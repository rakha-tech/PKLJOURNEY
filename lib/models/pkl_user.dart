enum UserRole { admin, guru, murid }

extension UserRoleDetails on UserRole {
  String get label => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.guru => 'Guru',
        UserRole.murid => 'Murid',
      };

  String get accountIdLabel => switch (this) {
        UserRole.admin => 'Username',
        UserRole.guru => 'NIP',
        UserRole.murid => 'NISN',
      };

  String get loginLabel => switch (this) {
        UserRole.admin => 'USERNAME ADMIN',
        UserRole.guru => 'USERNAME / NIP GURU',
        UserRole.murid => 'USERNAME / NISN MURID',
      };
}

class PklUser {
  const PklUser({
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    required this.accountId,
    this.mentorAccountId,
  });

  final String username;
  final String password;
  final String name;
  final UserRole role;
  final String accountId;
  final String? mentorAccountId;

  PklUser copyWith({
    String? mentorAccountId,
    bool clearMentorAccountId = false,
  }) {
    return PklUser(
      username: username,
      password: password,
      name: name,
      role: role,
      accountId: accountId,
      mentorAccountId:
          clearMentorAccountId ? null : mentorAccountId ?? this.mentorAccountId,
    );
  }
}

List<PklUser> createDemoUsers() => [
      PklUser(
        username: 'admin',
        password: 'admin',
        name: 'Administrator PKLJOURNEY',
        role: UserRole.admin,
        accountId: 'admin',
      ),
      PklUser(
        username: 'guru',
        password: 'guru',
        name: 'Budi Santoso, S.Kom.',
        role: UserRole.guru,
        accountId: '198406082010011004',
      ),
      PklUser(
        username: 'murid',
        password: 'murid',
        name: 'Sukmalintang Ramadhani',
        role: UserRole.murid,
        accountId: '0058291823',
        mentorAccountId: '198406082010011004',
      ),
    ];