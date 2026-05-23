import 'dart:typed_data';
import 'services/api_client.dart';

class LostPet {
  final String id;
  final String petName;
  final String? breed;
  final String? gender;
  final int? age;
  final String? petType;
  final Uint8List? photoBytes;
  final String? imageUrl;
  final String lastSeenLocation;
  final DateTime lastSeenDate;
  final String ownerName;
  final String ownerId;
  final bool isOwn;
  final String? description;

  const LostPet({
    required this.id,
    required this.petName,
    this.breed,
    this.gender,
    this.age,
    this.petType,
    this.photoBytes,
    this.imageUrl,
    required this.lastSeenLocation,
    required this.lastSeenDate,
    required this.ownerName,
    required this.ownerId,
    this.isOwn = false,
    this.description,
  });

  factory LostPet.fromJson(Map<String, dynamic> j, String myUserId) {
    final owner = j['owner'] as Map<String, dynamic>? ?? {};
    final images = j['images'] as List<dynamic>? ?? [];
    String? imageUrl;
    if (images.isNotEmpty) {
      final rawUrl =
          (images.first as Map<String, dynamic>)['url'] as String?;
      if (rawUrl != null) {
        imageUrl = rawUrl.startsWith('http')
            ? rawUrl
            : '${ApiClient.baseUrl}$rawUrl';
      }
    }
    return LostPet(
      id: j['id'] as String? ?? '',
      petName: j['name'] as String? ?? 'Unknown Pet',
      breed: j['breed'] as String?,
      gender: j['gender'] as String?,
      petType: j['species'] as String?,
      imageUrl: imageUrl,
      lastSeenLocation: j['lastSeenLocation'] as String? ?? '',
      lastSeenDate: j['lastSeenDate'] != null
          ? DateTime.tryParse(j['lastSeenDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      ownerName: owner['fullName'] as String? ?? '',
      ownerId: j['ownerId'] as String? ?? '',
      isOwn: (j['ownerId'] as String?) == myUserId,
      description: j['description'] as String?,
    );
  }
}

class FoundPet {
  final String id;
  final String description;
  final Uint8List? photoBytes;
  final String? imageUrl;
  final String foundLocation;
  final bool isPetKept;
  final String reporterName;
  final String reporterId;
  final bool isOwn;
  final String? petType;
  final String? breed;

  const FoundPet({
    required this.id,
    required this.description,
    this.photoBytes,
    this.imageUrl,
    required this.foundLocation,
    required this.isPetKept,
    required this.reporterName,
    required this.reporterId,
    this.isOwn = false,
    this.petType,
    this.breed,
  });

  factory FoundPet.fromJson(Map<String, dynamic> j, String myUserId) {
    final finder = j['finder'] as Map<String, dynamic>? ?? {};
    final images = j['images'] as List<dynamic>? ?? [];
    String? imageUrl;
    if (images.isNotEmpty) {
      final rawUrl =
          (images.first as Map<String, dynamic>)['url'] as String?;
      if (rawUrl != null) {
        imageUrl = rawUrl.startsWith('http')
            ? rawUrl
            : '${ApiClient.baseUrl}$rawUrl';
      }
    }
    return FoundPet(
      id: j['id'] as String? ?? '',
      description: j['description'] as String? ?? '',
      imageUrl: imageUrl,
      foundLocation: j['foundLocation'] as String? ?? '',
      isPetKept: j['isPetStillAtLocation'] as bool? ?? false,
      reporterName: finder['fullName'] as String? ?? '',
      reporterId: j['finderId'] as String? ?? '',
      isOwn: (j['finderId'] as String?) == myUserId,
      petType: j['species'] as String?,
      breed: j['breed'] as String?,
    );
  }
}
