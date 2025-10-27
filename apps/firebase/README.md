# User Edit Form: Riverpod + Firebase + Offline

**TL;DR:** Complete working example of a Flutter form with Riverpod state management, Firebase persistence, offline support, and computed fields. Zero ORM thinking. No session hydration. Just immutable freezed objects, Riverpod watchers, and Firebase async await.

---

## Architecture Philosophy

**Your MongoDB lesson applies here:** Model data flat and indexed, handle writes carefully, resolve read-side inconsistencies in logic. Hibernate is dead.

**Dart's isolate boundary is a feature, not a problem:** Copy-on-send forces immutability. Freezed gives you zero-cost object cloning. Firebase SDK handles offline queuing—you just await.

**Riverpod is reactive wiring:** Providers are dependency-injected, computed values auto-recompute when inputs change, components watch providers and re-render.

No ORM session. No hydration. No managed entities. Just data objects in, JSON out, Firebase does the rest.

---

## What This App Does

1. **Load user from Firestore** (or local cache if offline)
2. **Edit form with two-way binding** (Name + DoB)
3. **Computed age field** auto-updates when DoB changes
4. **Title bar shows name + age** from edit state
5. **Save button persists to Firestore** (queues offline, syncs when online)
6. **Cancel button discards edits**
7. **All state transitions logged**, offline handling transparent

---

## Setup

### 1. Install dependencies

```bash
export PATH="/tmp/flutter/bin:$PATH"
cd /workspace/apps/firebase
flutter pub get
```

### 2. Generate code

Freezed and Riverpod require code generation:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This creates:
- `lib/models/user.freezed.dart` (immutable machinery)
- `lib/models/user.g.dart` (JSON serialization)
- `lib/providers/user_providers.g.dart` (Riverpod code-gen)

### 3. Set up Firebase (Local Emulator)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase
firebase init emulators

# Start emulator (localhost:8080 Firestore, :9099 Auth)
firebase emulators:start --only firestore,auth
```

### 4. Seed test data

```bash
# Add test user to Firestore emulator
firebase firestore:set /users/test-user-1 '{
  "id": "test-user-1",
  "name": "Alice Smith",
  "dateOfBirth": "1990-06-15T00:00:00.000Z"
}'
```

---

## Development Workflow

### Step 1: Unit Tests (fast, iterate quickly)

Test business logic (age calculation, JSON roundtrip):

```bash
flutter test test/providers/user_providers_test.dart
```

Expected output:
```
✓ Age calculation (2 tests passed)
✓ User model (1 test passed)
3 tests passed in 1.2s.
```

### Step 2: Integration Tests (web via Chrome)

Start Firebase emulator in one terminal:
```bash
firebase emulators:start --only firestore,auth
```

In another terminal:
```bash
timeout 180 ./flutter_test_server.sh
```

Tail logs in a third terminal:
```bash
tail -f .tmp/flutter_test_server.sh.log
```

---

## Running the App

### iOS Simulator

```bash
flutter run -d ios
```

### Web (Chrome)

```bash
flutter run -d chrome
```

---

## File Structure

```
apps/firebase/
├── lib/
│   ├── main.dart                  (app entry + Firebase init)
│   ├── models/
│   │   └── user.dart              (@freezed User + JSON)
│   ├── providers/
│   │   └── user_providers.dart    (fetchUser, editState, save)
│   └── screens/
│       └── user_edit_screen.dart  (UI components)
├── test/
│   └── providers/
│       └── user_providers_test.dart (unit tests)
├── integration_test/
│   └── user_edit_test.dart         (integration tests)
├── test_driver/
│   └── integration_test_driver.dart (driver entry)
├── pubspec.yaml
├── flutter_test_server.sh          (test harness)
└── .tmp/                           (generated at test runtime)
```

---

## Key Principles Applied

1. **Immutable data:** Freezed for zero-copy semantics across isolates
2. **Offline first:** Firebase SDK handles sync automatically
3. **Computed state:** Riverpod providers derive age from DoB, no manual recomputation
4. **Separation:** Read path (fetchUser), edit path (userEditStateNotifier), write path (userSaveNotifier)
5. **Simple components:** Stateless widgets listening to providers
6. **No ORM thinking:** No hydration, no session, just JSON ↔ immutable objects
7. **Firebase does the work:** Auth, persistence, offline, sync—you just await

---

## Debugging

### "Age field shows null"
→ `currentEditedUser` is null (form still loading)
→ Add null check in UI or wait for `fetchUser` to complete

### "Name doesn't update in title"
→ `_TitlePanel` not watching `currentEditedUserProvider`
→ Verify `ref.watch(currentEditedUserProvider)` is in the build method

### "Save doesn't persist"
→ Firestore rules deny write
→ Check rules: `allow write: if request.auth.uid == userId`

### "Offline write never syncs"
→ Firebase not initialized, or emulator not running
→ Verify: `firebase emulators:start --only firestore,auth`

---

## References

- **Riverpod docs:** https://riverpod.dev
- **Firebase + Flutter:** https://firebase.google.com/docs/flutter/setup
- **Freezed:** https://pub.dev/packages/freezed
- **Integration test:** https://docs.flutter.dev/testing/integration-tests
- **Firebase Emulator:** https://firebase.google.com/docs/emulator-suite/install_and_configure
