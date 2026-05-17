import '../models/doctor_model.dart';
import '../models/pet_model.dart';
import 'api_client.dart';

class AppointmentService {
  /// GET /appointments/doctors — returns all verified vets.
  static Future<List<DoctorModel>> fetchDoctors() async {
    final response = await ApiClient.get('/appointments/doctors');
    final data = response['data'] as List<dynamic>;
    return data
        .map((json) => DoctorModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// GET /pets — returns the authenticated owner's pets.
  static Future<List<PetModel>> fetchMyPets() async {
    final response = await ApiClient.get('/pets');
    final data = response['data'] as List<dynamic>;
    return data
        .map((json) => PetModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /appointments/book — multipart: fields + invoice image bytes.
  static Future<Map<String, dynamic>> bookAppointment({
    required String vetId,
    required String petId,
    required DateTime startTime,
    required List<int> invoiceBytes,
    required String invoiceFilename,
    String? reason,
  }) async {
    final fields = <String, String>{
      'vetId': vetId,
      'petId': petId,
      'startTime': startTime.toUtc().toIso8601String(),
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    };

    return ApiClient.multipartPostBytes(
      '/appointments/book',
      fields: fields,
      bytes: invoiceBytes,
      filename: invoiceFilename,
      fileField: 'invoice',
    );
  }
}
