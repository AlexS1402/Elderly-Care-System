class AlertLog {
  final int alertId;
  final DateTime alertTimestamp;
  final String alertType;
  final int profileId;
  final bool resolved;
  final String patientFirstName;
  final String patientLastName;
  final String emergencyContact;

  AlertLog({
    required this.alertId,
    required this.alertTimestamp,
    required this.alertType,
    required this.profileId,
    required this.resolved,
    required this.patientFirstName,
    required this.patientLastName,
    required this.emergencyContact,
  });

  factory AlertLog.fromJson(Map<String, dynamic> json) {
    return AlertLog(
      alertId: json['AlertID'],
      alertTimestamp: DateTime.parse(json['AlertTimestamp']),
      alertType: json['AlertType'],
      profileId: json['ProfileID'],
      resolved: json['Resolved'],
      patientFirstName: json['PatientProfile']['FirstName'],
      patientLastName: json['PatientProfile']['LastName'],
      emergencyContact: json['PatientProfile']['EmergencyContact'],
    );
  }
}
