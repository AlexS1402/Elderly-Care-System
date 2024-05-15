class MedicationSchedule {
  final int scheduleId;
  final String scheduledTime;
  final int patientMedicationId;

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
}
