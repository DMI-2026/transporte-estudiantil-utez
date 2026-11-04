enum VerificationStatus {
  pendiente,
  aprobada,
  rechazada;

  String get firestoreValue => name;

  /// `null` si el valor no es un estado conocido.
  static VerificationStatus? fromFirestore(String value) {
    for (final s in VerificationStatus.values) {
      if (s.name == value) return s;
    }
    return null;
  }

  bool get canUseApp => this == VerificationStatus.aprobada;
}
