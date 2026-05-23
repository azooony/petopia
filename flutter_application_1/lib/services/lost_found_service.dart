import 'dart:typed_data';
import 'api_client.dart';
import 'auth_storage.dart';
import '../lost_found_data.dart';

class LostFoundService {
  static Future<List<LostPet>> getLostPets() async {
    final myId = await AuthStorage.getUserId() ?? '';
    final res = await ApiClient.get('/lost-found/lost');
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => LostPet.fromJson(Map<String, dynamic>.from(e as Map), myId))
        .toList();
  }

  static Future<List<FoundPet>> getFoundPets() async {
    final myId = await AuthStorage.getUserId() ?? '';
    final res = await ApiClient.get('/lost-found/found');
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => FoundPet.fromJson(Map<String, dynamic>.from(e as Map), myId))
        .toList();
  }

  static Future<void> reportLostPet({
    required String species,
    required String description,
    required String lastSeenLocation,
    required String lastSeenDate,
    String? petId,
    String? name,
    String? breed,
    String? gender,
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    final fields = <String, String>{
      'species': species,
      'description': description,
      'lastSeenLocation': lastSeenLocation,
      'lastSeenDate': lastSeenDate,
      if (petId != null && petId.isNotEmpty) 'petId': petId,
      if (name != null && name.isNotEmpty) 'name': name,
      if (breed != null && breed.isNotEmpty) 'breed': breed,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
    };

    final files = imageBytes != null && imageFilename != null
        ? [
            {
              'field': 'images',
              'bytes': imageBytes,
              'filename': imageFilename,
            }
          ]
        : <Map<String, dynamic>>[];

    await ApiClient.multipartPostMultipleFiles(
      '/lost-found/lost',
      fields: fields,
      files: files,
    );
  }

  static Future<void> reportFoundPet({
    required String species,
    required String description,
    required String foundLocation,
    required bool isPetStillAtLocation,
    String? breed,
    String? gender,
    Uint8List? imageBytes,
    String? imageFilename,
  }) async {
    final fields = <String, String>{
      'species': species,
      'description': description,
      'foundLocation': foundLocation,
      'isPetStillAtLocation': isPetStillAtLocation.toString(),
      if (breed != null && breed.isNotEmpty) 'breed': breed,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
    };

    final files = imageBytes != null && imageFilename != null
        ? [
            {
              'field': 'images',
              'bytes': imageBytes,
              'filename': imageFilename,
            }
          ]
        : <Map<String, dynamic>>[];

    await ApiClient.multipartPostMultipleFiles(
      '/lost-found/found',
      fields: fields,
      files: files,
    );
  }

  static Future<void> deleteFoundPet(String id) async {
    await ApiClient.delete('/lost-found/found/$id');
  }
}
