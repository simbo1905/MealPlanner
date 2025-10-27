# Decoupling Widget Tests from Firebase with Riverpod

You're absolutely right to want this separation. Here's the pragmatic Teemu-aligned approach:

## The Strategy: Provider Overrides + Repository Pattern

**Core principle:** Widgets should never know about Firebase. They only know about Riverpod providers. Tests override providers with in-memory implementations.

## Architecture Layers

### 1. **Repository Interface (Abstract Contract)**

Define what operations exist, not how they're implemented:

```dart
// lib/repositories/user_repository.dart
abstract class UserRepository {
  Stream<User?> watchUser(String userId);
  Future<User> getUser(String userId);
  Future<void> updateUser(String userId, User user);
  Future<void> deleteUser(String userId);
}
```

### 2. **Firebase Implementation (Production)**

Real Firestore integration:

```dart
// lib/repositories/firebase_user_repository.dart
class FirebaseUserRepository implements UserRepository {
  final FirebaseFirestore _firestore;
  
  FirebaseUserRepository(this._firestore);
  
  @override
  Stream<User?> watchUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return User.fromJson(doc.data()!);
        });
  }
  
  @override
  Future<User> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) throw UserNotFoundException(userId);
    return User.fromJson(doc.data()!);
  }
  
  @override
  Future<void> updateUser(String userId, User user) async {
    await _firestore.collection('users').doc(userId).update({
      ...user.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
      'version': FieldValue.increment(1),
    });
  }
  
  @override
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}
```

### 3. **In-Memory Implementation (Testing)**

Fast, synchronous, no Firebase dependency:

```dart
// test/repositories/fake_user_repository.dart
class FakeUserRepository implements UserRepository {
  final Map<String, User> _users = {};
  final Map<String, StreamController<User?>> _controllers = {};
  
  // Pre-seed data for tests
  void seed(String userId, User user) {
    _users[userId] = user;
    _notifyListeners(userId);
  }
  
  void clear() {
    _users.clear();
    for (var controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
  
  @override
  Stream<User?> watchUser(String userId) {
    _controllers[userId] ??= StreamController<User?>.broadcast();
    
    // Emit current value immediately
    Future.microtask(() {
      if (!_controllers[userId]!.isClosed) {
        _controllers[userId]!.add(_users[userId]);
      }
    });
    
    return _controllers[userId]!.stream;
  }
  
  @override
  Future<User> getUser(String userId) async {
    final user = _users[userId];
    if (user == null) throw UserNotFoundException(userId);
    return user;
  }
  
  @override
  Future<void> updateUser(String userId, User user) async {
    if (!_users.containsKey(userId)) {
      throw UserNotFoundException(userId);
    }
    _users[userId] = user;
    _notifyListeners(userId);
  }
  
  @override
  Future<void> deleteUser(String userId) async {
    _users.remove(userId);
    _notifyListeners(userId);
  }
  
  void _notifyListeners(String userId) {
    if (_controllers.containsKey(userId) && !_controllers[userId]!.isClosed) {
      _controllers[userId]!.add(_users[userId]);
    }
  }
}
```

### 4. **Riverpod Provider Layer**

This is where the magic happens - the app only sees providers:

```dart
// lib/providers/user_providers.dart

// Repository provider - this is what we override in tests
final userRepositoryProvider = Provider<UserRepository>((ref) {
  // Production: return Firebase implementation
  return FirebaseUserRepository(FirebaseFirestore.instance);
});

// Data providers - widgets watch these
final userStreamProvider = StreamProvider.family<User?, String>((ref, userId) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.watchUser(userId);
});

final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUser(userId);
});

// Derived/computed providers
final userDisplayProvider = Provider.family<UserDisplay?, String>((ref, userId) {
  final userAsync = ref.watch(userStreamProvider(userId));
  
  return userAsync.when(
    data: (user) {
      if (user == null) return null;
      return UserDisplay(
        displayName: user.name.toUpperCase(),
        initials: user.name.split(' ').map((e) => e[0]).join(),
        isVerified: user.email.isNotEmpty,
      );
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Mutation provider
final updateUserProvider = Provider<Future<void> Function(String, User)>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return (userId, user) => repository.updateUser(userId, user);
});
```

## Widget Implementation (Firebase-Agnostic)

