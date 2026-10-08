import 'package:flutter/material.dart';
import '../models/pkl_user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  final PklUser user;
  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: AppColors.maroon),
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu akan kembali ke halaman login.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.maroon),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (shouldLogout == true) widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final initial = user.name.isEmpty ? '?' : user.name[0].toUpperCase();
    final details = switch (user.role) {
      UserRole.admin => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'Username admin',
            value: user.accountId,
          ),
          const _ProfileDetail(
            icon: Icons.admin_panel_settings_outlined,
            label: 'Akses',
            value: 'Kelola akun dan monitoring PKL',
          ),
        ],
      UserRole.guru => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'NIP',
            value: user.accountId,
          ),
          const _ProfileDetail(
            icon: Icons.school_outlined,
            label: 'Sekolah',
            value: 'SMK Negeri 1 Jakarta',
          ),
          const _ProfileDetail(
            icon: Icons.work_outline_rounded,
            label: 'Peran',
            value: 'Guru pembimbing PKL',
          ),
        ],
      UserRole.murid => <Widget>[
          _ProfileDetail(
            icon: Icons.badge_outlined,
            label: 'NISN',
            value: user.accountId,
          ),
          const _ProfileDetail(
            icon: Icons.school_outlined,
            label: 'Sekolah',
            value: 'SMK Negeri 1 Jakarta',
          ),
          const _ProfileDetail(
            icon: Icons.business_outlined,
            label: 'Tempat PKL',
            value: 'PT Aksara Digital Nusantara',
          ),
          const _ProfileDetail(
            icon: Icons.person_outline_rounded,
            label: 'Pembimbing',
            value: 'Ibu Ratna Puspita, S.Kom.',
          ),
        ],
    };

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Profil ${user.role.label}',
            subtitle: 'Informasi akun dan akses PKLJOURNEY.',
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.cream,
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: AppColors.maroon,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        user.role.label,
                        style: TextStyle(
                          color: AppColors.cream,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.verified_rounded,
                  color: AppColors.cream,
                  size: 21,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionLabel('Informasi akun'),
          WhiteCard(
            padding: 0,
            child: Column(children: details),
          ),
          const SizedBox(height: 22),
          const SectionLabel('Pengaturan'),
          WhiteCard(
            padding: 0,
            child: SwitchListTile(
              value: _notificationsEnabled,
              activeColor: AppColors.maroon,
              onChanged: (value) =>
                  setState(() => _notificationsEnabled = value),
              secondary: const CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.cream,
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.maroon,
                  size: 19,
                ),
              ),
              title: const Text(
                'Pengingat kegiatan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              subtitle: const Text(
                'Pengingat presensi dan jurnal',
                style: TextStyle(fontSize: 11),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
            ),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Keluar dari akun'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.maroon,
              side: const BorderSide(color: AppColors.line),
              minimumSize: const Size.fromHeight(49),
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'PKLJOURNEY • Versi demo 1.0.0',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.paper,
            child: Icon(icon, color: AppColors.maroon, size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}