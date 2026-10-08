import 'package:flutter/material.dart';
import 'models/attendance_record.dart';
import 'models/internship_location.dart';
import 'models/journal_entry.dart';
import 'models/pkl_user.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PklJourneyApp());
}

class PklJourneyApp extends StatefulWidget {
  const PklJourneyApp({super.key});

  @override
  State<PklJourneyApp> createState() => _PklJourneyAppState();
}

class _PklJourneyAppState extends State<PklJourneyApp> {
  bool _showSplash = true;
  PklUser? _currentUser;
  final List<PklUser> _users = createDemoUsers();
  final Map<String, InternshipLocation> _teacherLocations = {};
  final Map<String, List<AttendanceRecord>> _attendanceRecords = {};
  final Map<String, List<JournalEntry>> _journalEntries = {
    '0058291823': [
      JournalEntry(
        id: 'demo-workplace-orientation',
        title: 'Orientasi lingkungan kerja',
        description:
            'Mengenal tim, alur kerja, dan tools yang digunakan di bagian teknologi informasi.',
        date: '30 Sep 2026',
        time: '15.42',
        tag: 'Orientasi',
      ),
      JournalEntry(
        id: 'demo-git-collaboration',
        title: 'Belajar dasar Git dan kolaborasi',
        description:
            'Mempelajari cara membuat branch dan mengirim perubahan dengan pull request.',
        date: '29 Sep 2026',
        time: '16.05',
        tag: 'Pembelajaran',
      ),
    ],
  };

  void _finishSplash() {
    if (mounted) setState(() => _showSplash = false);
  }

  void _login(PklUser user) {
    setState(() => _currentUser = user);
  }

  void _registerAccount(PklUser user) {
    setState(() => _users.add(user));
  }

  void _addTeacherStudent(PklUser teacher, PklUser student) {
    setState(() {
      final existingIndex = _users.indexWhere(
        (user) =>
            user.role == UserRole.murid &&
            user.accountId == student.accountId,
      );
      if (existingIndex == -1) {
        _users.add(student.copyWith(mentorAccountId: teacher.accountId));
      } else {
        _users[existingIndex] =
            _users[existingIndex].copyWith(mentorAccountId: teacher.accountId);
      }
    });
  }

  void _assignStudentMentor(String studentAccountId, String? teacherAccountId) {
    setState(() {
      final index = _users.indexWhere(
        (user) =>
            user.role == UserRole.murid && user.accountId == studentAccountId,
      );
      if (index != -1) {
        _users[index] = _users[index].copyWith(
          mentorAccountId: teacherAccountId,
          clearMentorAccountId: teacherAccountId == null,
        );
      }
    });
  }

  void _saveTeacherLocation(String teacherAccountId, InternshipLocation location) {
    setState(() => _teacherLocations[teacherAccountId] = location);
  }

  void _saveAttendance(
    String studentAccountId,
    List<AttendanceRecord> records,
  ) {
    setState(() => _attendanceRecords[studentAccountId] = records);
  }

  void _addJournalEntry(String studentAccountId, JournalEntry entry) {
    setState(() {
      _journalEntries[studentAccountId] = [
        entry,
        ...(_journalEntries[studentAccountId] ?? const <JournalEntry>[]),
      ];
    });
  }

  void _markJournalReviewed(String studentAccountId, String entryId) {
    final entries = _journalEntries[studentAccountId];
    if (entries == null) return;
    final index = entries.indexWhere((entry) => entry.id == entryId);
    if (index == -1 || entries[index].isReviewed) return;
    setState(() => entries[index] = entries[index].copyWith(isReviewed: true));
  }

  void _deleteAccount(PklUser account) {
    setState(() {
      _users.removeWhere(
        (user) =>
            user.role == account.role && user.accountId == account.accountId,
      );

      if (account.role == UserRole.guru) {
        for (var index = 0; index < _users.length; index++) {
          if (_users[index].mentorAccountId == account.accountId) {
            _users[index] = _users[index].copyWith(clearMentorAccountId: true);
          }
        }
        _teacherLocations.remove(account.accountId);
      } else if (account.role == UserRole.murid) {
        _attendanceRecords.remove(account.accountId);
        _journalEntries.remove(account.accountId);
      }
    });
  }

  void _logout() {
    setState(() => _currentUser = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PKLJOURNEY',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _showSplash
          ? SplashScreen(onFinished: _finishSplash)
          : _currentUser != null
              ? MainShell(
                  user: _currentUser!,
                  users: _users,
                  teacherLocations: _teacherLocations,
                  attendanceRecords: _attendanceRecords,
                  journalEntries: _journalEntries,
                  onRegisterAccount: _registerAccount,
                  onAddStudent: _addTeacherStudent,
                  onAssignMentor: _assignStudentMentor,
                  onSaveTeacherLocation: _saveTeacherLocation,
                  onSaveAttendance: _saveAttendance,
                  onAddJournalEntry: _addJournalEntry,
                  onMarkJournalReviewed: _markJournalReviewed,
                  onDeleteAccount: _deleteAccount,
                  onLogout: _logout,
                )
              : LoginScreen(users: _users, onLogin: _login),
    );
  }
}