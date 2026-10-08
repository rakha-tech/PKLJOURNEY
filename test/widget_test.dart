import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pkljourney2/models/pkl_user.dart';
import 'package:pkljourney2/screens/admin_mentorship_screen.dart';

void main() {
  final users = [
    const PklUser(
      username: 'admin',
      password: '123',
      name: 'Admin Sekolah',
      role: UserRole.admin,
      accountId: 'admin',
    ),
    const PklUser(
      username: 'guru1',
      password: '123',
      name: 'Guru Pembimbing 1',
      role: UserRole.guru,
      accountId: '19800101',
    ),
    const PklUser(
      username: 'murid1',
      password: '123',
      name: 'Murid Satu',
      role: UserRole.murid,
      accountId: '0011223344',
      mentorAccountId: '19800101',
    ),
    const PklUser(
      username: 'murid2',
      password: '123',
      name: 'Murid Dua',
      role: UserRole.murid,
      accountId: '0055667788',
    ),
  ];

  testWidgets('AdminMentorshipScreen displays students, metrics, and filters',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    String? assignedStudentId;
    String? assignedTeacherId;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminMentorshipScreen(
            users: users,
            onAssignMentor: (studentId, teacherId) {
              assignedStudentId = studentId;
              assignedTeacherId = teacherId;
            },
          ),
        ),
      ),
    );

    // Verify title and metrics
    expect(find.text('Penetapan Bimbingan'), findsOneWidget);
    expect(find.text('Total Siswa'), findsOneWidget);
    expect(find.text('Belum Dibimbing'), findsOneWidget);
    expect(find.text('Guru Pembimbing'), findsOneWidget);

    // Verify student names
    expect(find.text('Murid Satu'), findsOneWidget);
    expect(find.text('Murid Dua'), findsOneWidget);

    // Verify mentor status
    expect(find.text('Dibimbing oleh Guru Pembimbing 1'), findsOneWidget);
    expect(find.text('Belum ditentukan pembimbing'), findsOneWidget);

    // Tap "Tentukan" on Murid Dua
    await tester.tap(find.text('Tentukan'));
    await tester.pumpAndSettle();

    // Verify bottom sheet opened
    expect(find.text('Tentukan Guru Pembimbing'), findsOneWidget);
    expect(find.text('Guru Pembimbing 1'), findsWidgets);

    // Select the teacher
    await tester.tap(find.text('Guru Pembimbing 1').last);
    await tester.pumpAndSettle();

    // Save assignment
    await tester.tap(find.text('Simpan Penugasan'));
    await tester.pumpAndSettle();

    expect(assignedStudentId, '0055667788');
    expect(assignedTeacherId, '19800101');
  });

  testWidgets('AdminMentorshipScreen filter chips and search functionality',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminMentorshipScreen(
            users: users,
            onAssignMentor: (_, __) {},
          ),
        ),
      ),
    );

    // Filter "Belum Dibimbing"
    await tester.tap(find.text('Belum Dibimbing (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Murid Dua'), findsOneWidget);
    expect(find.text('Murid Satu'), findsNothing);

    // Filter "Per Guru"
    await tester.tap(find.text('Per Guru (1)'));
    await tester.pumpAndSettle();

    expect(find.text('Guru & Siswa Bimbingan'), findsOneWidget);
    expect(find.text('Guru Pembimbing 1'), findsOneWidget);
    expect(find.text('1 Siswa'), findsOneWidget);

    // Filter back to "Semua"
    await tester.tap(find.text('Semua (2)'));
    await tester.pumpAndSettle();

    // Search query
    await tester.enterText(find.byType(TextField), 'Satu');
    await tester.pumpAndSettle();

    expect(find.text('Murid Satu'), findsOneWidget);
    expect(find.text('Murid Dua'), findsNothing);
  });
}
