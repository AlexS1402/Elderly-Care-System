class MedicationSchedule {
  int scheduleId;
  String scheduledTime;
  int patientMedicationId;

  MedicationSchedule({
    required this.scheduleId,
    required this.scheduledTime,
    required this.patientMedicationId,
  });

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) {
    return MedicationSchedule(
      scheduleId: json['ScheduleID'],
      scheduledTime: json['ScheduledTime'],
      patientMedicationId: json['PatientMedicationID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ScheduleID': scheduleId,
      'ScheduledTime': scheduledTime,
      'PatientMedicationID': patientMedicationId,
    };
  }
}
