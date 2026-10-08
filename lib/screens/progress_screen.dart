import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const PageHeading(
            title: 'Progres PKL',
            subtitle: 'Lihat sejauh mana kamu sudah melangkah.',
          ),
          Container(
            padding: const EdgeInsets.all(21),
            decoration: BoxDecoration(
              color: AppColors.maroon,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Perjalanan praktikmu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        '50%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: const LinearProgressIndicator(
                    value: 0.5,
                    minHeight: 10,
                    backgroundColor: Color(0xFF8A4242),
                    color: AppColors.cream,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '16 dari 32 hari praktik sudah selesai.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 21),
          const SectionLabel('Pencapaianmu'),
          Row(
            children: const [
              Expanded(
                child: _ProgressMetric(
                  icon: Icons.fact_check_rounded,
                  value: '98%',
                  label: 'Kehadiran',
                  color: AppColors.green,
                  background: AppColors.paleGreen,
                ),
              ),
              SizedBox(width: 11),
              Expanded(
                child: _ProgressMetric(
                  icon: Icons.menu_book_rounded,
                  value: '14',
                  label: 'Jurnal dibuat',
                  color: AppColors.maroon,
                  background: AppColors.cream,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: const [
              Expanded(
                child: _ProgressMetric(
                  icon: Icons.stars_rounded,
                  value: '4.7 / 5',
                  label: 'Nilai pembimbing',
                  color: AppColors.amber,
                  background: AppColors.paleAmber,
                ),
              ),
              SizedBox(width: 11),
              Expanded(
                child: _ProgressMetric(
                  icon: Icons.emoji_events_rounded,
                  value: '3 / 4',
                  label: 'Target tercapai',
                  color: AppColors.maroon,
                  background: AppColors.cream,
                ),
              ),
            ],
          ),
          const SizedBox(height: 23),
          const SectionLabel('Tahapan PKL'),
          const WhiteCard(
            padding: 18,
            child: Column(
              children: [
                _MilestoneRow(
                  title: 'Persiapan & orientasi',
                  detail: 'Pengenalan tempat praktik dan tim',
                  complete: true,
                  last: false,
                ),
                _MilestoneRow(
                  title: 'Adaptasi lingkungan kerja',
                  detail: 'Belajar alur kerja dan peralatan',
                  complete: true,
                  last: false,
                ),
                _MilestoneRow(
                  title: 'Praktik & pengembangan',
                  detail: 'Sedang berlangsung • Minggu ke-3',
                  active: true,
                  last: false,
                ),
                _MilestoneRow(
                  title: 'Evaluasi & penutupan',
                  detail: 'Rangkuman pengalaman PKL',
                  last: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 21),
          const SectionLabel('Target kompetensi'),
          const WhiteCard(
            child: Column(
              children: [
                _CompetencyRow(
                  title: 'Kolaborasi dalam tim',
                  progress: 1,
                  complete: true,
                ),
                SizedBox(height: 17),
                _CompetencyRow(
                  title: 'Dasar pengembangan web',
                  progress: 0.72,
                  active: true,
                ),
                SizedBox(height: 17),
                _CompetencyRow(
                  title: 'Komunikasi profesional',
                  progress: 0.48,
                  active: true,
                ),
                SizedBox(height: 17),
                _CompetencyRow(
                  title: 'Dokumentasi proyek',
                  progress: 0.22,
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Nilai dan target kompetensi merupakan data contoh.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return WhiteCard(
      padding: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.title,
    required this.detail,
    this.complete = false,
    this.active = false,
    this.last = false,
  });

  final String title;
  final String detail;
  final bool complete;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = complete
        ? AppColors.green
        : active
            ? AppColors.maroon
            : AppColors.line;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: complete
                        ? AppColors.paleGreen
                        : active
                            ? AppColors.cream
                            : AppColors.paper,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 1.5),
                  ),
                  child: Icon(
                    complete
                        ? Icons.check_rounded
                        : active
                            ? Icons.circle
                            : Icons.circle_outlined,
                    color: color,
                    size: complete ? 14 : 9,
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: complete ? AppColors.green : AppColors.line,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 19),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: active ? AppColors.maroon : AppColors.ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(detail, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompetencyRow extends StatelessWidget {
  const _CompetencyRow({
    required this.title,
    required this.progress,
    this.complete = false,
    this.active = false,
  });

  final String title;
  final double progress;
  final bool complete;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = complete ? AppColors.green : AppColors.maroon;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: AppColors.cream,
            color: color,
          ),
        ),
        if (complete || active)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                complete ? 'Target tercapai' : 'Sedang dikembangkan',
                style: TextStyle(
                  color: complete ? AppColors.green : AppColors.muted,
                  fontSize: 9,
                ),
              ),
            ),
          ),
      ],
    );
  }
}