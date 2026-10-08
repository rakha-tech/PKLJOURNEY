import 'package:flutter/material.dart';
import '../models/internship_location.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.studentName,
    required this.hasCheckedIn,
    required this.hasCheckedOut,
    required this.checkInTime,
    required this.checkOutTime,
    required this.journalCount,
    required this.workplaceLocation,
    required this.onOpenAttendance,
    required this.onOpenJournal,
    required this.onOpenProgress,
  });

  final String studentName;
  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final String? checkInTime;
  final String? checkOutTime;
  final int journalCount;
  final InternshipLocation? workplaceLocation;
  final VoidCallback onOpenAttendance;
  final VoidCallback onOpenJournal;
  final VoidCallback onOpenProgress;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: [
              const BrandMark(compact: true),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [AppColors.maroon, AppColors.maroonDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -2,
                  top: 5,
                  child: Icon(
                    Icons.auto_graph_rounded,
                    color: Colors.white.withOpacity(0.09),
                    size: 96,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentDateLabel().toUpperCase(),
                      style: TextStyle(
                        color: AppColors.cream.withOpacity(0.8),
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Halo, ${studentName.split(' ').first}!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Satu langkah kecil hari ini, pengalaman besar untuk masa depan.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.79),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 17),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.cream,
                          child: Icon(
                            Icons.school_rounded,
                            color: AppColors.maroon,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 9),
                        const Expanded(
                          child: Text(
                            'XI RPL 2  •  Siswa PKL',
                            style: TextStyle(
                              color: AppColors.cream,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        InfoPill(
                          label: 'AKTIF',
                          color: Colors.white.withOpacity(0.16),
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 23),
          const SectionLabel('Ringkasan PKL'),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  icon: Icons.calendar_month_rounded,
                  value: '16 / 32',
                  label: 'Hari berjalan',
                  accent: AppColors.maroon,
                  onTap: onOpenAttendance,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.fact_check_rounded,
                  value: '98%',
                  label: 'Kehadiran',
                  accent: AppColors.green,
                  onTap: onOpenAttendance,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: _SummaryCard(
                  icon: Icons.edit_note_rounded,
                  value: '$journalCount',
                  label: 'Jurnal',
                  accent: AppColors.amber,
                  onTap: onOpenJournal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          const SectionLabel('Aksi hari ini'),
          WhiteCard(
            padding: 0,
            child: Column(
              children: [
                _ActionRow(
                  icon: Icons.location_on_outlined,
                  iconColor: AppColors.maroon,
                  iconBg: AppColors.cream,
                  title: 'Presensi PKL',
                  subtitle: hasCheckedIn
                      ? 'Sudah masuk pukul ${checkInTime ?? '--:--'}'
                      : 'Catat kehadiranmu hari ini',
                  trailing: Icon(
                    hasCheckedIn
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: hasCheckedIn ? 19 : 15,
                    color: hasCheckedIn ? AppColors.green : AppColors.muted,
                  ),
                  onTap: onOpenAttendance,
                ),
                const Divider(height: 1, indent: 68, endIndent: 16),
                _ActionRow(
                  icon: Icons.menu_book_rounded,
                  iconColor: AppColors.amber,
                  iconBg: AppColors.paleAmber,
                  title: 'Tulis jurnal kegiatan',
                  subtitle: 'Ceritakan hal yang kamu pelajari',
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: AppColors.muted,
                  ),
                  onTap: onOpenJournal,
                ),
              ],
            ),
          ),
          const SizedBox(height: 23),
          SectionLabel(
            'Perjalananmu',
            action: 'Lihat progres',
            onAction: onOpenProgress,
          ),
          WhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Minggu ke-3 dari 6',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const Text(
                      '50%',
                      style: TextStyle(
                        color: AppColors.maroon,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const LinearProgressIndicator(
                    value: 0.5,
                    minHeight: 9,
                    backgroundColor: AppColors.cream,
                    color: AppColors.maroon,
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  hasCheckedOut
                      ? 'Presensimu hari ini sudah lengkap. Terus pertahankan!'
                      : 'Konsisten sedikit demi sedikit. Kamu sudah di tengah perjalanan!',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          WhiteCard(
            padding: 15,
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.paleGreen,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.business_center_outlined,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tempat praktik',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        workplaceLocation?.companyName ??
                            'Lokasi PKL belum ditetapkan',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        workplaceLocation?.address ??
                            'Hubungi guru pembimbing untuk informasi lokasi.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (workplaceLocation != null)
                  const Icon(
                    Icons.verified_rounded,
                    color: AppColors.green,
                    size: 19,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: WhiteCard(
        padding: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 20),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.muted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final Widget trailing;
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
              backgroundColor: iconBg,
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}