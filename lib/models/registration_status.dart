enum UserRole {
  challenger,
  supporter,
  none; // 역할이 아직 지정되지 않은 경우

  static UserRole fromString(String? value) {
    if (value == null) return UserRole.none;
    if (value.toLowerCase() == 'challenger') return UserRole.challenger;
    if (value.toLowerCase() == 'supporter') return UserRole.supporter;
    return UserRole.none;
  }
}

class RegistrationStatus {
  final UserRole registeredRole;

  RegistrationStatus({
    this.registeredRole = UserRole.none,
  });

  factory RegistrationStatus.fromString(String? value) {
    return RegistrationStatus(
      registeredRole: UserRole.fromString(value),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'registered_role': registeredRole.name,
    };
  }

  @override
  String toString() {
    return 'RegistrationStatus(registeredRole: $registeredRole)';
  }
}
