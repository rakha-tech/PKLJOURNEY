import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import '../models/internship_location.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({
    super.key,
    required this.hasCheckedIn,
    required this.hasCheckedOut,
    required this.checkInTime,
    required this.checkOutTime,
    required this.onAttendanceAction,
    required this.records,
    required this.workplaceLocation,
  });

  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final String? checkInTime;
  final String? checkOutTime;
  final VoidCallback onAttendanceAction;
  final List<AttendanceRecord> records;
  final InternshipLocation? workplaceLocation;

  @override
  Widget build(BuildContext context) {
    final isComplete = hasCheckedIn && hasCheckedOut;
    final statusLabel = isComplete
        ? 'Presensi lengkap'
        : hasCheckedIn
            ? 'Sedang praktik'
            : 'Belum presensi';
    final statusColor = isComplete
        ? AppColors.green
        : hasCheckedIn
            ? AppColors.amber
            : AppColors.maroon;
    final actionLabel = isComplete
        ? 'Presensi hari ini selesai'
        : hasCheckedIn
            ? 'Catat presensi pulang'
            : 'Catat presensi masuk';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Presensi',
            subtitle: 'Catat kehadiran PKL-mu hari ini.',
            trailing: InfoPill(
              label: statusLabel,
              color: isComplete
                  ? AppColors.paleGreen
                  : hasCheckedIn
                      ? AppColors.paleAmber
                      : AppColors.cream,
              textColor: statusColor,
              icon: isComplete
                  ? Icons.check_circle_outline_rounded
                  : Icons.schedule_rounded,
            ),
          ),
          WhiteCard(
            padding: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 23,
                      backgroundColor: AppColors.cream,
                      child: Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.maroon,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentDateLabel(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Jam kerja 08.00 – 16.00',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TimeBlock(
                          label: 'MASUK',
                          time: checkInTime ?? '--.--',
                          complete: hasCheckedIn,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 44,
                        color: AppColors.line,
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                      ),
                      Expanded(
                        child: _TimeBlock(
                          label: 'PULANG',
                          time: checkOutTime ?? '--.--',
                          complete: hasCheckedOut,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 17),
                ElevatedButton.icon(
                  onPressed: isComplete ? null : onAttendanceAction,
                  icon: Icon(
                    isComplete
                        ? Icons.check_circle_rounded
                        : hasCheckedIn
                            ? Icons.logout_rounded
                            : Icons.login_rounded,
                  ),
                  label: Text(actionLabel),
                  style: isComplete
                      ? ElevatedButton.styleFrom(
                          disabledBackgroundColor: AppColors.paleGreen,
                          disabledForegroundColor: AppColors.green,
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pastikan kamu berada di tempat praktik saat mencatat kehadiran.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(height: 21),
          const SectionLabel('Lokasi praktik'),
          WhiteCard(
            padding: 15,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 21,
                  backgroundColor: AppColors.paleGreen,
                  child: Icon(
                    Icons.business_outlined,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workplaceLocation?.companyName ??
                            'Lokasi PKL belum ditetapkan',
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        workplaceLocation?.address ??
                            'Hubungi guru pembimbing untuk informasi lokasi.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 21),
          SectionLabel(
            'Riwayat presensi',
            action: '${records.length} hari',
          ),
          WhiteCard(
            padding: records.isEmpty ? 16 : 0,
            child: records.isEmpty
                ? const Text(
                    'Belum ada riwayat presensi. Catat presensi masuk untuk memulai.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, height: 1.5),
                  )
                : Column(
                    children: [
                      for (var index = 0;
                          index < records.length && index < 7;
                          index++) ...[
                        if (index > 0)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                        _AttendanceHistoryRow(record: records[index]),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.label,
    required this.time,
    required this.complete,
  });

  final String label;
  final String time;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 9,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              time,
              style: TextStyle(
                color: complete ? AppColors.ink : AppColors.muted,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (complete) ...[
              const SizedBox(width: 5),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.green,
                size: 15,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _AttendanceHistoryRow extends StatelessWidget {
  const _AttendanceHistoryRow({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final complete = record.checkInTime != null && record.checkOutTime != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.shortWeekday.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  record.shortDate,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _TimeBlock(
            label: 'Masuk',
            time: record.checkInTime ?? '--.--',
            complete: record.checkInTime != null,
          ),
          const SizedBox(width: 18),
          _TimeBlock(
            label: 'Pulang',
            time: record.checkOutTime ?? '--.--',
            complete: record.checkOutTime != null,
          ),
          const SizedBox(width: 7),
          Icon(
            complete ? Icons.check_circle_rounded : Icons.more_horiz_rounded,
            color: complete ? AppColors.green : AppColors.amber,
            size: 17,
          ),
        ],
      ),
    );
  }
}