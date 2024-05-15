import 'medication_schedule.dart';

class Medication {
  final int medicationId;
  final String name;
  final String dosage;
  final int frequencyPerDay;
  final String startDate;
  final String endDate;
  final int profileId;
  final List<MedicationSchedule> schedules;

  Medication({
    required this.medicationId,
    required this.name,
    required this.dosage,
    required this.frequencyPerDay,
    required this.startDate,
    required this.endDate,
    required this.profileId,
    required this.schedules,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      medicationId: json['PatientMedicationID'],
      name: json['MedicationName'],
      dosage: json['Dosage'],
      frequencyPerDay: json['FrequencyPerDay'],
      startDate: json['StartDate'],
      endDate: json['EndDate'],
      profileId: json['ProfileID'],
      schedules: (json['MedicationSchedules'] as List)
          .map((schedule) => MedicationSchedule.fromJson(schedule))
          .toList(),
    );
  }
}
