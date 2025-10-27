#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';

/// PocketBase Development Environment Setup
/// 
/// Downloads PocketBase, probes for free port, creates admin user from .env,
/// and starts the development server.
/// 
/// Requirements:
/// - .env file with PB_ADMIN_USER and PB_ADMIN_PASSWORD
/// - pb_config.json with configuration
/// 
/// Usage:
///   dart scripts/setup_pocketbase.dart

const kConfigFile = 'pb_config.json';
const kEnvFile = '.env';
const kMinPort = 8091;
const kMaxPort = 8199;

void main() async {
  print('=== PocketBase Development Environment Setup ===\n');

  // Load configuration
  final config = await loadConfig();
  final credentials = await loadCredentials();

  // Ensure directories
  await ensureDirectories(config);

  // Download binary if needed
  final binaryPath = await ensureBinary(config);

  // Find free port
  final port = await findFreePort(
    config['pocketbase']['port_range']['min'] ?? kMinPort,
    config['pocketbase']['port_range']['max'] ?? kMaxPort,
  );

  print('✔ Found free port: $port\n');

  // Create timestamped working directory
  final workDir = await createWorkingDirectory(config);

  // Write instance configuration
  await writeInstanceConfig(workDir, port, credentials);

  // Create admin user BEFORE starting server (avoid concurrency)
  await createAdminUser(
    binaryPath: binaryPath,
    workDir: workDir,
    credentials: credentials,
  );

  // Start PocketBase
  final pid = await startPocketBase(
    binaryPath: binaryPath,
    workDir: workDir,
    port: port,
    config: config,
  );

  // Wait for health check
  final url = 'http://127.0.0.1:$port';
  final healthy = await waitForHealth(url);

  if (!healthy) {
    print('✖ Health check failed\n');
    exit(1);
  }

  // Write run info
  await writeRunInfo(
    workDir: workDir,
    url: url,
    port: port,
    pid: pid,
    credentials: credentials,
  );

  print('\n=== Setup Complete ===');
  print('PocketBase running on: $url');
  print('Admin UI: $url/_/');
  print('PID: $pid');
  print('Working directory: $workDir');
  print('\nNext steps:');
  print('1. Visit $url/_/ to verify admin login');
  print('2. Collections will be auto-created on first app run');
  print('3. Run Flutter app: cd meal_planner && flutter run -d chrome');
  print('\nControl:');
  print('  sh scripts/pocketbase_dev.sh status');
  print('  sh scripts/pocketbase_dev.sh stop');
  print('');
}

Future<Map<String, dynamic>> loadConfig() async {
  final file = File(kConfigFile);
  if (!await file.exists()) {
    print('✖ Configuration file not found: $kConfigFile');
    exit(1);
  }

  try {
    final content = await file.readAsString();
    final config = json.decode(content) as Map<String, dynamic>;
    print('✔ Loaded configuration from $kConfigFile');
    return config;
  } catch (e) {
    print('✖ Failed to parse $kConfigFile: $e');
    exit(1);
  }
}

Future<Map<String, String>> loadCredentials() async {
  final file = File(kEnvFile);
  if (!await file.exists()) {
    print('✖ Environment file not found: $kEnvFile');
    print('  Copy .env.example to .env and fill in credentials');
    exit(1);
  }

  final credentials = <String, String>{};
  final lines = await file.readAsLines();

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

    final parts = trimmed.split('=');
    if (parts.length == 2) {
      credentials[parts[0].trim()] = parts[1].trim();
    }
  }

  if (!credentials.containsKey('PB_ADMIN_USER') ||
      !credentials.containsKey('PB_ADMIN_PASSWORD')) {
    print('✖ Missing required credentials in .env:');
    print('  PB_ADMIN_USER and PB_ADMIN_PASSWORD');
    exit(1);
  }

  final user = credentials['PB_ADMIN_USER']!;
  if (!user.contains('@')) {
    print('✖ PB_ADMIN_USER must be a valid email address');
    exit(1);
  }

  print('✔ Loaded credentials from .env');
  print('  User: $user');

  return credentials;
}

