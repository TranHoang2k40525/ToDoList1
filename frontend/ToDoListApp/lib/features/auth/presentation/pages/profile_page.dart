import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_notifier.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _fullNameCtrl = TextEditingController();
  final _avatarCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authNotifierProvider.notifier).refreshProfile());
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _avatarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);
    final profile = state.profile;

    if (profile != null && _fullNameCtrl.text.isEmpty) {
      _fullNameCtrl.text = profile.fullName;
      _avatarCtrl.text = profile.avatarUrl ?? '';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${profile?.userName ?? ''}'),
            Text('Email: ${profile?.email ?? ''}'),
            const SizedBox(height: 12),
            TextField(
              controller: _fullNameCtrl,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _avatarCtrl,
              decoration: const InputDecoration(labelText: 'Avatar URL'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final ok = await ref.read(authNotifierProvider.notifier).updateProfile(
                      fullName: _fullNameCtrl.text.trim(),
                      avatarUrl: _avatarCtrl.text.trim(),
                    );
                if (!mounted) return;
                messenger.showSnackBar(
                  SnackBar(content: Text(ok ? 'Profile updated' : 'Update failed')),
                );
              },
              child: const Text('Save profile'),
            )
          ],
        ),
      ),
    );
  }
}
