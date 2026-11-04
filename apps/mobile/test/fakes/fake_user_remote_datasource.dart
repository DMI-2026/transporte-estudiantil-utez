import 'package:transporte_estudiantil/src/core/errors/app_failure.dart';
import 'package:transporte_estudiantil/src/features/auth/data/datasources/user_remote_datasource.dart';

class FakeUserRemoteDataSource implements UserRemoteDataSource {
  FakeUserRemoteDataSource({Map<String, Map<String, dynamic>>? perfiles})
    : perfiles = perfiles ?? {};

  final Map<String, Map<String, dynamic>> perfiles;
  AppFailure? fallaAlLeer;
  AppFailure? fallaAlGuardar;

  @override
  Future<Map<String, dynamic>?> fetchProfile(String uid) async {
    if (fallaAlLeer != null) {
      throw fallaAlLeer!;
    }
    return perfiles[uid];
  }

  @override
  Future<void> saveProfile(String uid, Map<String, Object?> data) async {
    if (fallaAlGuardar != null) {
      throw fallaAlGuardar!;
    }
    perfiles[uid] = Map<String, dynamic>.from(data);
  }
}