Future<void> ensureDirectories(Map<String, dynamic> config) async {
  final binaryPath = config['pocketbase']['binary_path'] as String;
  final binDir = Directory(dirname(binaryPath));

  if (!await binDir.exists()) {
    await binDir.create(recursive: true);
    print('✔ Created directory: ${binDir.path}');
  }
}

String dirname(String path) {
  final parts = path.split('/');
  return parts.sublist(0, parts.length - 1).join('/');
}

String basename(String path) {
  return path.split('/').last;
}

String joinPath(String... parts) {
  return parts.join('/');
}

Future<String> ensureBinary(Map<String, dynamic> config) async {
  final binaryPath = config['pocketbase']['binary_path'] as String;
  final file = File(binaryPath);

  if (await file.exists()) {
    print('✔ PocketBase binary exists: $binaryPath');
    return binaryPath;
  }

  print('➡ Downloading PocketBase...');
  final downloadUrl = config['pocketbase']['download_url'] as String;
  final zipPath = '$binaryPath.zip';

  // Download
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(downloadUrl));
    final response = await request.close();

    if (response.statusCode != 200) {
      print('✖ Download failed: HTTP ${response.statusCode}');
      exit(1);
    }

    final zipFile = File(zipPath);
    final sink = zipFile.openWrite();
    await response.pipe(sink);
    await sink.close();

    print('✔ Downloaded: $zipPath');

    // Extract (using system unzip)
    final result = await Process.run('unzip', [
      '-o',
      zipPath,
      '-d',
      dirname(binaryPath),
    ]);

    if (result.exitCode != 0) {
      print('✖ Extraction failed: ${result.stderr}');
      exit(1);
    }

    // Make executable
    await Process.run('chmod', ['+x', binaryPath]);

    // Clean up
    await File(zipPath).delete();

    print('✔ Extracted and installed: $binaryPath');
    return binaryPath;
  } finally {
    client.close();
  }
}

Future<int> findFreePort(int minPort, int maxPort) async {
  for (var port = minPort; port <= maxPort; port++) {
    try {
      final server = await ServerSocket.bind('127.0.0.1', port);
      await server.close();
      return port;
    } catch (e) {
      // Port in use, try next
    }
  }

  print('✖ No free ports found in range $minPort-$maxPort');
  exit(1);
}

Future<String> createWorkingDirectory(Map<String, dynamic> config) async {
  final now = DateTime.now();
  final timestamp = '${now.year}${pad(now.month)}${pad(now.day)}'
      '${pad(now.hour)}${pad(now.minute)}${pad(now.second)}';

  final pattern = config['pocketbase']['working_dir_pattern'] as String;
  final workDir = pattern.replaceAll('{timestamp}', timestamp);

  final dir = Directory(workDir);
  await dir.create(recursive: true);

  // Create subdirectories
  await Directory('$workDir/pb_data').create();
  await Directory('$workDir/pb_hooks').create();
  await Directory('$workDir/test_data').create();

  // Create hooks README
  final hooksReadme = File('$workDir/pb_hooks/README.md');
  await hooksReadme.writeAsString('''# PocketBase Hooks

JavaScript hooks for server-side transactions and validation.

See: https://pocketbase.io/docs/js-overview/

Examples:
- Transaction guarantees for multi-collection writes
- Custom validation rules
- Server-side computed fields
- Automated event triggers

Not required for MVP; foundation for future features.
''');

  // Update current symlink (absolute path)
  final currentLink = config['pocketbase']['current_link'] as String;
  final link = Link(currentLink);
  if (await link.exists()) {
    await link.delete();
  }
  
  final absWorkDir = Directory(workDir).absolute.path;
  await link.create(absWorkDir);

  print('✔ Created working directory: $workDir');
  print('✔ Updated symlink: $currentLink -> $absWorkDir');

  return workDir;
}

String pad(int value) {
  return value.toString().padLeft(2, '0');
}

