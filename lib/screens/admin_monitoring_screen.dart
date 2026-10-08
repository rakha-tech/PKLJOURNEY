import 'package:flutter/material.dart';
import '../models/pkl_user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AdminMonitoringScreen extends StatelessWidget {
  const AdminMonitoringScreen({super.key, required this.users});

  final List<PklUser> users;

  @override
  Widget build(BuildContext context) {
    final students =
        users.where((account) => account.role == UserRole.murid).toList();
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const PageHeading(
            title: 'Monitoring PKL',
            subtitle: 'Ringkasan aktivitas seluruh murid.',
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: _MonitoringMetric(
                    label: 'Kehadiran hari ini',
                    value: '92%',
                    icon: Icons.fact_check_outlined,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _MonitoringMetric(
                    label: 'Jurnal menunggu',
                    value: '8',
                    icon: Icons.menu_book_outlined,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 21),
          SectionLabel('Status murid', action: '${students.length} akun'),
          if (students.isEmpty)
            const WhiteCard(
              child: Text(
                'Belum ada murid yang didaftarkan. Tambahkan akun murid melalui menu Akun.',
                textAlign: TextAlign.center,
              ),
            )
          else
            ...students.asMap().entries.map(
              (entry) {
                final student = entry.value;
                final attendance = ['Hadir', 'Hadir', 'Belum presensi'][
                    entry.key % 3];
                final isPresent = attendance == 'Hadir';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: WhiteCard(
                    padding: 14,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 21,
                          backgroundColor: AppColors.cream,
                          child: Text(
                            student.name.isEmpty
                                ? '?'
                                : student.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.maroon,
                              fontWeight: FontWeight.w800,
                            ),
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
                        InfoPill(
                          label: attendance,
                          color: isPresent
                              ? AppColors.paleGreen
                              : AppColors.paleAmber,
                          textColor:
                              isPresent ? AppColors.green : AppColors.amber,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 8),
          const Text(
            'Data monitoring pada halaman ini merupakan data contoh.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MonitoringMetric extends StatelessWidget {
  const _MonitoringMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.11),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.cream, size: 19),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}