import 'dart:typed_data';
import 'services/api_client.dart';

class SittingPet {
  final String id;
  final String name;
  final String duration;
  final String city;
  final String gender;
  final String petType;
  final String? pricePerDay;
  final String? imagePath;
  final Uint8List? photoBytes;
  final String? imageUrl;
  final bool isOwn;
  final bool navigatesToMolly;
  final String ownerName;
  final String ownerId;
  final String? breed;
  final int? age;
  final String? fullNotes;

  const SittingPet({
    this.id = '',
    required this.name,
    required this.duration,
    required this.city,
    required this.gender,
    this.petType = 'DOG',
    this.pricePerDay,
    this.imagePath,
    this.photoBytes,
    this.imageUrl,
    this.isOwn = false,
    this.navigatesToMolly = false,
    this.ownerName = '',
    this.ownerId = '',
    this.breed,
    this.age,
    this.fullNotes,
  });

  static String _fmtDateRange(String firstLine) {
    final re = RegExp(r'(\d{4}-\d{2}-\d{2}) to (\d{4}-\d{2}-\d{2})');
    final m = re.firstMatch(firstLine);
    if (m == null) return firstLine.isNotEmpty ? firstLine : 'Available now';
    final start = DateTime.tryParse(m.group(1)!);
    final end   = DateTime.tryParse(m.group(2)!);
    if (start == null || end == null) return firstLine;
    final days = end.difference(start).inDays + 1;
    const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final s = '${mo[start.month - 1]} ${start.day}';
    final e = '${mo[end.month - 1]} ${end.day}';
    return '$s → $e · $days ${days == 1 ? 'day' : 'days'}';
  }

  factory SittingPet.fromJson(Map<String, dynamic> j) {
    final rawNotes = j['sittingNotes'] as String? ?? '';
    final parts = rawNotes.split('\n');
    final duration = _fmtDateRange(parts.isNotEmpty ? parts.first : '');
    final restNotes = parts.length > 1 ? parts.skip(1).join('\n').trim() : null;

    final rate = j['payRatePerDay'];
    final priceStr = rate != null ? '${(rate as num).toInt()} EGP/day' : null;

    final rawPhoto = j['photo'] as String?;
    String? imageUrl;
    if (rawPhoto != null && rawPhoto.isNotEmpty) {
      imageUrl = rawPhoto.startsWith('http')
          ? rawPhoto
          : '${ApiClient.baseUrl}$rawPhoto';
    }

    final rawGender = j['gender'] as String?;
    final gender = rawGender == 'FEMALE' ? 'Female' : 'Male';

    final rawAge = j['age'];
    final age = rawAge != null ? (rawAge as num).toInt() : null;

    final rawType = (j['petType'] as String?)?.toUpperCase() ?? 'DOG';
    final petType = rawType == 'CAT' ? 'CAT' : 'DOG';

    return SittingPet(
      id: j['id'] as String? ?? '',
      name: j['name'] as String? ?? '',
      duration: duration,
      city: j['ownerAddress'] as String? ?? '',
      gender: gender,
      petType: petType,
      pricePerDay: priceStr,
      imageUrl: imageUrl,
      isOwn: j['isOwn'] as bool? ?? false,
      ownerName: j['ownerName'] as String? ?? '',
      ownerId: j['ownerId'] as String? ?? '',
      breed: j['breed'] as String?,
      age: age,
      fullNotes: restNotes?.isNotEmpty == true ? restNotes : null,
    );
  }
}
