import 'package:caregiver_dashboard/models/medication_schedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:caregiver_dashboard/models/medication.dart';
import 'package:caregiver_dashboard/services/medication_service.dart';
import 'package:caregiver_dashboard/nav_bar.dart';

class EditMedicationsScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  EditMedicationsScreen({required this.arguments});

  @override
  _EditMedicationsScreenState createState() => _EditMedicationsScreenState();
}

class _EditMedicationsScreenState extends State<EditMedicationsScreen> {
  late int profileId;
  List<Medication> medications = [];
  int currentMedicationIndex = 0;

  @override
  void initState() {
    super.initState();
    profileId = widget.arguments['profileId'];
    fetchMedications();
  }

  fetchMedications() async {
    try {
      final response = await MedicationService.getMedications(profileId);
      setState(() {
        medications = response;
      });
    } catch (e) {
      print('Failed to load medications: $e');
    }
  }

  void _saveChanges() async {
    try {
      final medication = medications[currentMedicationIndex];
      print('Updating medication data: ${medication.toJson()}');
      await MedicationService.updateMedication(medication);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication updated successfully')),
      );
    } catch (e) {
      print('Error updating medication: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update medication')),
      );
    }
  }

  void _deleteMedication() async {
    final medication = medications[currentMedicationIndex];
    try {
      await MedicationService.deleteMedication(medication.medicationId);
      setState(() {
        medications.removeAt(currentMedicationIndex);
        if (currentMedicationIndex > 0) {
          currentMedicationIndex--;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication deleted successfully')),
      );
    } catch (e) {
      print('Error deleting medication: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete medication')),
      );
    }
  }

  void _navigateToPreviousMedication() {
    if (currentMedicationIndex > 0) {
      setState(() {
        currentMedicationIndex--;
      });
    }
  }

  void _navigateToNextMedication() {
    if (currentMedicationIndex < medications.length - 1) {
      setState(() {
        currentMedicationIndex++;
      });
    }
  }

  void _navigateToAddMedication() {
    Navigator.pushNamed(
      context,
      '/add-medication',
      arguments: {'profileId': profileId},
    ).then((_) {
      fetchMedications(); // Refresh the list after returning from add medication screen
    });
  }

  @override
  Widget build(BuildContext context) {
    if (medications.isEmpty) {
      return NavBar(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit Medications'),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final currentMedication = medications[currentMedicationIndex];

    return NavBar(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Medications'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Text(
                  'Editing Medication ${currentMedicationIndex + 1} of ${medications.length}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: currentMedication.name,
                  decoration: const InputDecoration(labelText: 'Medication Name'),
                  onChanged: (value) => setState(() => currentMedication.name = value),
                ),
                TextFormField(
                  initialValue: currentMedication.dosage,
                  decoration: const InputDecoration(labelText: 'Dosage (mg)'),
                  onChanged: (value) => setState(() => currentMedication.dosage = value),
                ),
                TextFormField(
                  initialValue: currentMedication.frequencyPerDay.toString(),
                  decoration: const InputDecoration(labelText: 'Frequency Per Day'),
                  onChanged: (value) => setState(() => currentMedication.frequencyPerDay = int.parse(value)),
                ),
                DatePicker(
                  selectedDate: currentMedication.startDate,
                  label: 'Start Date',
                  onDateChanged: (value) => setState(() => currentMedication.startDate = value),
                ),
                DatePicker(
                  selectedDate: currentMedication.endDate,
                  label: 'End Date',
                  onDateChanged: (value) => setState(() => currentMedication.endDate = value),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Medication Schedules',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ...currentMedication.schedules.map((schedule) {
                  return TimePicker(
                    selectedTime: TimeOfDay(
                      hour: int.parse(schedule.scheduledTime.split(':')[0]),
                      minute: int.parse(schedule.scheduledTime.split(':')[1]),
                    ),
                    onTimeChanged: (value) {
                      setState(() {
                        final hours = value.hour.toString().padLeft(2, '0');
                        final minutes = value.minute.toString().padLeft(2, '0');
                        schedule.scheduledTime = '$hours:$minutes';
                      });
                    },
                  );
                }).toList(),
                ElevatedButton(
                  onPressed: () {
                    // Add a new schedule
                    final newSchedule = MedicationSchedule(
                      scheduleId: 0,
                      scheduledTime: '00:00', // Set to a default valid time
                      patientMedicationId: currentMedication.medicationId,
                    );
                    setState(() {
                      currentMedication.schedules.add(newSchedule);
                    });
                  },
                  child: const Text('Add Medication Schedule'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text('Save Changes'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _deleteMedication,
                      child: const Text('Delete Medication'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _navigateToAddMedication,
                      child: const Text('Add Medication'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _navigateToPreviousMedication,
                      child: const Text('Previous Medication'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _navigateToNextMedication,
                      child: const Text('Next Medication'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DatePicker extends StatelessWidget {
  final DateTime selectedDate;
  final String label;
  final ValueChanged<DateTime> onDateChanged;

  DatePicker({
    required this.selectedDate,
    required this.label,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != selectedDate) {
              onDateChanged(picked);
            }
          },
          child: Text(
            DateFormat('yyyy-MM-dd').format(selectedDate),
          ),
        ),
      ],
    );
  }
}

class TimePicker extends StatelessWidget {
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  TimePicker({
    required this.selectedTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Time:'),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: selectedTime,
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                );
              },
            );
            if (picked != null && picked != selectedTime) {
              onTimeChanged(picked);
            }
          },
          child: Text(
            selectedTime.format(context),
          ),
        ),
      ],
    );
  }
}
