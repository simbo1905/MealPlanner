import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../providers/user_providers.dart';

class UserEditScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserEditScreen({required this.userId, Key? key}) : super(key: key);

  @override
  ConsumerState<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends ConsumerState<UserEditScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger load on screen mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUser();
    });
  }

  Future<void> _loadUser() async {
    final user =
        await ref.read(fetchUserProvider(widget.userId).future);
    ref.read(userEditStateNotifierProvider.notifier)
        .initializeFromUser(user);
  }

  @override
  Widget build(BuildContext context) {
    final fetchAsync = ref.watch(fetchUserProvider(widget.userId));
    final editedUser = ref.watch(currentEditedUserProvider);
    final age = ref.watch(currentAgeProvider);
    final saveAsync = ref.watch(userSaveNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: _TitlePanel(editedUser: editedUser, age: age),
      ),
      body: fetchAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (_) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _EditPanel(
              editedUser: editedUser,
              age: age,
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BottomButtonPanel(
        onSave: () => _handleSave(editedUser),
        onCancel: () => _handleCancel(),
        isSaving: saveAsync.isLoading,
      ),
    );
  }

  Future<void> _handleSave(User? user) async {
    if (user == null) return;
    await ref.read(userSaveNotifierProvider.notifier).save(user);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved')));
      Navigator.pop(context);
    }
  }

  void _handleCancel() {
    ref.read(userEditStateNotifierProvider.notifier).reset();
    Navigator.pop(context);
  }
}

class _TitlePanel extends ConsumerWidget {
  final User? editedUser;
  final int? age;

  const _TitlePanel({required this.editedUser, required this.age});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(editedUser?.name ?? 'Loading...'),
        if (age != null) Text('Age: $age', style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _EditPanel extends ConsumerWidget {
  final User? editedUser;
  final int? age;

  const _EditPanel({required this.editedUser, required this.age});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (editedUser == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'Name'),
          controller: TextEditingController(text: editedUser!.name),
          onChanged: (value) {
            ref.read(userEditStateNotifierProvider.notifier).updateName(value);
          },
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showDatePicker(context, ref),
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Date of Birth'),
            child: Text(
              editedUser!.dateOfBirth.toString().split(' ')[0],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (age != null)
          Text(
            'Computed Age: $age',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  Future<void> _showDatePicker(BuildContext context, WidgetRef ref) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: editedUser!.dateOfBirth,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(userEditStateNotifierProvider.notifier).updateDateOfBirth(picked);
    }
  }
}

class _BottomButtonPanel extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isSaving;

  const _BottomButtonPanel({
    required this.onSave,
    required this.onCancel,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: isSaving ? null : onCancel,
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
