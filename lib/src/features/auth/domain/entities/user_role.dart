enum UserRole {
  estudiante,
  operador,
  administrador;

  String get firestoreValue => name;

  /// `null` si el valor no es un rol conocido: nunca se asume un rol por
  /// defecto, el servidor es la única fuente de verdad.
  static UserRole? fromFirestore(String value) {
    for (final r in UserRole.values) {
      if (r.name == value) return r;
    }
    return null;
  }
}
