import 'dart:typed_data';
import 'api_client.dart';
import '../sitting_data.dart';

class SittingService {
  static Future<void> listPetForSitting({
    required String petName,
    required String breed,
    required int age,
    required String gender,
    required String petType,
    required double payRatePerDay,
    required String sittingNotes,
    Uint8List? photoBytes,
    String? photoFilename,
  }) async {
    if (photoBytes != null && photoFilename != null) {
      await ApiClient.multipartPostMultipleFiles(
        '/sitting/pet-listing',
        fields: {
          'petName': petName,
          'breed': breed,
          'age': age.toString(),
          'gender': gender,
          'petType': petType,
          'payRatePerDay': payRatePerDay.toString(),
          'sittingNotes': sittingNotes,
        },
        files: [
          {
            'field': 'petPhoto',
            'bytes': photoBytes,
            'filename': photoFilename,
          },
        ],
      );
    } else {
      await ApiClient.post('/sitting/pet-listing', {
        'petName': petName,
        'breed': breed,
        'age': age,
        'gender': gender,
        'petType': petType,
        'payRatePerDay': payRatePerDay,
        'sittingNotes': sittingNotes,
      });
    }
  }

  static Future<List<SittingPet>> getAvailablePets() async {
    final res = await ApiClient.get('/sitting/available-pets');
    final list = res['data'] as List<dynamic>;
    return list
        .map((e) => SittingPet.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> unlistPet() async {
    await ApiClient.delete('/sitting/pet-listing');
  }

  static Future<String?> getSitterStatus() async {
    final res = await ApiClient.get('/sitting/sitter-status');
    final data = res['data'] as Map<String, dynamic>?;
    return data?['status'] as String?;
  }

  static Future<void> registerSitter({
    required Uint8List nationalIdBytes,
    required String nationalIdFilename,
    required Uint8List venuePhotoBytes,
    required String venuePhotoFilename,
  }) async {
    await ApiClient.multipartPostMultipleFiles(
      '/sitting/register-sitter',
      files: [
        {
          'field': 'nationalIdPhoto',
          'bytes': nationalIdBytes,
          'filename': nationalIdFilename,
        },
        {
          'field': 'venuePhoto',
          'bytes': venuePhotoBytes,
          'filename': venuePhotoFilename,
        },
      ],
    );
  }
}
