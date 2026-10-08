import 'package:flutter/material.dart';
import '../models/pkl_user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AdminAccountsScreen extends StatelessWidget {
  const AdminAccountsScreen({
    super.key,
    required this.currentAdmin,
    required this.users,
    required this.onRegisterAccount,
    required this.onDeleteAccount,
  });

  final PklUser currentAdmin;
  final List<PklUser> users;
  final ValueChanged<PklUser> onRegisterAccount;
  final ValueChanged<PklUser> onDeleteAccount;

  Future<void> _confirmDelete(BuildContext context, PklUser account) async {
    final assignedStudents = account.role == UserRole.guru
        ? users
            .where(
              (user) =>
                  user.role == UserRole.murid &&
                  user.mentorAccountId == account.accountId,
            )
            .length
        : 0;
    final detail = assignedStudents > 0
        ? '\n\n$assignedStudents murid bimbingan akan dilepas dari guru ini. Akun murid tidak akan dihapus.'
        : '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus akun?'),
        content: Text(
          'Akun ${account.name} (${account.role.label}) akan dihapus.$detail',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus akun'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    onDeleteAccount(account);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Akun ${account.name} berhasil dihapus.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openRegistrationForm(BuildContext context) async {
    final account = await showModalBottomSheet<PklUser>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _RegistrationForm(),
    );
    if (account == null) return;

    final duplicate = users.any(
      (existing) =>
          existing.role == account.role &&
          (existing.username.toLowerCase() == account.username.toLowerCase() ||
              existing.accountId.toLowerCase() ==
                  account.accountId.toLowerCase()),
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${account.role.accountIdLabel} tersebut sudah terdaftar.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    onRegisterAccount(account);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Akun ${account.role.label.toLowerCase()} berhasil didaftarkan.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Kelola akun',
            subtitle: 'Daftarkan akun guru dan murid PKL.',
            trailing: IconButton.filled(
              onPressed: () => _openRegistrationForm(context),
              tooltip: 'Tambah akun',
              icon: const Icon(Icons.person_add_alt_1_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.maroon,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.paleAmber,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(color: AppColors.cream),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.amber),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Username guru adalah NIP. Username murid adalah NISN. Akun baru bisa langsung dipakai untuk login demo.',
                    style: TextStyle(
                      color: AppColors.taupe,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _CountBox(
                  title: 'Guru',
                  count: users.where((u) => u.role == UserRole.guru).length,
                  icon: Icons.person_pin_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CountBox(
                  title: 'Murid',
                  count: users.where((u) => u.role == UserRole.murid).length,
                  icon: Icons.school_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SectionLabel('Daftar pengguna', action: '${users.length} akun'),
          ...users.map(
            (account) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AccountTile(
                account: account,
                onDelete: account.role == currentAdmin.role &&
                        account.accountId == currentAdmin.accountId
                    ? null
                    : () => _confirmDelete(context, account),
              ),
            ),
          ),
          const SizedBox(height: 5),
          OutlinedButton.icon(
            onPressed: () => _openRegistrationForm(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Daftarkan akun baru'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.maroon,
              side: const BorderSide(color: AppColors.maroon),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Akun baru dan kata sandi disimpan sementara di memori aplikasi demo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _CountBox extends StatelessWidget {
  const _CountBox({
    required this.title,
    required this.count,
    required this.icon,
  });

  final String title;
  final int count;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: 15,
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.cream,
            child: Icon(icon, color: AppColors.maroon, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                title,
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({required this.account, this.onDelete});

  final PklUser account;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = switch (account.role) {
      UserRole.admin => AppColors.maroon,
      UserRole.guru => AppColors.green,
      UserRole.murid => AppColors.amber,
    };
    final icon = switch (account.role) {
      UserRole.admin => Icons.admin_panel_settings_outlined,
      UserRole.guru => Icons.person_pin_outlined,
      UserRole.murid => Icons.school_outlined,
    };
    return WhiteCard(
      padding: 14,
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${account.role.accountIdLabel}: ${account.accountId}',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          InfoPill(
            label: account.role.label,
            color: color.withOpacity(0.1),
            textColor: color,
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 2),
            IconButton(
              onPressed: onDelete,
              tooltip: 'Hapus akun',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.delete_outline_rounded),
              color: AppColors.maroon,
            ),
          ],
        ],
      ),
    );
  }
}

class _RegistrationForm extends StatefulWidget {
  const _RegistrationForm();

  @override
  State<_RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<_RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.murid;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final identifier = _identifierController.text.trim();
    Navigator.of(context).pop(
      PklUser(
        username: identifier,
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _role,
        accountId: identifier,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Daftarkan akun',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 5),
                const Text('Akun demo bisa langsung digunakan untuk login.'),
                const SizedBox(height: 18),
                const _RegistrationLabel('JENIS AKUN'),
                const SizedBox(height: 7),
                DropdownButtonFormField<UserRole>(
                  value: _role,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.switch_account_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: UserRole.murid,
                      child: Text('Murid'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.guru,
                      child: Text('Guru'),
                    ),
                  ],
                  onChanged: (role) {
                    if (role != null) setState(() => _role = role);
                  },
                ),
                const SizedBox(height: 13),
                const _RegistrationLabel('NAMA LENGKAP'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan nama lengkap',
                  ),
                  validator: (value) =>
                      value == null || value.trim().length < 3
                          ? 'Nama lengkap wajib diisi'
                          : null,
                ),
                const SizedBox(height: 13),
                _RegistrationLabel(_role.accountIdLabel.toUpperCase()),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _identifierController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: _role == UserRole.murid
                        ? 'Masukkan 10 digit NISN'
                        : 'Masukkan NIP guru',
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    final id = value?.trim() ?? '';
                    if (id.isEmpty) return '${_role.accountIdLabel} wajib diisi';
                    if (!RegExp(r'^\d+$').hasMatch(id)) {
                      return '${_role.accountIdLabel} harus berupa angka';
                    }
                    if (_role == UserRole.murid && id.length != 10) {
                      return 'NISN harus terdiri dari 10 digit';
                    }
                    if (_role == UserRole.guru && id.length < 8) {
                      return 'Masukkan NIP yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 13),
                const _RegistrationLabel('KATA SANDI AWAL'),
                const SizedBox(height: 7),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Buat kata sandi untuk akun ini',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.length < 4
                          ? 'Kata sandi minimal 4 karakter'
                          : null,
                ),
                const SizedBox(height: 17),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Daftarkan akun'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RegistrationLabel extends StatelessWidget {
  const _RegistrationLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.taupe,
          fontSize: 10,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w800,
        ),
      );
}