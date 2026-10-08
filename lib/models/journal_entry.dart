class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    this.tag = 'Kegiatan',
    this.isReviewed = false,
  });

  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String tag;
  final bool isReviewed;

  JournalEntry copyWith({bool? isReviewed}) => JournalEntry(
        id: id,
        title: title,
        description: description,
        date: date,
        time: time,
        tag: tag,
        isReviewed: isReviewed ?? this.isReviewed,
      );
}