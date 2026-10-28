abstract interface class UserRemoteDataSource {
  Future<Map<String, dynamic>?> fetchProfile(String uid);

  Future<void> saveProfile(String uid, Map<String, Object?> data);
}
