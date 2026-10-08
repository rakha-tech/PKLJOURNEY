import 'package:flutter/material.dart';
import '../models/pkl_user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

enum _MentorshipFilter {
  all,
  unassigned,
  assigned,
  byTeacher,
}

class AdminMentorshipScreen extends StatefulWidget {
  const AdminMentorshipScreen({
    super.key,
    required this.users,
    required this.onAssignMentor,
    this.onNavigateToAccounts,
  });

  final List<PklUser> users;
  final void Function(String studentAccountId, String? teacherAccountId)
      onAssignMentor;
  final VoidCallback? onNavigateToAccounts;

  @override
  State<AdminMentorshipScreen> createState() => _AdminMentorshipScreenState();
}

class _AdminMentorshipScreenState extends State<AdminMentorshipScreen> {
  final _searchController = TextEditingController();
  _MentorshipFilter _currentFilter = _MentorshipFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PklUser> get _teachers => widget.users
      .where((user) => user.role == UserRole.guru)
      .toList();

  List<PklUser> get _students => widget.users
      .where((user) => user.role == UserRole.murid)
      .toList();

  PklUser? _findTeacher(String? teacherAccountId) {
    if (teacherAccountId == null) return null;
    final index = _teachers.indexWhere((t) => t.accountId == teacherAccountId);
    return index != -1 ? _teachers[index] : null;
  }

  List<PklUser> _studentsForTeacher(String teacherAccountId) {
    return _students
        .where((s) => s.mentorAccountId == teacherAccountId)
        .toList();
  }

  List<PklUser> get _filteredStudents {
    final query = _searchQuery.trim().toLowerCase();
    return _students.where((student) {
      final matchesQuery = query.isEmpty ||
          student.name.toLowerCase().contains(query) ||
          student.accountId.toLowerCase().contains(query);
      if (!matchesQuery) return false;

      switch (_currentFilter) {
        case _MentorshipFilter.all:
          return true;
        case _MentorshipFilter.unassigned:
          return student.mentorAccountId == null;
        case _MentorshipFilter.assigned:
          return student.mentorAccountId != null;
        case _MentorshipFilter.byTeacher:
          return true;
      }
    }).toList();
  }

  Future<void> _showAssignTeacherSheet(PklUser student) async {
    final teachers = _teachers;
    final currentMentor = _findTeacher(student.mentorAccountId);

    if (teachers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Belum ada akun guru. Silakan daftarkan guru terlebih dahulu di menu Akun.',
          ),
          action: widget.onNavigateToAccounts != null
              ? SnackBarAction(
                  label: 'Kelola Akun',
                  textColor: AppColors.cream,
                  onPressed: widget.onNavigateToAccounts!,
                )
              : null,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedTeacherId = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AssignTeacherSheet(
        student: student,
        teachers: teachers,
        currentMentorAccountId: currentMentor?.accountId,
        studentCounts: {
          for (final teacher in teachers)
            teacher.accountId: _studentsForTeacher(teacher.accountId).length,
        },
      ),
    );

    // If user cancelled or didn't select, selectedTeacherId is null without change
    // If user explicitly chose to unassign, sheet returns an empty string sentinel.
    if (selectedTeacherId == null) return;

    if (!mounted) return;

