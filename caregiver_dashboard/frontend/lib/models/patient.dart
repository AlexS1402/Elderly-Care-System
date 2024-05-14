class Patient {
  final int patientId;
  final int userId;
  final String firstName;
  final String lastName;
  final String dob;
  final String gender;
  final String address;
  final String emergencyContact;

  Patient({
    required this.patientId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.dob,
    required this.gender,
    required this.address,
    required this.emergencyContact,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patientId'],
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dob: json['dob'],
      gender: json['gender'],
      address: json['address'],
      emergencyContact: json['emergencyContact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'dob': dob,
      'gender': gender,
      'address': address,
      'emergencyContact': emergencyContact,
    };
  }
}