import 'package:flutter/material.dart';
import '../models/pkl_user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({
    super.key,
    required this.user,
    required this.users,
    required this.pendingJournalCount,
    required this.onOpenStudents,
    required this.onOpenReviews,
    required this.onOpenAttendance,
  });

  final PklUser user;
  final List<PklUser> users;
  final int pendingJournalCount;
  final VoidCallback onOpenStudents;
  final VoidCallback onOpenReviews;
  final VoidCallback onOpenAttendance;

  @override
  Widget build(BuildContext context) {
    final studentCount =
        users
            .where(
              (account) =>
                  account.role == UserRole.murid &&
                  account.mentorAccountId == user.accountId,
            )
            .length;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const Row(
            children: [
              BrandMark(compact: true),
              Spacer(),
              InfoPill(
                label: 'GURU PEMBIMBING',
                color: AppColors.paleGreen,
                textColor: AppColors.green,
                icon: Icons.person_pin_outlined,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(23),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RUANG PEMBIMBING',
                  style: TextStyle(
                    color: AppColors.cream.withOpacity(0.8),
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  'Halo, ${user.name.split(' ').first}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pantau perkembangan siswa dan beri arahan untuk langkah berikutnya.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _TeacherMetric(
                        value: '$studentCount',
                        label: 'Murid dibimbing',
                        icon: Icons.school_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TeacherMetric(
                        value: '$pendingJournalCount',
                        label: 'Jurnal menunggu',
                        icon: Icons.rate_review_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionLabel('Akses cepat'),
          WhiteCard(
            padding: 0,
            child: Column(
              children: [
                _TeacherAction(
                  icon: Icons.groups_2_outlined,
                  color: AppColors.maroon,
                  title: 'Daftar murid bimbingan',
                  subtitle: '$studentCount akun murid terdaftar',
                  onTap: onOpenStudents,
                ),
                const Divider(height: 1, indent: 66, endIndent: 15),
                _TeacherAction(
                  icon: Icons.menu_book_outlined,
                  color: AppColors.amber,
                  title: 'Tinjau jurnal kegiatan',
                  subtitle: 'Periksa catatan dan beri tindak lanjut',
                  onTap: onOpenReviews,
                ),
                const Divider(height: 1, indent: 66, endIndent: 15),
                _TeacherAction(
                  icon: Icons.fact_check_outlined,
                  color: AppColors.green,
                  title: 'Riwayat kehadiran',
                  subtitle: 'Lihat presensi murid bimbingan',
                  onTap: onOpenAttendance,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SectionLabel(
            'Murid terbaru',
            action: 'Lihat semua',
            onAction: onOpenStudents,
          ),
          ...users
              .where(
                (account) =>
                    account.role == UserRole.murid &&
                    account.mentorAccountId == user.accountId,
              )
              .take(3)
              .map(
                (student) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: WhiteCard(
                    padding: 14,
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 21,
                          backgroundColor: AppColors.cream,
                          child: Icon(
                            Icons.school_outlined,
                            color: AppColors.maroon,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
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
                                'NISN ${student.accountId}',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const InfoPill(
                          label: 'Aktif',
                          color: AppColors.paleGreen,
                          textColor: AppColors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 5),
          const Text(
            'Status jurnal dan presensi pada ringkasan merupakan data contoh.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _TeacherMetric extends StatelessWidget {
  const _TeacherMetric({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.11),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.cream, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 9,
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

class _TeacherAction extends StatelessWidget {
  const _TeacherAction({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.muted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}