class PetModel {
  final String id;
  final String name;
  final String? breed;
  final int? age;
  final String? gender;

  const PetModel({
    required this.id,
    required this.name,
    this.breed,
    this.age,
    this.gender,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) => PetModel(
        id: json['id'] as String,
        name: json['name'] as String,
        breed: json['breed'] as String?,
        age: json['age'] as int?,
        gender: json['gender'] as String?,
      );

  String get displayLabel {
    final parts = [name, if (breed != null) breed!];
    return parts.join(' · ');
  }
}