    if (selectedTeacherId.isEmpty) {
      // Unassign
      widget.onAssignMentor(student.accountId, null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bimbingan untuk ${student.name} dilepaskan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Assign or reassign
      final teacher = _findTeacher(selectedTeacherId);
      widget.onAssignMentor(student.accountId, selectedTeacherId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${student.name} berhasil ditugaskan ke pembimbing ${teacher?.name ?? selectedTeacherId}.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmRemoveMentor(PklUser student) async {
    final mentor = _findTeacher(student.mentorAccountId);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Lepas pembimbing?'),
        content: Text(
          'Lepaskan bimbingan ${student.name} dari guru ${mentor?.name ?? 'pembimbing saat ini'}?\n\n'
          'Siswa akan berstatus "Belum ada pembimbing".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Lepaskan'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    widget.onAssignMentor(student.accountId, null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bimbingan ${student.name} telah dilepaskan.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allStudents = _students;
    final allTeachers = _teachers;
    final unassignedCount =
        allStudents.where((s) => s.mentorAccountId == null).length;
    final assignedCount =
        allStudents.where((s) => s.mentorAccountId != null).length;
    final filtered = _filteredStudents;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const PageHeading(
            title: 'Penetapan Bimbingan',
            subtitle: 'Tentukan dan kelola guru pembimbing untuk seluruh siswa PKL.',
          ),

          // Overview Metrics Row
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Total Siswa',
                  count: '${allStudents.length}',
                  icon: Icons.school_outlined,
                  color: AppColors.maroon,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'Belum Dibimbing',
                  count: '$unassignedCount',
                  icon: Icons.person_off_outlined,
                  color: unassignedCount > 0 ? AppColors.amber : AppColors.muted,
                  isAlert: unassignedCount > 0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(
                  title: 'Guru Pembimbing',
                  count: '${allTeachers.length}',
                  icon: Icons.person_pin_outlined,
                  color: AppColors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Search Box
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Cari nama atau NISN murid...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),

          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Semua (${allStudents.length})',
                  isSelected: _currentFilter == _MentorshipFilter.all,
                  onSelected: () =>
                      setState(() => _currentFilter = _MentorshipFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Belum Dibimbing ($unassignedCount)',
                  isSelected: _currentFilter == _MentorshipFilter.unassigned,
                  highlight: unassignedCount > 0,
                  onSelected: () => setState(
                    () => _currentFilter = _MentorshipFilter.unassigned,
                  ),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Sudah Dibimbing ($assignedCount)',
                  isSelected: _currentFilter == _MentorshipFilter.assigned,
                  onSelected: () => setState(
                    () => _currentFilter = _MentorshipFilter.assigned,
                  ),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Per Guru (${allTeachers.length})',
                  isSelected: _currentFilter == _MentorshipFilter.byTeacher,
                  onSelected: () => setState(
                    () => _currentFilter = _MentorshipFilter.byTeacher,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Content according to filter
          if (_currentFilter == _MentorshipFilter.byTeacher)
            _buildByTeacherSection(allTeachers)
          else
            _buildStudentListSection(filtered),
        ],
      ),
    );
  }

  Widget _buildStudentListSection(List<PklUser> students) {
    if (students.isEmpty) {
      final isSearching = _searchQuery.isNotEmpty;
      return WhiteCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.check_circle_outline_rounded,
                size: 44,
                color: isSearching ? AppColors.muted : AppColors.green,
              ),
              const SizedBox(height: 12),
              Text(
                isSearching
                    ? 'Tidak ada siswa yang sesuai pencarian'
                    : _currentFilter == _MentorshipFilter.unassigned
                        ? 'Semua siswa telah memiliki pembimbing'
                        : 'Belum ada data siswa',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isSearching
                    ? 'Coba gunakan kata kunci pencarian yang lain.'
                    : _currentFilter == _MentorshipFilter.unassigned
                        ? 'Kerja bagus! Seluruh murid PKL sudah terhubung dengan guru.'
                        : 'Tambahkan akun siswa baru melalui menu Kelola Akun.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          'Daftar Siswa',
          action: '${students.length} siswa',
        ),
        ...students.map((student) {
          final mentor = _findTeacher(student.mentorAccountId);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _StudentMentorshipTile(
              student: student,
              mentor: mentor,
              onAssignTeacher: () => _showAssignTeacherSheet(student),
              onRemoveMentor: mentor != null
                  ? () => _confirmRemoveMentor(student)
                  : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildByTeacherSection(List<PklUser> teachers) {
    if (teachers.isEmpty) {
      return WhiteCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              const Icon(
                Icons.person_pin_outlined,
                size: 44,
                color: AppColors.muted,
              ),
              const SizedBox(height: 12),
              const Text(
                'Belum ada guru pembimbing',
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Daftarkan akun guru terlebih dahulu agar siswa dapat ditugaskan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
              if (widget.onNavigateToAccounts != null) ...[
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: widget.onNavigateToAccounts,
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                  label: const Text('Buka Kelola Akun'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final unassigned =
        _students.where((s) => s.mentorAccountId == null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
          'Guru & Siswa Bimbingan',
          action: '${teachers.length} guru',
        ),
        ...teachers.map((teacher) {
          final mentoredStudents = _studentsForTeacher(teacher.accountId);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TeacherMentorshipGroupCard(
              teacher: teacher,
              students: mentoredStudents,
              unassignedStudentsCount: unassigned.length,
              onAddStudent: unassigned.isNotEmpty
                  ? () => _showQuickAssignToTeacherSheet(teacher, unassigned)
                  : null,
              onReassignStudent: (student) => _showAssignTeacherSheet(student),
              onRemoveStudent: (student) => _confirmRemoveMentor(student),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _showQuickAssignToTeacherSheet(
    PklUser teacher,
    List<PklUser> unassignedStudents,
  ) async {
    final selectedStudent = await showModalBottomSheet<PklUser>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PickStudentForTeacherSheet(
        teacher: teacher,
        unassignedStudents: unassignedStudents,
      ),
    );

    if (selectedStudent == null || !mounted) return;

    widget.onAssignMentor(selectedStudent.accountId, teacher.accountId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selectedStudent.name} berhasil ditugaskan ke ${teacher.name}.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.isAlert = false,
  });

  final String title;
  final String count;
  final IconData icon;
  final Color color;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 13),
      decoration: BoxDecoration(
        color: isAlert ? AppColors.paleAmber : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAlert ? AppColors.amber.withValues(alpha: 0.3) : AppColors.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              if (isAlert) ...[
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.amber,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 7),
          Text(
            count,
            style: TextStyle(
              color: isAlert ? AppColors.amber : AppColors.ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.highlight = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? AppColors.maroon
        : highlight
            ? AppColors.paleAmber
            : Colors.white;
    final fg = isSelected
        ? Colors.white
        : highlight
            ? AppColors.amber
            : AppColors.ink;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.maroon
                : highlight
                    ? AppColors.amber.withValues(alpha: 0.4)
                    : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StudentMentorshipTile extends StatelessWidget {
  const _StudentMentorshipTile({
    required this.student,
    required this.mentor,
    required this.onAssignTeacher,
    this.onRemoveMentor,
  });

  final PklUser student;
  final PklUser? mentor;
  final VoidCallback onAssignTeacher;
  final VoidCallback? onRemoveMentor;

  @override
  Widget build(BuildContext context) {
    final hasMentor = mentor != null;
    return WhiteCard(
      padding: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: hasMentor
                    ? AppColors.cream
                    : AppColors.paleAmber,
                child: Text(
                  student.name.isEmpty ? '?' : student.name[0].toUpperCase(),
                  style: TextStyle(
                    color: hasMentor ? AppColors.maroon : AppColors.amber,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
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
              if (hasMentor)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.muted,
                    size: 20,
                  ),
                  tooltip: 'Opsi penugasan',
                  onSelected: (action) {
                    if (action == 'reassign') {
                      onAssignTeacher();
                    } else if (action == 'remove') {
                      onRemoveMentor?.call();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'reassign',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Ubah pembimbing'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_remove_outlined,
                            size: 18,
                            color: AppColors.maroon,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Lepas bimbingan',
                            style: TextStyle(color: AppColors.maroon),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: hasMentor ? AppColors.paleGreen : AppColors.paleAmber,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  hasMentor
                      ? Icons.person_pin_rounded
                      : Icons.warning_amber_rounded,
                  size: 15,
                  color: hasMentor ? AppColors.green : AppColors.amber,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    hasMentor
                        ? 'Dibimbing oleh ${mentor!.name}'
                        : 'Belum ditentukan pembimbing',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasMentor ? AppColors.green : AppColors.amber,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!hasMentor) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onAssignTeacher,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Tentukan',
                            style: TextStyle(
                              color: AppColors.maroon,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 14,
                            color: AppColors.maroon,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherMentorshipGroupCard extends StatelessWidget {
  const _TeacherMentorshipGroupCard({
    required this.teacher,
    required this.students,
    required this.unassignedStudentsCount,
    required this.onAddStudent,
    required this.onReassignStudent,
    required this.onRemoveStudent,
  });

  final PklUser teacher;
  final List<PklUser> students;
  final int unassignedStudentsCount;
  final VoidCallback? onAddStudent;
  final ValueChanged<PklUser> onReassignStudent;
  final ValueChanged<PklUser> onRemoveStudent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 21,
                  backgroundColor: AppColors.paleGreen,
                  child: Icon(
                    Icons.person_pin_rounded,
                    color: AppColors.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'NIP ${teacher.accountId}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                InfoPill(
                  label: '${students.length} Siswa',
                  color: students.isEmpty
                      ? AppColors.paper
                      : AppColors.paleGreen,
                  textColor: students.isEmpty
                      ? AppColors.muted
                      : AppColors.green,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.line),
          if (students.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Belum ada siswa yang ditugaskan ke guru ini.',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                  ),
                  if (unassignedStudentsCount > 0 && onAddStudent != null)
                    TextButton.icon(
                      onPressed: onAddStudent,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Tugaskan siswa'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.maroon,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            )
          else ...[
            ...students.map(
              (student) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.line, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.cream,
                      child: Text(
                        student.name.isEmpty
                            ? '?'
                            : student.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.maroon,
                          fontSize: 10,
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'NISN ${student.accountId}',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                      tooltip: 'Pindahkan ke guru lain',
                      visualDensity: VisualDensity.compact,
                      color: AppColors.muted,
                      onPressed: () => onReassignStudent(student),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      tooltip: 'Lepas bimbingan',
                      visualDensity: VisualDensity.compact,
                      color: AppColors.maroon,
                      onPressed: () => onRemoveStudent(student),
                    ),
                  ],
                ),
              ),
            ),
            if (unassignedStudentsCount > 0 && onAddStudent != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: onAddStudent,
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                    label: Text(
                      'Tugaskan siswa lain ($unassignedStudentsCount belum dibimbing)',
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.maroon,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _AssignTeacherSheet extends StatefulWidget {
  const _AssignTeacherSheet({
    required this.student,
    required this.teachers,
    required this.currentMentorAccountId,
    required this.studentCounts,
  });

  final PklUser student;
  final List<PklUser> teachers;
  final String? currentMentorAccountId;
  final Map<String, int> studentCounts;

  @override
  State<_AssignTeacherSheet> createState() => _AssignTeacherSheetState();
}

class _AssignTeacherSheetState extends State<_AssignTeacherSheet> {
  String? _selectedTeacherId;

  @override
  void initState() {
    super.initState();
    _selectedTeacherId = widget.currentMentorAccountId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Tentukan Guru Pembimbing',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih guru yang akan membimbing ${widget.student.name} (NISN ${widget.student.accountId}).',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 18),
              ...widget.teachers.map((teacher) {
                final isSelected = _selectedTeacherId == teacher.accountId;
                final count = widget.studentCounts[teacher.accountId] ?? 0;
                final isCurrent =
                    widget.currentMentorAccountId == teacher.accountId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() => _selectedTeacherId = teacher.accountId);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.cream.withValues(alpha: 0.3) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.maroon : AppColors.line,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.maroon
                                    : AppColors.line,
                                width: isSelected ? 6.5 : 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        teacher.name,
                                        style: const TextStyle(
                                          color: AppColors.ink,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (isCurrent)
                                      const InfoPill(
                                        label: 'Saat Ini',
                                        color: AppColors.paleGreen,
                                        textColor: AppColors.green,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'NIP ${teacher.accountId} • $count siswa bimbingan',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              if (widget.currentMentorAccountId != null) ...[
                const SizedBox(height: 6),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Return empty string sentinel to indicate unassignment
                      Navigator.pop(context, '');
                    },
                    icon: const Icon(
                      Icons.person_remove_outlined,
                      size: 16,
                      color: AppColors.maroon,
                    ),
                    label: const Text(
                      'Lepaskan pembimbing dari siswa ini',
                      style: TextStyle(color: AppColors.maroon),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _selectedTeacherId == null ||
                        _selectedTeacherId == widget.currentMentorAccountId
                    ? null
                    : () => Navigator.pop(context, _selectedTeacherId),
                child: const Text('Simpan Penugasan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickStudentForTeacherSheet extends StatefulWidget {
  const _PickStudentForTeacherSheet({
    required this.teacher,
    required this.unassignedStudents,
  });

  final PklUser teacher;
  final List<PklUser> unassignedStudents;

  @override
  State<_PickStudentForTeacherSheet> createState() =>
      _PickStudentForTeacherSheetState();
}

class _PickStudentForTeacherSheetState
    extends State<_PickStudentForTeacherSheet> {
  PklUser? _selectedStudent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Pilih Siswa untuk Ditugaskan',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Tugaskan siswa tanpa pembimbing ke ${widget.teacher.name}.',
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ...widget.unassignedStudents.map((student) {
                final isSelected =
                    _selectedStudent?.accountId == student.accountId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedStudent = student),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.cream.withValues(alpha: 0.3)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.maroon : AppColors.line,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.maroon
                                    : AppColors.line,
                                width: isSelected ? 6.5 : 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.name,
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
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
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _selectedStudent == null
                    ? null
                    : () => Navigator.pop(context, _selectedStudent),
                child: const Text('Tugaskan ke Guru Ini'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
