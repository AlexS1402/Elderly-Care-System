import 'medication.dart';

class Patient {
  int profileId;
  int userId;
  String firstName;
  String lastName;
  DateTime dob;
  String gender;
  String address;
  String emergencyContact;
  List<Medication> medications;

  Patient({
    required this.profileId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.gender,
    required this.address,
    required this.emergencyContact,
    this.medications = const [],
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      profileId: json['ProfileID'] ?? 0,
      userId: json['UserId'] ?? 0,
      firstName: json['FirstName'] ?? '',
      lastName: json['LastName'] ?? '',
      dob: DateTime.parse(json['DOB'] ?? '1970-01-01'),
      gender: json['Gender'] ?? 'Unknown',
      address: json['Address'] ?? '',
      emergencyContact: json['EmergencyContact'] ?? '',
      medications: (json['PatientMedications'] != null ? json['PatientMedications'] as List : [])
          .map((med) => Medication.fromJson(med))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob.toIso8601String(),  // Ensure date is properly formatted
      'gender': gender,
      'address': address,
      'emergencyContact': emergencyContact,
    };
  }
}
