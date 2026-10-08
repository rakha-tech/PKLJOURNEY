import 'package:flutter/material.dart';
import '../models/pkl_user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.users,
    required this.onLogin,
  });

  final List<PklUser> users;
  final ValueChanged<PklUser> onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;
  UserRole _selectedRole = UserRole.murid;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      PklUser? matchedUser;
      for (final user in widget.users) {
        if (user.role == _selectedRole &&
            (user.username.toLowerCase() ==
                    _usernameController.text.trim().toLowerCase() ||
                user.accountId.toLowerCase() ==
                    _usernameController.text.trim().toLowerCase()) &&
            user.password == _passwordController.text) {
          matchedUser = user;
          break;
        }
      }

      if (matchedUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Role, username, atau kata sandi tidak sesuai.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      widget.onLogin(matchedUser);
    }
  }

  void _showForgotPassword() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.lock_reset_rounded, color: AppColors.maroon),
        title: const Text('Lupa kata sandi?'),
        content: const Text(
          'Hubungi admin sekolah untuk mendaftarkan akun atau meminta bantuan reset kata sandi PKLJOURNEY.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.maroon,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(26, 24, 26, 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      const BrandMark(light: true, showWordmark: false),
                      const SizedBox(height: 13),
                      Text(
                        'LANGKAH PERTAMAMU',
                        style: TextStyle(
                          color: AppColors.cream.withOpacity(0.72),
                          fontSize: 10,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                        decoration: BoxDecoration(
                          color: AppColors.cream,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat datang',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontSize: 23),
                              ),
                              const SizedBox(height: 7),
                              const Text(
                                'Masuk dan lanjutkan perjalanan PKL-mu.',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const _FieldLabel('MASUK SEBAGAI'),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<UserRole>(
                                value: _selectedRole,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.switch_account_outlined),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: UserRole.admin,
                                    child: Text('Admin'),
                                  ),
                                  DropdownMenuItem(
                                    value: UserRole.guru,
                                    child: Text('Guru'),
                                  ),
                                  DropdownMenuItem(
                                    value: UserRole.murid,
                                    child: Text('Murid'),
                                  ),
                                ],
                                onChanged: (role) {
                                  if (role != null) {
                                    setState(() => _selectedRole = role);
                                  }
                                },
                              ),
                              const SizedBox(height: 17),
                              _FieldLabel(_selectedRole.loginLabel),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: switch (_selectedRole) {
                                    UserRole.admin => 'Contoh: admin',
                                    UserRole.guru =>
                                      'Contoh: guru atau NIP dari admin',
                                    UserRole.murid =>
                                      'Contoh: murid atau NISN dari admin',
                                  },
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Masukkan username kamu'
                                        : null,
                              ),
                              const SizedBox(height: 19),
                              const _FieldLabel('PASSWORD'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan kata sandi akun',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: _obscurePassword
                                        ? 'Tampilkan kata sandi'
                                        : 'Sembunyikan kata sandi',
                                    onPressed: () => setState(
                                      () => _obscurePassword =
                                          !_obscurePassword,
                                    ),
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                        ? 'Masukkan kata sandi'
                                        : null,
                              ),
                              const SizedBox(height: 9),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppColors.maroon,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (value) => setState(
                                      () => _rememberMe = value ?? false,
                                    ),
                                  ),
                                  const Text(
                                    'Ingat saya',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: _showForgotPassword,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.maroon,
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Text('Lupa password?'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              ElevatedButton.icon(
                                onPressed: _submit,
                                icon: const Icon(Icons.login_rounded, size: 19),
                                label: const Text('Masuk'),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  'Akun demo: ${_demoUsername(_selectedRole)} / ${_demoUsername(_selectedRole)}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.muted.withOpacity(0.9),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Center(
                                child: Text(
                                  'Akun guru dan murid baru didaftarkan oleh Admin menggunakan NIP atau NISN.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 10,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'PKLJOURNEY  •  BELAJAR, BERTUMBUH, BERKARYA',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.cream.withOpacity(0.68),
                          fontSize: 9,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _demoUsername(UserRole role) => switch (role) {
        UserRole.admin => 'admin',
        UserRole.guru => 'guru',
        UserRole.murid => 'murid',
      };
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.taupe,
        fontSize: 11,
        letterSpacing: 0.8,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}