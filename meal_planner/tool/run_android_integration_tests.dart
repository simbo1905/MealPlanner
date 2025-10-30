import 'dart:async';
import 'dart:io';

/// Runs all integration tests on a currently running Android device/emulator
/// without invoking the `emulator` CLI. Captures per-test logs and a device
/// logcat stream under ./tmp/.
///
/// Usage:
///   dart run tool/run_android_integration_tests.dart
Future<void> main() async {
  final testDir = Directory('integration_test');
  if (!await testDir.exists()) {
    stderr.writeln('No integration_test/ directory found.');
    exit(2);
  }
  final logsDir = Directory('tmp');
  if (!await logsDir.exists()) {
    await logsDir.create(recursive: true);
  }

  String getDeviceId() {
    final result = Process.runSync('adb', ['devices']);
    final lines = result.stdout.toString().split(RegExp(r'\r?\n'));
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('List of devices')) continue;
      if (line.endsWith('\tdevice')) {
        return line.split('\t').first.trim();
      }
    }
    throw 'No Android device (emulator or phone) is currently connected. Launch one from Android Studio → AVD Manager.';
  }

  String? whichBin(String bin) {
    try {
      final res = Process.runSync('which', [bin]);
      if (res.exitCode == 0) {
        final p = res.stdout.toString().trim();
        if (p.isNotEmpty) return p;
      }
    } catch (_) {}
    return null;
  }

  Future<int> runWithTimeout(
    List<String> cmd, {
    required Duration timeout,
    required File logFile,
  }) async {
    final logSink = logFile.openWrite(mode: FileMode.writeOnly);
    try {
      final proc = await Process.start(cmd.first, cmd.sublist(1), runInShell: true);
      final stdoutSub = proc.stdout.listen(logSink.add);
      final stderrSub = proc.stderr.listen(logSink.add);
      final timer = Timer(timeout, () {
        // Kill the entire process group (best effort)
        proc.kill(ProcessSignal.sigterm);
        proc.kill(ProcessSignal.sigkill);
      });
      final code = await proc.exitCode;
      timer.cancel();
      await stdoutSub.cancel();
      await stderrSub.cancel();
      return code;
    } finally {
      await logSink.flush();
      await logSink.close();
    }
  }

  String deviceId;
  try {
    deviceId = getDeviceId();
  } catch (e) {
    stderr.writeln('❌ $e');
    exit(1);
  }
  stdout.writeln('📱 Using device: $deviceId');

  // Start logcat capture
  final logcatFile = File('${logsDir.path}/logcat.log');
  final logcat = await Process.start('adb', ['logcat', '-v', 'time']);
  final logcatSink = logcatFile.openWrite();
  logcat.stdout.listen(logcatSink.add);
  logcat.stderr.listen(logcatSink.add);

  // Discover test files (*.dart) under integration_test/
  final tests = testDir
      .listSync(recursive: false)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  if (tests.isEmpty) {
    stderr.writeln('No integration tests found in integration_test/.');
    logcat.kill();
    await logcatSink.flush();
    await logcatSink.close();
    exit(3);
  }

  // Prefer GNU `timeout`, fallback to `gtimeout` (coreutils), else manual.
  final timeoutBin = whichBin('timeout') ?? whichBin('gtimeout');
  const seconds = 300;

  for (final file in tests) {
    final name = file.uri.pathSegments.last.replaceAll('.dart', '');
    final logPath = '${logsDir.path}/test_$name.log';
    stdout.writeln('▶️  Running $name → $logPath');

    int exitCode;
    if (timeoutBin != null) {
      final result = await Process.run(
        timeoutBin,
        [
          seconds.toString(),
          'flutter',
          'test',
          file.path,
          '--device-id',
          deviceId,
        ],
        runInShell: true,
      );
      await File(logPath)
          .writeAsString('${result.stdout}\n${result.stderr}', mode: FileMode.writeOnly);
      exitCode = result.exitCode;
    } else {
      // Manual timeout fallback
      exitCode = await runWithTimeout(
        [
          'flutter',
          'test',
          file.path,
          '--device-id',
          deviceId,
        ],
        timeout: Duration(seconds: seconds),
        logFile: File(logPath),
      );
    }

    if (exitCode != 0) {
      stderr.writeln('❌ $name failed (exit $exitCode)');
      logcat.kill();
      await logcatSink.flush();
      await logcatSink.close();
      exit(exitCode);
    }
  }

  logcat.kill();
  await logcatSink.flush();
  await logcatSink.close();
  stdout.writeln('✅ All integration tests passed. Logs are in ./tmp/');
}
