import 'medication.dart';

class Patient {
  final int profileId;
  final String firstName;
  final String lastName;
  final DateTime dob;
  final String gender;
  final String address;
  final String emergencyContact;
  final List<Medication> medications;

  Patient({
    required this.profileId,
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
      profileId: json['ProfileID'],
      firstName: json['FirstName'],
      lastName: json['LastName'],
      dob: DateTime.parse(json['DOB']),
      gender: json['Gender'],
      address: json['Address'],
      emergencyContact: json['EmergencyContact'],
      medications: (json['PatientMedications'] as List)
          .map((med) => Medication.fromJson(med))
          .toList(),
    );
  }
}
