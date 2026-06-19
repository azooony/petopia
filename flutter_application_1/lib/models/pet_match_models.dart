// Models matching schema.prisma field names exactly.

// ── Current user's pet (from /users/me → data.pets[0]) ───────────────────────

class MyPet {
  final String  id;
  final String  name;
  final String? breed;
  final int     age;
  final String? gender;       // 'MALE' | 'FEMALE'
  final String? description;
  final String? photo;

  const MyPet({
    required this.id,
    required this.name,
    this.breed,
    required this.age,
    this.gender,
    this.description,
    this.photo,
  });

  factory MyPet.fromJson(Map<String, dynamic> j) => MyPet(
        id:          j['id']          as String,
        name:        j['name']        as String,
        breed:       j['breed']       as String?,
        age:         (j['age'] as num?)?.toInt() ?? 0,
        gender:      j['gender']      as String?,
        description: j['description'] as String?,
        photo:       j['photo']       as String?,
      );
}

// ── Existing match profile (from /matching/profile/:petId → data.profile) ────

class MyMatchProfile {
  final String  id;
  final String  petId;
  final String? description;
  final String? address;
  final String? preferredBreed;
  final bool    isAvailable;

  const MyMatchProfile({
    required this.id,
    required this.petId,
    this.description,
    this.address,
    this.preferredBreed,
    required this.isAvailable,
  });

  factory MyMatchProfile.fromJson(Map<String, dynamic> j) => MyMatchProfile(
        id:             j['id']             as String,
        petId:          j['petId']          as String,
        description:    j['description']    as String?,
        address:        j['address']        as String?,
        preferredBreed: j['preferredBreed'] as String?,
        isAvailable:    j['isavailable']    as bool? ?? true,
      );
}

// ── Bundled result returned by PetMatchingService.getMyPetForMatching() ───────

class PetForMatching {
  final MyPet          pet;
  final String         userAddress;
  final MyMatchProfile? profile;

  const PetForMatching({
    required this.pet,
    required this.userAddress,
    this.profile,
  });
}

// ── Discover list item (from /matching/discover/:petId → data[]) ──────────────

class MatchPet {
  final String  profileId;
  final String  petId;
  final String  petName;
  final int     petAge;
  final String? petBreed;
  final String? petGender;   // 'MALE' | 'FEMALE'
  final String? description;
  final String? address;
  final String? imageUrl;
  final String  ownerId;
  final String  ownerName;

  const MatchPet({
    required this.profileId,
    required this.petId,
    required this.petName,
    required this.petAge,
    this.petBreed,
    this.petGender,
    this.description,
    this.address,
    this.imageUrl,
    required this.ownerId,
    required this.ownerName,
  });

  factory MatchPet.fromJson(Map<String, dynamic> j) {
    final pet    = j['pet']    as Map<String, dynamic>? ?? {};
    final owner  = pet['owner'] as Map<String, dynamic>? ?? {};
    final images = pet['images'] as List<dynamic>? ?? [];

    // Resolution order: isPrimary image → first image → pet.photo
    String? imageUrl;
    for (final img in images) {
      final m = img as Map<String, dynamic>;
      if (m['isPrimary'] == true) {
        imageUrl = (m['asset'] as Map<String, dynamic>?)?['url'] as String?;
        break;
      }
    }
    if (imageUrl == null && images.isNotEmpty) {
      imageUrl = ((images.first as Map<String, dynamic>)['asset']
          as Map<String, dynamic>?)?['url'] as String?;
    }
    imageUrl ??= pet['photo'] as String?;

    return MatchPet(
      profileId:   j['id']           as String,
      petId:       j['petId']        as String,
      petName:     pet['name']       as String? ?? 'Unknown',
      petAge:      (pet['age'] as num?)?.toInt() ?? 0,
      petBreed:    pet['breed']      as String?,
      petGender:   pet['gender']     as String?,
      description: (pet['description'] as String?) ?? (j['description'] as String?),
      address:     j['address']      as String?,
      imageUrl:    imageUrl,
      ownerId:     owner['id']       as String? ?? '',
      ownerName:   owner['fullName'] as String? ?? '',
    );
  }
}
