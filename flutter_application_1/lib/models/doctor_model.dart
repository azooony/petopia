class ClinicModel {
  final String id;
  final String name;
  final String address;
  final String? phone;

  const ClinicModel({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
  });

  factory ClinicModel.fromJson(Map<String, dynamic> json) => ClinicModel(
        id: json['id'] as String,
        name: json['name'] as String,
        address: json['address'] as String,
        phone: json['phone'] as String?,
      );
}

class AvailabilitySlot {
  final String id;
  final DateTime startTime;
  final DateTime endTime;

  const AvailabilitySlot({
    required this.id,
    required this.startTime,
    required this.endTime,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) =>
      AvailabilitySlot(
        id: json['id'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
      );
}

class VetProfile {
  final String id;
  final String? phone;
  final String? description;
  final int? yearsOfExperience;
  final double appointmentPrice;
  final String startTime;
  final String endTime;
  final String? photo;
  final String? specialization;
  final ClinicModel clinic;

  const VetProfile({
    required this.id,
    this.phone,
    this.description,
    this.yearsOfExperience,
    required this.appointmentPrice,
    required this.startTime,
    required this.endTime,
    this.photo,
    this.specialization,
    required this.clinic,
  });

  factory VetProfile.fromJson(Map<String, dynamic> json) => VetProfile(
        id: json['id'] as String,
        phone: json['phone'] as String?,
        description: json['description'] as String?,
        yearsOfExperience: json['yearsOfExperience'] as int?,
        appointmentPrice: (json['appointmentPrice'] as num).toDouble(),
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
        photo: json['photo'] as String?,
        specialization: json['specialization'] as String?,
        clinic: ClinicModel.fromJson(json['clinic'] as Map<String, dynamic>),
      );
}

class DoctorModel {
  final String id;
  final String fullName;
  final String email;
  final VetProfile vetProfile;
  final List<AvailabilitySlot> availabilitySlots;

  const DoctorModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.vetProfile,
    required this.availabilitySlots,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) => DoctorModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        vetProfile:
            VetProfile.fromJson(json['vetProfile'] as Map<String, dynamic>),
        availabilitySlots: (json['availabilitySlots'] as List<dynamic>)
            .map((s) =>
                AvailabilitySlot.fromJson(s as Map<String, dynamic>))
            .toList(),
      );

  String get displayFee => '${vetProfile.appointmentPrice.toInt()} EGP';
  String get workingHours => '${vetProfile.startTime} – ${vetProfile.endTime}';
}
