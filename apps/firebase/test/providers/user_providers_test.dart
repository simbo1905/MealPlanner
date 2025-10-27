import 'package:flutter_test/flutter_test.dart';
import 'package:user_edit_example/models/user.dart';

void main() {
  group('Age calculation', () {
    test('calculates age correctly for birthdate before today in calendar year', () {
      final now = DateTime.now();
      final dob = DateTime(now.year - 25, now.month, now.day - 1);
      
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      
      expect(age, 25);
    });

    test('calculates age correctly for birthdate after today in calendar year', () {
      final now = DateTime.now();
      final dob = DateTime(now.year - 25, now.month, now.day + 1);
      
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      
      expect(age, 24);
    });
  });

  group('User model', () {
    test('User.fromJson roundtrips correctly', () {
      final original = User(
        id: 'user-1',
        name: 'Alice',
        dateOfBirth: DateTime(1990, 6, 15),
      );
      
      final json = original.toJson();
      final reconstructed = User.fromJson(json);
      
      expect(reconstructed, original);
    });
  });
}
