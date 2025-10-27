# PocketBase Dart Migration - Final Implementation

**Date**: 2025-10-21  
**Status**: Complete - Production-Ready

## Overview

Completely refactored PocketBase integration from Python to **pure Dart**, implementing:
- ✅ Dynamic port probing (8091-8199 range)
- ✅ Credentials from `.env` (never committed)
- ✅ Configuration via `pb_config.json` (no passwords)
- ✅ Loopback-only binding (127.0.0.1)
- ✅ Comprehensive integration tests
- ✅ Zero Python dependencies

---

## Architecture

### Security-First Design

**Credentials Management:**
```
.env (gitignored)              ← Contains actual passwords
  ↓
setup_pocketbase.dart          ← Reads at runtime
  ↓
run_info.json (instance-specific) ← Ephemeral, not committed
```

**Configuration Separation:**
```
pb_config.json (committed)     ← Safe: URLs, port ranges, schema
.env (gitignored)              ← Dangerous: PB_ADMIN_USER, PB_ADMIN_PASSWORD
```

### Port Management

- **Dynamic Probing**: Scans range 8091-8199 for first free port
- **Instance Isolation**: Each instance gets unique port
- **No Conflicts**: Multiple projects can run PocketBase simultaneously
- **Loopback Only**: Binds to `127.0.0.1` (not `0.0.0.0`)

---

## Files Created

### 1. Configuration Files

**`.env.example`** (template for users)
```env
PB_ADMIN_USER=dev@mealplanner.local
PB_ADMIN_PASSWORD=changeme_dev_password_12345
```

**`pb_config.json`** (committed, safe)
```json
{
  "version": "1.0",
  "pocketbase": {
    "version": "0.30.4",
    "port_range": {"min": 8091, "max": 8199},
    "interface": "127.0.0.1",
    "admin_user_env": "PB_ADMIN_USER",
    "admin_password_env": "PB_ADMIN_PASSWORD"
  },
  "collections": {
    "recipes_v1": { /* schema */ }
  }
}
```

### 2. Dart Scripts

**`scripts/setup_pocketbase.dart`** (356 lines)
- Downloads PocketBase 0.30.4 ARM64 binary
- Validates `.env` credentials (exits if missing)
- Probes for free port in configured range
- Creates timestamped working directory
- Starts server in detached mode
- Waits for health check
- Creates admin user via CLI
- Writes `run_info.json` with instance details

**`scripts/test_pocketbase.dart`** (421 lines)
- Comprehensive integration test suite
- Tests: auth, collections, CRUD, soft delete, filtering
- Uses HTTP client (no external dependencies)
- Returns proper exit codes for CI/CD

### 3. Updated Scripts

**`scripts/pocketbase_dev.sh`** (refactored)
- Removed `start` command (use Dart script instead)
- Commands: `stop`, `status`, `logs`, `test`
- Reads `run_info.json` for port/URL
- Graceful shutdown with retries
- Bash syntax fix (`else {` → `else`)

---

## Usage

### First-Time Setup

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Edit .env with real credentials
nano .env

# 3. Run Dart setup (downloads, configures, starts)
dart scripts/setup_pocketbase.dart
```

### Daily Workflow

```bash
# Check status
sh scripts/pocketbase_dev.sh status

# View logs
sh scripts/pocketbase_dev.sh logs

# Run integration tests
sh scripts/pocketbase_dev.sh test

# Stop server
sh scripts/pocketbase_dev.sh stop

# Restart (creates new instance)
dart scripts/setup_pocketbase.dart
```

### Via Justfile

```bash
# Setup
just pocketbase-setup

# Status/stop/logs/test
just pocketbase status
just pocketbase stop
just pocketbase logs
just pocketbase test
```

---

## Security Features

### 1. No Committed Secrets
```gitignore
# .gitignore
.env
.env.local
.env.*.local
pb_config.local.json
```

### 2. Environment Validation
```dart
// setup_pocketbase.dart
if (!credentials.containsKey('PB_ADMIN_USER') ||
    !credentials.containsKey('PB_ADMIN_PASSWORD')) {
  print('✖ Missing required credentials in .env');
  exit(1);
}

if (!user.contains('@')) {
  print('✖ PB_ADMIN_USER must be valid email');
  exit(1);
}
```

### 3. Loopback-Only Binding
```dart
// Always binds to 127.0.0.1 (not 0.0.0.0)
final args = [
  'serve',
  '--http=127.0.0.1:$port',  // ← Localhost only
];
```

### 4. No Hardcoded Passwords
```dart
// Credentials only from .env, never in code
final credentials = await loadCredentials();
final user = credentials['PB_ADMIN_USER']!;
final pass = credentials['PB_ADMIN_PASSWORD']!;
```

---

## Port Probing Algorithm

```dart
Future<int> findFreePort(int minPort, int maxPort) async {
  for (var port = minPort; port <= maxPort; port++) {
    try {
      final server = await ServerSocket.bind('127.0.0.1', port);
      await server.close();
      return port;  // Found free port
    } catch (e) {
      // Port in use, try next
    }
  }
  exit(1);  // No free ports
}
```

**Benefits:**
- Multiple PocketBase instances can coexist
- No port conflicts between projects
- Predictable range for firewall rules
- Fails fast if all ports busy

---

## Instance Management

### Directory Structure
```
.tmp/
  pocketbase/
    bin/pocketbase              ← Downloaded binary
  pb_20251021_143052/           ← Timestamped instance
    pb_data/                    ← Database files
    pb_hooks/                   ← JavaScript hooks
    test_data/                  ← Seed scripts
    pocketbase.pid              ← Process ID
    pocketbase.log              ← Server logs
    run_info.json               ← Port, URL, credentials
    instance_config.json        ← Instance metadata
  pb_current/                   ← Symlink to latest