```dart
// lib/widgets/user_profile_widget.dart
class UserProfileWidget extends ConsumerWidget {
  final String userId;
  
  const UserProfileWidget({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider(userId));
    
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Text('User not found');
        }
        return Column(
          children: [
            Text(user.name),
            Text(user.email),
            ElevatedButton(
              onPressed: () async {
                final updateUser = ref.read(updateUserProvider);
                await updateUser(
                  userId,
                  user.copyWith(name: 'Updated Name'),
                );
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

## Widget Tests (Fast, In-Memory)

```dart
// test/widgets/user_profile_widget_test.dart
void main() {
  late FakeUserRepository fakeRepo;
  
  setUp(() {
    fakeRepo = FakeUserRepository();
  });
  
  tearDown(() {
    fakeRepo.clear();
  });

  testWidgets('displays user data from repository', (tester) async {
    // Arrange: seed test data
    final testUser = User(
      id: '123',
      name: 'Simon Test',
      email: 'simon@test.com',
      createdAt: DateTime(2025, 1, 1),
    );
    fakeRepo.seed('123', testUser);
    
    // Act: render widget with overridden repository
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: UserProfileWidget(userId: '123'),
          ),
        ),
      ),
    );
    
    // Wait for stream to emit
    await tester.pump();
    
    // Assert
    expect(find.text('Simon Test'), findsOneWidget);
    expect(find.text('simon@test.com'), findsOneWidget);
  });
  
  testWidgets('shows loading state initially', (tester) async {
    // Don't seed data - repository is empty
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: UserProfileWidget(userId: '123'),
          ),
        ),
      ),
    );
    
    // Before first pump - loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    await tester.pump();
    
    // After data emits (null) - not found state
    expect(find.text('User not found'), findsOneWidget);
  });
  
  testWidgets('updates user when button pressed', (tester) async {
    final testUser = User(
      id: '123',
      name: 'Simon',
      email: 'simon@test.com',
      createdAt: DateTime(2025, 1, 1),
    );
    fakeRepo.seed('123', testUser);
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(fakeRepo),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: UserProfileWidget(userId: '123'),
          ),
        ),
      ),
    );
    
    await tester.pump();
    expect(find.text('Simon'), findsOneWidget);
    
    // Tap update button
    await tester.tap(find.text('Update'));
    await tester.pump();
    
    // Verify repository was updated
    final updatedUser = await fakeRepo.getUser('123');
    expect(updatedUser.name, 'Updated Name');
    
    // UI should reflect the change (stream emits new value)
    await tester.pump();
    expect(find.text('Updated Name'), findsOneWidget);
  });
  
  testWidgets('handles derived display provider', (tester) async {
    final testUser = User(
      id: '123',
      name: 'Simon Test',
      email: 'simon@test.com',
      createdAt: DateTime(2025, 1, 1),
    );
    fakeRepo.seed('123', testUser);
    
    final container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
    
    // Let stream emit
    await Future.delayed(Duration.zero);
    
    final display = container.read(userDisplayProvider('123'));
    
    expect(display?.displayName, 'SIMON TEST');
    expect(display?.initials, 'ST');
    expect(display?.isVerified, true);
    
    container.dispose();
  });
}
```

## Unit Tests for Repository Logic

```dart
// test/repositories/firebase_user_repository_test.dart
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirebaseUserRepository repository;
  
  setUp(() {
    fakeFirestore = FakeFirebaseFirestore(); // from fake_cloud_firestore package
    repository = FirebaseUserRepository(fakeFirestore);
  });

  test('getUser returns user from Firestore', () async {
    // Seed Firestore
    await fakeFirestore.collection('users').doc('123').set({
      'id': '123',
      'name': 'Simon',
      'email': 'simon@test.com',
      'createdAt': Timestamp.now(),
    });
    
    final user = await repository.getUser('123');
    
    expect(user.id, '123');
    expect(user.name, 'Simon');
  });
  
  test('watchUser emits updates', () async {
    // Seed initial data
    await fakeFirestore.collection('users').doc('123').set({
      'id': '123',
      'name': 'Simon',
      'email': 'simon@test.com',
      'createdAt': Timestamp.now(),
    });
    
    final stream = repository.watchUser('123');
    
    expect(
      stream,
      emitsInOrder([
        isA<User>().having((u) => u.name, 'name', 'Simon'),
        isA<User>().having((u) => u.name, 'name', 'Updated'),
      ]),
    );
    
    // Update after stream starts watching
    await Future.delayed(const Duration(milliseconds: 100));
    await fakeFirestore.collection('users').doc('123').update({
      'name': 'Updated',
    });
  });
}
```

## Integration Tests with Real Firebase Emulator

For critical paths only:

```dart
// integration_test/user_flow_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp();
    
    // Use emulators - NO overrides needed, real Firebase SDK
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  });

  testWidgets('complete user registration flow with real Firebase', (tester) async {
    // This uses the REAL Firebase repository implementation
    // but pointed at local emulator
    app.main(); // Your actual app entry point
    await tester.pumpAndSettle();
    
    // Real end-to-end flow
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byKey(Key('email-field')), 'test@example.com');
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    
    expect(find.text('Welcome'), findsOneWidget);
    
    // Verify data actually made it to Firestore emulator
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: 'test@example.com')
        .get();
    
    expect(doc.docs.length, 1);
  });
}
```

## When to Use Each Approach

| Test Type | Implementation | Speed | Fidelity | Use Case |
|-----------|---------------|-------|----------|----------|
| **Widget tests** | `FakeUserRepository` | ⚡ Instant | Medium | Business logic, UI states, user interactions |
| **Repository unit tests** | `fake_cloud_firestore` package | ⚡ Fast | High | Firestore query logic, serialization |
| **Integration tests** | Real Firebase emulators | 🐌 Slow (5-7s startup) | Highest | Critical flows, pre-release smoke tests |

## AI Agent Compatibility

This approach is perfect for AI-driven development:

1. **Fast iteration**: Widget tests run in milliseconds
2. **No external dependencies**: Tests don't need emulators running
3. **Clear terminal output**: Pass/fail is immediate and parseable
4. **Isolated changes**: Can test single widget without whole app

## Key Takeaways

1. **Repository pattern**: Abstract Firebase behind interfaces
2. **Provider overrides**: Riverpod's superpower for testing
3. **In-memory fakes**: Fast, synchronous, deterministic
4. **Widget ignorance**: Widgets never import Firebase packages
5. **Three-tier testing**: Fakes for widgets, `fake_cloud_firestore` for repository logic, emulators for integration
6. **Real Firebase only for integration**: Save the expensive tests for critical paths

This gives you the best of both worlds: blazingly fast unit/widget tests for development velocity, and high-fidelity integration tests for confidence before release.