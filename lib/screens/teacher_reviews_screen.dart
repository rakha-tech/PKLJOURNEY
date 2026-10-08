import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../models/pkl_user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class TeacherReviewsScreen extends StatelessWidget {
  const TeacherReviewsScreen({
    super.key,
    required this.students,
    required this.journalEntries,
    required this.onMarkReviewed,
  });

  final List<PklUser> students;
  final Map<String, List<JournalEntry>> journalEntries;
  final void Function(String studentAccountId, String entryId) onMarkReviewed;

  List<_StudentJournal> get _reviews => [
        for (final student in students)
          for (final entry in journalEntries[student.accountId] ?? const [])
            _StudentJournal(student: student, entry: entry),
      ];

  @override
  Widget build(BuildContext context) {
    final reviews = _reviews;
    final pendingCount =
        reviews.where((review) => !review.entry.isReviewed).length;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          PageHeading(
            title: 'Tinjau jurnal',
            subtitle: 'Baca catatan kegiatan murid bimbingan.',
            trailing: InfoPill(
              label: '$pendingCount menunggu',
              color: pendingCount == 0
                  ? AppColors.paleGreen
                  : AppColors.paleAmber,
              textColor:
                  pendingCount == 0 ? AppColors.green : AppColors.amber,
              icon: Icons.rate_review_outlined,
            ),
          ),
          if (reviews.isEmpty)
            const WhiteCard(
              child: Text(
                'Belum ada jurnal dari murid bimbingan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted),
              ),
            )
          else
            ...reviews.map(
              (review) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: WhiteCard(
                  padding: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.school_outlined,
                            color: AppColors.maroon,
                            size: 17,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              review.student.name,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            review.entry.date,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Text(
                        review.entry.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        review.entry.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: review.entry.isReviewed
                            ? const InfoPill(
                                label: 'Sudah ditinjau',
                                color: AppColors.paleGreen,
                                textColor: AppColors.green,
                                icon: Icons.check_circle_outline_rounded,
                              )
                            : OutlinedButton.icon(
                                onPressed: () {
                                  onMarkReviewed(
                                    review.student.accountId,
                                    review.entry.id,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Jurnal ditandai sudah ditinjau.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                ),
                                label: const Text('Tandai sudah ditinjau'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.maroon,
                                  side: const BorderSide(
                                    color: AppColors.line,
                                  ),
                                  minimumSize: const Size.fromHeight(42),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (reviews.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Jurnal ditampilkan sesuai murid yang dibimbing akun guru ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}

class _StudentJournal {
  const _StudentJournal({required this.student, required this.entry});

  final PklUser student;
  final JournalEntry entry;
}