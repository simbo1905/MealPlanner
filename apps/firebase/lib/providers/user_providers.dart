import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

part 'user_providers.g.dart';

// Fetch user from Firestore (with offline support built into Firebase SDK)
@riverpod
Future<User> fetchUser(FetchUserRef ref, String userId) async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();
  
  if (!doc.exists) {
    throw Exception('User not found');
  }
  
  final data = doc.data()!;
  return User.fromJson(data);
}

// Edit state: holds uncommitted changes
class UserEditState {
  final User original;
  final String nameEdit;
  final DateTime dateOfBirthEdit;
  
  UserEditState({
    required this.original,
    required this.nameEdit,
    required this.dateOfBirthEdit,
  });
  
  UserEditState copyWith({
    String? nameEdit,
    DateTime? dateOfBirthEdit,
  }) =>
    UserEditState(
      original: original,
      nameEdit: nameEdit ?? this.nameEdit,
      dateOfBirthEdit: dateOfBirthEdit ?? this.dateOfBirthEdit,
    );
}

// Mutable provider for edit-in-progress state
@riverpod
class UserEditStateNotifier extends _$UserEditStateNotifier {
  @override
  UserEditState? build() => null;

  void initializeFromUser(User user) {
    state = UserEditState(
      original: user,
      nameEdit: user.name,
      dateOfBirthEdit: user.dateOfBirth,
    );
  }

  void updateName(String name) {
    if (state != null) {
      state = state!.copyWith(nameEdit: name);
    }
  }

  void updateDateOfBirth(DateTime dob) {
    if (state != null) {
      state = state!.copyWith(dateOfBirthEdit: dob);
    }
  }

  void reset() {
    state = null;
  }
}

// Computed: current edited user
@riverpod
User? currentEditedUser(CurrentEditedUserRef ref) {
  final editState = ref.watch(userEditStateNotifierProvider);
  if (editState == null) return null;
  
  return User(
    id: editState.original.id,
    name: editState.nameEdit,
    dateOfBirth: editState.dateOfBirthEdit,
  );
}

// Computed: age from current DoB
@riverpod
int? currentAge(CurrentAgeRef ref) {
  final user = ref.watch(currentEditedUserProvider);
  if (user == null) return null;
  
  final now = DateTime.now();
  int age = now.year - user.dateOfBirth.year;
  if (now.month < user.dateOfBirth.month ||
      (now.month == user.dateOfBirth.month && now.day < user.dateOfBirth.day)) {
    age--;
  }
  return age;
}

// Save to Firestore
@riverpod
class UserSaveNotifier extends _$UserSaveNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> save(User user) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .set(
            user.toJson(),
            SetOptions(merge: true),
          );
      // Clear edit state after successful save
      ref.read(userEditStateNotifierProvider.notifier).reset();
    });
  }
}
