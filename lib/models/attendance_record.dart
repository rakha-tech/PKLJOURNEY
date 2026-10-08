const _indonesianMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

const _indonesianWeekdays = [
  'Sen',
  'Sel',
  'Rab',
  'Kam',
  'Jum',
  'Sab',
  'Min',
];

class AttendanceRecord {
  const AttendanceRecord({
    required this.date,
    this.checkInTime,
    this.checkOutTime,
  });

  final DateTime date;
  final String? checkInTime;
  final String? checkOutTime;

  AttendanceRecord copyWith({
    String? checkInTime,
    String? checkOutTime,
  }) {
    return AttendanceRecord(
      date: date,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }

  bool isSameDay(DateTime other) =>
      date.year == other.year &&
      date.month == other.month &&
      date.day == other.day;

  String get shortDate =>
      '${date.day.toString().padLeft(2, '0')} ${_indonesianMonths[date.month - 1]} ${date.year}';

  String get shortWeekday => _indonesianWeekdays[date.weekday - 1];
}