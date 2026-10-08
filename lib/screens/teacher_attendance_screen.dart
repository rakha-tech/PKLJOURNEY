import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import '../models/pkl_user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class TeacherAttendanceScreen extends StatelessWidget {
  const TeacherAttendanceScreen({
    super.key,
    required this.students,
    required this.attendanceRecords,
  });

  final List<PklUser> students;
  final Map<String, List<AttendanceRecord>> attendanceRecords;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Riwayat kehadiran',
            subtitle: 'Presensi murid yang menjadi tanggung jawab Anda.',
            trailing: InfoPill(
              label: '${students.length} murid',
              color: AppColors.cream,
              textColor: AppColors.maroon,
              icon: Icons.groups_2_outlined,
            ),
          ),
          if (students.isEmpty)
            const WhiteCard(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Icon(
                      Icons.fact_check_outlined,
                      color: AppColors.maroon,
                      size: 38,
                    ),
                    SizedBox(height: 11),
                    Text(
                      'Belum ada murid bimbingan',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Tambahkan atau tautkan murid terlebih dahulu untuk melihat riwayat kehadirannya.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...students.map((student) {
              final records = List<AttendanceRecord>.of(
                attendanceRecords[student.accountId] ?? const [],
              )..sort((a, b) => b.date.compareTo(a.date));
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: WhiteCard(
                  padding: 0,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
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
                            const SizedBox(width: 10),
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
                                  const SizedBox(height: 3),
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
                              label: '${records.length} hari',
                              color: AppColors.paleGreen,
                              textColor: AppColors.green,
                              icon: Icons.calendar_month_outlined,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, indent: 15, endIndent: 15),
                      if (records.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(15),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Belum ada riwayat presensi.',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )
                      else
                        ...records.take(10).map(
                              (record) => _StudentAttendanceRow(record: record),
                            ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _StudentAttendanceRow extends StatelessWidget {
  const _StudentAttendanceRow({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final isComplete =
        record.checkInTime != null && record.checkOutTime != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 76,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.shortWeekday,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
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
          _AttendanceTime(label: 'Masuk', value: record.checkInTime),
          const SizedBox(width: 20),
          _AttendanceTime(label: 'Pulang', value: record.checkOutTime),
          const SizedBox(width: 8),
          Icon(
            isComplete ? Icons.check_circle_rounded : Icons.schedule_rounded,
            color: isComplete ? AppColors.green : AppColors.amber,
            size: 17,
          ),
        ],
      ),
    );
  }
}

class _AttendanceTime extends StatelessWidget {
  const _AttendanceTime({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 9),
        ),
        const SizedBox(height: 3),
        Text(
          value ?? '--.--',
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}