Future<void> writeInstanceConfig(
  String workDir,
  int port,
  Map<String, String> credentials,
) async {
  final instanceConfig = {
    'port': port,
    'interface': '127.0.0.1',
    'url': 'http://127.0.0.1:$port',
    'admin_ui': 'http://127.0.0.1:$port/_/',
    'created_at': DateTime.now().toIso8601String(),
  };

  final file = File('$workDir/instance_config.json');
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(instanceConfig),
  );

  print('✔ Wrote instance config: ${file.path}');
}

Future<int> startPocketBase({
  required String binaryPath,
  required String workDir,
  required int port,
  required Map<String, dynamic> config,
}) async {
  final logFile = '$workDir/pocketbase.log';
  final pidFile = '$workDir/pocketbase.pid';

  final args = [
    'serve',
    '--dir=$workDir/pb_data',
    '--http=127.0.0.1:$port',
    '--hooksDir=$workDir/pb_hooks',
  ];

  if (config['pocketbase']['dev_mode'] == true) {
    args.add('--dev');
  }

  if (config['pocketbase']['hooks_watch'] == true) {
    args.add('--hooksWatch');
  }

  print('➡ Starting PocketBase...');
  print('   Command: $binaryPath ${args.join(' ')}');

  // Start process with output redirected to file
  final process = await Process.start(
    binaryPath,
    args,
    mode: ProcessStartMode.normal,
  );

  // Redirect output to log file
  final logFileHandle = File(logFile).openWrite();
  process.stdout.listen((chunk) => logFileHandle.add(chunk));
  process.stderr.listen((chunk) => logFileHandle.add(chunk));
  
  // Close log when process exits
  process.exitCode.then((_) => logFileHandle.close());

  // Write PID
  await File(pidFile).writeAsString('${process.pid}');

  print('✔ PocketBase started (PID: ${process.pid})');
  print('  Log: $logFile');

  return process.pid;
}

Future<bool> waitForHealth(String url, {int timeoutSeconds = 30}) async {
  print('➡ Waiting for health check at $url/api/health...');

  final client = HttpClient();
  final deadline = DateTime.now().add(Duration(seconds: timeoutSeconds));

  try {
    while (DateTime.now().isBefore(deadline)) {
      try {
        final request = await client.getUrl(Uri.parse('$url/api/health'));
        final response = await request.close();

        if (response.statusCode == 200) {
          print('✔ Health check passed');
          return true;
        }
      } catch (e) {
        // Server not ready yet
      }

      await Future.delayed(const Duration(seconds: 2));
      stdout.write('.');
    }

    print('\n✖ Health check timeout after $timeoutSeconds seconds');
    return false;
  } finally {
    client.close();
  }
}

Future<void> createAdminUser({
  required String binaryPath,
  required String workDir,
  required Map<String, String> credentials,
}) async {
  print('➡ Creating/updating admin user...');

  final result = await Process.run(
    binaryPath,
    [
      'superuser',
      'upsert',
      credentials['PB_ADMIN_USER']!,
      credentials['PB_ADMIN_PASSWORD']!,
      '--dir=$workDir/pb_data',
    ],
  );

  if (result.exitCode != 0) {
    print('✖ Failed to create admin user: ${result.stderr}');
    exit(1);
  }

  print('✔ Admin user created/updated');
}

Future<void> writeRunInfo({
  required String workDir,
  required String url,
  required int port,
  required int pid,
  required Map<String, String> credentials,
}) async {
  final runInfo = {
    'url': url,
    'port': port,
    'admin_ui': '$url/_/',
    'pid': pid,
    'working_directory': workDir,
    'started_at': DateTime.now().toIso8601String(),
    'admin_user': credentials['PB_ADMIN_USER'],
    'log_file': '$workDir/pocketbase.log',
    'pid_file': '$workDir/pocketbase.pid',
  };

  final file = File('$workDir/run_info.json');
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(runInfo),
  );

  print('✔ Wrote run info: ${file.path}');
}