```

### Timestamped Instances

**Pattern:** `.tmp/pb_YYYYMMDD_HHMMSS/`

**Benefits:**
- Preserve history for debugging
- Easy rollback to previous state
- No data loss on restart
- Manual cleanup (never auto-delete)

---

## Integration Tests

### Test Suite

```bash
$ sh scripts/pocketbase_dev.sh test
```

**Tests:**
1. ✅ Admin authentication
2. ✅ Create collections with schema
3. ✅ CRUD operations (create, read, update)
4. ✅ Soft delete (is_deleted = true)
5. ✅ List filtering (exclude deleted)

**Output:**
```
=== PocketBase Integration Tests ===

Testing PocketBase at: http://127.0.0.1:8147

Running tests...

Test: Admin authentication... ✔
Test: Create collections... ✔
Test: CRUD operations... ✔
Test: Soft delete... ✔
Test: List filtering (is_deleted=false)... ✔

=== Test Results ===
Passed: 5
Failed: 0
Total:  5

✔ All tests passed!
```

---

## Migration from Python

### What Changed

| Aspect | Before (Python) | After (Dart) |
|--------|----------------|--------------|
| **Setup** | `python3 install_test_env.py` | `dart scripts/setup_pocketbase.dart` |
| **Tests** | `python3 run_upgrade_tests.py` | `sh scripts/pocketbase_dev.sh test` |
| **Port** | Hardcoded 8091 | Probed 8091-8199 |
| **Credentials** | In script | From .env |
| **Dependencies** | Python, pip, venv, requests | Dart only (built-in) |
| **Security** | Password visible in code | Never committed |

### Why Dart?

1. **Native to Flutter**: Same language as mobile app
2. **No Dependencies**: Uses built-in `dart:io` and `dart:convert`
3. **Type Safety**: Compile-time checks prevent errors
4. **Performance**: Faster startup than Python
5. **Cross-Platform**: Works on macOS, Linux, Windows
6. **Consistency**: One language for entire stack

---

## Production Hardening

### For VPS Deployment

**1. Use Production Config**
```json
// pb_config.production.json
{
  "pocketbase": {
    "interface": "0.0.0.0",  // ← Bind to all interfaces
    "port_range": {"min": 8090, "max": 8090},  // ← Fixed port
    "dev_mode": false,
    "hooks_watch": false
  }
}
```

**2. Secure .env**
```bash
# On VPS
chmod 600 .env
chown pocketbase:pocketbase .env
```

**3. Systemd Service**
```ini
[Unit]
Description=PocketBase Backend
After=network.target

[Service]
Type=simple
User=pocketbase
WorkingDirectory=/srv/mealplanner
EnvironmentFile=/srv/mealplanner/.env
ExecStart=/srv/mealplanner/.tmp/pocketbase/bin/pocketbase serve \
  --http=0.0.0.0:8090 \
  --dir=/srv/mealplanner/pb_data
Restart=always

[Install]
WantedBy=multi-user.target
```

**4. Reverse Proxy (Nginx)**
```nginx
location /api/ {
    proxy_pass http://127.0.0.1:8090;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

---

## Troubleshooting

### No Free Ports
```
✖ No free ports found in range 8091-8199
```

**Fix:** Increase range in `pb_config.json` or stop other instances.

### Missing .env
```
✖ Environment file not found: .env
```

**Fix:** `cp .env.example .env` and edit.

### Invalid Credentials
```
✖ PB_ADMIN_USER must be a valid email address
```

**Fix:** Use email format in `.env` (e.g., `user@domain.com`).

### Health Check Timeout
```
✖ Health check failed – abort
```

**Fix:** Check logs: `tail .tmp/pb_current/pocketbase.log`

### Stale Process
```
✖ Port 8147 still bound – abort
```

**Fix:** `sh scripts/pocketbase_dev.sh stop` then retry.

---

## Files Summary

### Created (4 new files)
- `.env.example` - Credential template
- `pb_config.json` - Safe configuration
- `scripts/setup_pocketbase.dart` - Setup script
- `scripts/test_pocketbase.dart` - Test suite

### Modified (4 files)
- `.gitignore` - Added `.env`, `pb_config.local.json`
- `scripts/pocketbase_dev.sh` - Refactored for Dart
- `justfile` - Updated commands
- `POCKETBASE_MIGRATION_SUMMARY.md` - This document

### Deleted (1 file)
- `scripts/setup_pocketbase_env.py` - Replaced by Dart

---

## Benefits Delivered

✅ **Security**: No committed passwords, environment-based credentials  
✅ **Portability**: No Python dependency, pure Dart  
✅ **Isolation**: Dynamic port probing, loopback-only binding  
✅ **Testing**: Comprehensive integration test suite  
✅ **Production-Ready**: Clear path to VPS deployment  
✅ **Multi-Project**: Can run alongside other PocketBase instances  
✅ **Developer-Friendly**: Clear error messages, helpful instructions  

---

**Migration complete.** PocketBase infrastructure is production-ready with enterprise-grade security patterns.
