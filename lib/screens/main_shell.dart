import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import '../models/internship_location.dart';
import '../models/journal_entry.dart';
import '../models/pkl_user.dart';
import '../theme/app_theme.dart';
import 'admin_accounts_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_mentorship_screen.dart';
import 'attendance_screen.dart';
import 'dashboard_screen.dart';
import 'journal_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'teacher_attendance_screen.dart';
import 'teacher_dashboard_screen.dart';
import 'teacher_reviews_screen.dart';
import 'teacher_students_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.user,
    required this.users,
    required this.teacherLocations,
    required this.attendanceRecords,
    required this.journalEntries,
    required this.onRegisterAccount,
    required this.onAddStudent,
    required this.onAssignMentor,
    required this.onSaveTeacherLocation,
    required this.onSaveAttendance,
    required this.onAddJournalEntry,
    required this.onMarkJournalReviewed,
    required this.onDeleteAccount,
    required this.onLogout,
  });

  final PklUser user;
  final List<PklUser> users;
  final Map<String, InternshipLocation> teacherLocations;
  final Map<String, List<AttendanceRecord>> attendanceRecords;
  final Map<String, List<JournalEntry>> journalEntries;
  final ValueChanged<PklUser> onRegisterAccount;
  final void Function(PklUser teacher, PklUser student) onAddStudent;
  final void Function(String studentAccountId, String? teacherAccountId)
      onAssignMentor;
  final void Function(String teacherAccountId, InternshipLocation location)
      onSaveTeacherLocation;
  final void Function(String studentAccountId, List<AttendanceRecord> records)
      onSaveAttendance;
  final void Function(String studentAccountId, JournalEntry entry)
      onAddJournalEntry;
  final void Function(String studentAccountId, String entryId)
      onMarkJournalReviewed;
  final ValueChanged<PklUser> onDeleteAccount;
  final VoidCallback onLogout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _addEntry(JournalEntry entry) {
    widget.onAddJournalEntry(widget.user.accountId, entry);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jurnal kegiatan berhasil disimpan.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleAttendance() {
    final now = DateTime.now();
    final records = List<AttendanceRecord>.of(
      widget.attendanceRecords[widget.user.accountId] ?? const [],
    );
    final todayIndex = records.indexWhere((record) => record.isSameDay(now));
    final time =
        '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';

    if (todayIndex == -1) {
      records.insert(
        0,
        AttendanceRecord(
          date: DateTime(now.year, now.month, now.day),
          checkInTime: time,
        ),
      );
    } else if (records[todayIndex].checkOutTime == null) {
      records[todayIndex] = records[todayIndex].copyWith(checkOutTime: time);
    }

    widget.onSaveAttendance(widget.user.accountId, records);
  }

  AttendanceRecord? _todayAttendance() {
    final now = DateTime.now();
    for (final record
        in widget.attendanceRecords[widget.user.accountId] ?? const []) {
      if (record.isSameDay(now)) return record;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Widget page;
    final List<NavigationDestination> destinations;

    switch (widget.user.role) {
      case UserRole.admin:
        page = IndexedStack(
          index: _selectedIndex,
          children: [
            AdminDashboardScreen(
              user: widget.user,
              users: widget.users,
              onManageAccounts: () => setState(() => _selectedIndex = 2),
              onManageMentorship: () => setState(() => _selectedIndex = 1),
            ),
            AdminMentorshipScreen(
              users: widget.users,
              onAssignMentor: widget.onAssignMentor,
              onNavigateToAccounts: () => setState(() => _selectedIndex = 2),
            ),
            AdminAccountsScreen(
              currentAdmin: widget.user,
              users: widget.users,
              onRegisterAccount: widget.onRegisterAccount,
              onDeleteAccount: widget.onDeleteAccount,
            ),
            ProfileScreen(user: widget.user, onLogout: widget.onLogout),
          ],
        );
        destinations = const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_ind_outlined),
            selectedIcon: Icon(Icons.assignment_ind_rounded),
            label: 'Bimbingan',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts_outlined),
            selectedIcon: Icon(Icons.manage_accounts_rounded),
            label: 'Akun',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ];
        break;
      case UserRole.guru:
        final students = widget.users
            .where(
              (account) =>
                  account.role == UserRole.murid &&
                  account.mentorAccountId == widget.user.accountId,
            )
            .toList();
        final studentIds = students.map((student) => student.accountId).toSet();
        final pendingJournalCount = widget.journalEntries.entries
            .where((entry) => studentIds.contains(entry.key))
            .expand((entry) => entry.value)
            .where((entry) => !entry.isReviewed)
            .length;
        page = IndexedStack(
          index: _selectedIndex,
          children: [
            TeacherDashboardScreen(
              user: widget.user,
              users: widget.users,
              pendingJournalCount: pendingJournalCount,
              onOpenStudents: () => setState(() => _selectedIndex = 1),
              onOpenReviews: () => setState(() => _selectedIndex = 2),
              onOpenAttendance: () => setState(() => _selectedIndex = 3),
            ),
            TeacherStudentsScreen(
              teacher: widget.user,
              users: widget.users,
              location: widget.teacherLocations[widget.user.accountId],
              onAddStudent: (student) =>
                  widget.onAddStudent(widget.user, student),
              onSaveLocation: (location) => widget.onSaveTeacherLocation(
                widget.user.accountId,
                location,
              ),
            ),
            TeacherReviewsScreen(
              students: students,
              journalEntries: widget.journalEntries,
              onMarkReviewed: widget.onMarkJournalReviewed,
            ),
            TeacherAttendanceScreen(
              students: students,
              attendanceRecords: widget.attendanceRecords,
            ),
            ProfileScreen(user: widget.user, onLogout: widget.onLogout),
          ],
        );
        destinations = const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_2_outlined),
            selectedIcon: Icon(Icons.groups_2_rounded),
            label: 'Murid',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Tinjau',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check_rounded),
            label: 'Presensi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ];
        break;
      case UserRole.murid:
        final attendance = _todayAttendance();
        final location = widget.user.mentorAccountId == null
            ? null
            : widget.teacherLocations[widget.user.mentorAccountId];
        final studentRecords =
            widget.attendanceRecords[widget.user.accountId] ?? const [];
        page = IndexedStack(
          index: _selectedIndex,
          children: [
            DashboardScreen(
              studentName: widget.user.name,
              hasCheckedIn: attendance?.checkInTime != null,
              hasCheckedOut: attendance?.checkOutTime != null,
              checkInTime: attendance?.checkInTime,
              checkOutTime: attendance?.checkOutTime,
              journalCount:
                  widget.journalEntries[widget.user.accountId]?.length ?? 0,
              workplaceLocation: location,
              onOpenAttendance: () => setState(() => _selectedIndex = 1),
              onOpenJournal: () => setState(() => _selectedIndex = 2),
              onOpenProgress: () => setState(() => _selectedIndex = 3),
            ),
            AttendanceScreen(
              hasCheckedIn: attendance?.checkInTime != null,
              hasCheckedOut: attendance?.checkOutTime != null,
              checkInTime: attendance?.checkInTime,
              checkOutTime: attendance?.checkOutTime,
              onAttendanceAction: _toggleAttendance,
              records: studentRecords,
              workplaceLocation: location,
            ),
            JournalScreen(
              entries:
                  widget.journalEntries[widget.user.accountId] ?? const [],
              onAddEntry: _addEntry,
            ),
            const ProgressScreen(),
            ProfileScreen(user: widget.user, onLogout: widget.onLogout),
          ],
        );
        destinations = const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check_rounded),
            label: 'Presensi',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Jurnal',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Progres',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ];
        break;
    }

    return Scaffold(
      body: page,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: AppColors.cream,
        destinations: destinations,
      ),
    );
  }
}