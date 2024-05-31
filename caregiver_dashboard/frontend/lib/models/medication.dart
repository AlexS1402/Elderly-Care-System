import 'medication_schedule.dart';

class Medication {
  int medicationId;
  String name;
  String dosage;
  int frequencyPerDay;
  DateTime startDate;
  DateTime endDate;
  int profileId;
  List<MedicationSchedule> schedules;

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
      startDate: DateTime.parse(json['StartDate']),
      endDate: DateTime.parse(json['EndDate']),
      profileId: json['ProfileID'],
      schedules: (json['MedicationSchedules'] as List)
          .map((schedule) => MedicationSchedule.fromJson(schedule))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PatientMedicationID': medicationId,
      'MedicationName': name,
      'Dosage': dosage,
      'FrequencyPerDay': frequencyPerDay,
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate.toIso8601String(),
      'ProfileID': profileId,
      'MedicationSchedules': schedules.map((schedule) => schedule.toJson()).toList(),
    };
  }
}
