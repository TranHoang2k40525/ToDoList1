import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../todo/presentation/pages/todo_page.dart';
import '../providers/auth_notifier.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _accountCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _registerUserCtrl = TextEditingController();
  final _registerFullNameCtrl = TextEditingController();
  final _registerEmailCtrl = TextEditingController();
  final _registerPasswordCtrl = TextEditingController();
  bool _registerMode = false;
  bool _obscureLogin = true;
  bool _obscureRegister = true;

  @override
  void dispose() {
    _accountCtrl.dispose();
    _passwordCtrl.dispose();
    _registerUserCtrl.dispose();
    _registerFullNameCtrl.dispose();
    _registerEmailCtrl.dispose();
    _registerPasswordCtrl.dispose();
    super.dispose();
  }

  Widget _liquidBackdrop({required Widget child}) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD6ECFF), Color(0xFFF8FCFF), Color(0xFFE2F5FF)],
            ),
          ),
        ),
        Positioned(
          left: -40,
          top: -60,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF81D4FF).withValues(alpha: 0.45),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF81D4FF).withValues(alpha: 0.45),
                  blurRadius: 60,
                  spreadRadius: 10,
                )
              ],
            ),
          ),
        ),
        Positioned(
          right: -20,
          bottom: 80,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFAEE3FF).withValues(alpha: 0.5),
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _liquidBackdrop(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.lightBlue.withValues(alpha: 0.2),
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                child: Column(
                  key: ValueKey(_registerMode),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0EA5E9).withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.water_drop_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _registerMode ? 'Create Account' : 'Welcome Back',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(value: false, label: Text('Login')),
                        ButtonSegment<bool>(value: true, label: Text('Register')),
                      ],
                      selected: {_registerMode},
                      style: ButtonStyle(
                        visualDensity: VisualDensity.standard,
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                      ),
                      onSelectionChanged: (next) {
                        setState(() => _registerMode = next.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    if (!_registerMode) ...[
                      TextField(
                        controller: _accountCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email or username',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscureLogin,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscureLogin = !_obscureLogin),
                            icon: Icon(
                              _obscureLogin ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: state.loading
                            ? null
                            : () async {
                                final navigator = Navigator.of(context);
                                final ok = await ref.read(authNotifierProvider.notifier).login(
                                      account: _accountCtrl.text.trim(),
                                      password: _passwordCtrl.text,
                                    );
                                if (!mounted || !ok) {
                                  return;
                                }
                                navigator.pushReplacement(
                                  MaterialPageRoute(builder: (_) => const TodoPage()),
                                );
                              },
                        icon: state.loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.login_rounded),
                        label: const Text('Login now'),
                      ),
                    ] else ...[
                      TextField(
                        controller: _registerUserCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.alternate_email_rounded),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _registerFullNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _registerEmailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _registerPasswordCtrl,
                        obscureText: _obscureRegister,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscureRegister = !_obscureRegister),
                            icon: Icon(
                              _obscureRegister ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: state.loading
                            ? null
                            : () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final ok = await ref.read(authNotifierProvider.notifier).register(
                                      userName: _registerUserCtrl.text.trim(),
                                      email: _registerEmailCtrl.text.trim(),
                                      password: _registerPasswordCtrl.text,
                                      fullName: _registerFullNameCtrl.text.trim(),
                                    );
                                if (!mounted) {
                                  return;
                                }
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok
                                          ? 'Register success. Please login.'
                                          : (state.error ?? 'Register failed'),
                                    ),
                                  ),
                                );
                                if (ok) {
                                  setState(() => _registerMode = false);
                                }
                              },
                        icon: state.loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Create account'),
                      ),
                    ],
                    if (state.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
