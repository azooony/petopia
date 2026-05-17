import 'api_client.dart';
import 'auth_storage.dart';

class AuthService {
  /// POST /auth/login — works for all roles (PET_OWNER, VET, ADMIN).
  /// Saves the JWT and returns the user map so the caller can route by role.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });
    final data = response['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    final token = data['token'] as String;

    await AuthStorage.saveSession(
      token: token,
      userId: user['id'] as String,
      role: user['role'] as String,
    );

    return user;
  }

  /// POST /auth/register-vet — registers a vet (multipart with certificate image).
  /// Does NOT return a token — the vet must wait for admin approval.
  static Future<void> registerVet({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required int age,
    required String gender,
    required String clinicName,
    required String clinicAddress,
    required List<int> certificateBytes,
    required String certificateFilename,
  }) async {
    await ApiClient.multipartPostBytes(
      '/auth/register-vet',
      fields: {
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'age': age.toString(),
        'gender': gender,
        'clinicName': clinicName,
        'clinicAddress': clinicAddress,
        'clinicPhone': phone,
        'yearsOfExperience': '1',
      },
      bytes: certificateBytes,
      filename: certificateFilename,
      fileField: 'certificate',
    );
  }

  /// POST /admin/login — admin-specific login endpoint.
  /// Saves the JWT and returns the admin map.
  static Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post('/admin/login', {
      'email': email,
      'password': password,
    });
    final data = response['data'] as Map<String, dynamic>;
    final admin = data['admin'] as Map<String, dynamic>;
    final token = data['token'] as String;

    await AuthStorage.saveSession(
      token: token,
      userId: admin['id'] as String,
      role: admin['role'] as String,
    );

    return admin;
  }

  /// POST /auth/register-owner — registers a pet owner and logs them in immediately.
  /// The backend returns a token on successful registration.
  static Future<Map<String, dynamic>> registerPetOwner({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required int age,
    required String gender, // 'MALE' or 'FEMALE'
  }) async {
    final response = await ApiClient.post('/auth/register-owner', {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'age': age,
      'gender': gender,
    });
    final data = response['data'] as Map<String, dynamic>;
    final user = data['user'] as Map<String, dynamic>;
    final token = data['token'] as String;

    await AuthStorage.saveSession(
      token: token,
      userId: user['id'] as String,
      role: user['role'] as String,
    );

    return user;
  }
}
