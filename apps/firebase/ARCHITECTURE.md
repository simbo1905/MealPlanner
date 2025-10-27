# Firebase User Edit App Architecture

## Overview

This Flutter application demonstrates a complete user edit form with:
- Riverpod state management
- Firebase Firestore persistence
- Offline-first architecture
- Computed reactive fields
- Comprehensive test coverage

## Architecture Principles

### 1. Immutability First

**Freezed models** ensure data is immutable:
- Copy-on-write semantics
- Safe across isolates
- No dangling references
- Zero-cost object cloning

```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required DateTime dateOfBirth,
  }) = _User;
}
```

### 2. Reactive State Management

**Riverpod providers** wire the app:
- Dependency injection built-in
- Computed values auto-recompute
- Components watch and re-render
- No callbacks, no setState

### 3. Offline-First Persistence

**Firebase SDK handles sync**:
- Local cache (SQLite on device)
- Write queue for offline operations
- Automatic sync when online
- App just awaits operations

## Component Architecture

### State Flow

```
Firebase Firestore (canonical source)
    ↓
fetchUser provider (read)
    ↓
userEditStateNotifier (mutable edit state)
    ↓
currentEditedUser (computed)
    ↓
currentAge (computed)
    ↓
UI Components (watch & render)
```

### Provider Layers

#### Read Layer: `fetchUser`
- Fetches user from Firestore
- Returns `AsyncValue<User>`
- Firebase SDK handles offline cache
- UI watches and shows loading/error/data states

#### Edit Layer: `userEditStateNotifier`
- Holds in-flight uncommitted changes
- Provides `updateName()`, `updateDateOfBirth()`
- Stateful provider (can be mutated)
- Separate from canonical data

#### Computed Layer: `currentEditedUser` & `currentAge`
- Derived from edit state
- Auto-recompute when inputs change
- Pure functions (no side effects)
- UI watches for reactive updates

#### Write Layer: `userSaveNotifier`
- Persists to Firestore
- Manages async save state
- Resets edit state on success
- Returns `AsyncValue<void>` for loading/error states

## UI Component Structure

### UserEditScreen (StatefulWidget + Consumer)
- Manages screen lifecycle
- Loads user on mount
- Coordinates save/cancel actions
- Watches multiple providers

### _TitlePanel (ConsumerWidget)
- Shows name + computed age
- Watches `currentEditedUser` and `currentAge`
- Re-renders on any edit

### _EditPanel (ConsumerWidget)
- Two-way binding for name
- Date picker for DoB
- Shows computed age
- Notifies providers on change

### _BottomButtonPanel (StatelessWidget)
- Save/Cancel actions
- Shows loading spinner during save
- Disables buttons when saving

## Data Flow Examples

### Load Flow
1. Screen mounts → `_loadUser()` called
2. `fetchUserProvider(userId)` executes
3. Firebase SDK checks local cache
4. If offline: returns cached data
5. If online: fetches from Firestore, updates cache
6. Provider returns `AsyncValue<User>`
7. UI shows loading → data → rendered form

### Edit Flow
1. User types in name field
2. TextField `onChanged` fires
3. `userEditStateNotifier.updateName(value)` called
4. Edit state updated
5. `currentEditedUser` recomputes
6. All watchers notified
7. Title and TextField update

### Save Flow
1. User taps Save button
2. `userSaveNotifier.save(user)` called
3. State set to loading
4. Firebase `set()` called with merge
5. If online: writes immediately
6. If offline: queues locally
7. On success: edit state reset
8. Screen pops

## Testing Strategy

### Unit Tests (Fast)
- Age calculation logic
- JSON serialization roundtrip
- Pure business logic
- No Firebase dependencies

```bash
flutter test test/providers/user_providers_test.dart
```

### Integration Tests (Comprehensive)
- Full user flows
- Firebase emulator
- Chrome web driver
- Real async interactions

```bash
./flutter_test_server.sh
```

## Firebase Configuration

### Emulator Setup
```json
{
  "emulators": {
    "firestore": { "port": 8080 },
    "auth": { "port": 9099 },
    "ui": { "enabled": true, "port": 4000 }
  }
}
```

### Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId || request.auth == null;
    }
  }
}
```

## Development Workflow

### 1. Setup
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Unit Tests
```bash
flutter test
```

### 3. Integration Tests
```bash
# Terminal 1: Start Firebase emulator
firebase emulators:start --only firestore,auth

# Terminal 2: Run tests
timeout 180 ./flutter_test_server.sh

# Terminal 3: Watch logs
tail -f .tmp/flutter_test_server.sh.log
```

### 4. Run App
```bash
flutter run -d ios     # iOS Simulator
flutter run -d chrome  # Chrome web
```

## Key Design Decisions

### Why Freezed?
- Immutability enforced at compile time
- Copy-with semantics for updates
- JSON serialization built-in
- Safe across isolates

### Why Riverpod?
- Compile-time safety
- No BuildContext needed in providers
- Computed values built-in
- Better testing than Provider

### Why Firebase?
- Offline support built-in
- Real-time updates
- Scales from MVP to production
- Auth + Firestore + Functions in one SDK

### Why No ORM?
- Dart isolates copy data anyway
- JSON is the wire format
- No impedance mismatch
- Simple, predictable

## Common Pitfalls & Solutions

### Problem: Age shows null
**Cause:** `currentEditedUser` is null (not loaded)
**Solution:** Add null check in UI or wait for `fetchUser` to complete

### Problem: Name doesn't update in title
**Cause:** `_TitlePanel` not watching `currentEditedUserProvider`
**Solution:** Verify `ref.watch(currentEditedUserProvider)` in build method

### Problem: Save doesn't persist
**Cause:** Firestore rules deny write
**Solution:** Check rules allow writes for test user or disable auth

### Problem: Offline write never syncs
**Cause:** Firebase not initialized or emulator not running
**Solution:** Start emulator: `firebase emulators:start --only firestore,auth`

## Future Enhancements

- [ ] Form validation
- [ ] Error handling UI
- [ ] Optimistic updates
- [ ] Conflict resolution
- [ ] Multiple user support
- [ ] Authentication
- [ ] Real-time listeners
- [ ] Batch operations
