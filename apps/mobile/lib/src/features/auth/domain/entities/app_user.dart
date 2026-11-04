import 'user_role.dart';
import 'verification_status.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.verificationStatus,
    this.displayName,
  });

  final String uid;
  final String email;
  final UserRole role;
  final VerificationStatus verificationStatus;
  final String? displayName;

  bool get isApproved => verificationStatus.canUseApp;
}
