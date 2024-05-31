import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:caregiver_dashboard/models/medication.dart';
import 'package:caregiver_dashboard/services/medication_service.dart';
import 'package:caregiver_dashboard/nav_bar.dart';

class AddMedicationScreen extends StatefulWidget {
  final int profileId;

  AddMedicationScreen({required this.profileId});

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _medicationName = '';
  String _dosage = '';
  int _frequencyPerDay = 1;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  void _saveMedication() async {
    if (_formKey.currentState!.validate()) {
      final newMedication = Medication(
        medicationId: 0, // Will be set by the database
        name: _medicationName,
        dosage: _dosage,
        frequencyPerDay: _frequencyPerDay,
        startDate: _startDate,
        endDate: _endDate,
        profileId: widget.profileId,
        schedules: [],
      );

      try {
        await MedicationService.addMedication(newMedication);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication added successfully')),
        );
      } catch (e) {
        print('Error adding medication: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add medication')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Medication'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Medication Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a medication name';
                      }
                      return null;
                    },
                    onSaved: (value) => _medicationName = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Dosage (mg)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a dosage';
                      }
                      return null;
                    },
                    onSaved: (value) => _dosage = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Frequency Per Day'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter frequency per day';
                      }
                      return null;
                    },
                    onSaved: (value) => _frequencyPerDay = int.parse(value!),
                  ),
                  DatePicker(
                    selectedDate: _startDate,
                    label: 'Start Date',
                    onDateChanged: (value) => setState(() => _startDate = value),
                  ),
                  DatePicker(
                    selectedDate: _endDate,
                    label: 'End Date',
                    onDateChanged: (value) => setState(() => _endDate = value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _saveMedication();
                          }
                        },
                        child: const Text('Add'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          _formKey.currentState!.reset();
                          setState(() {
                            _startDate = DateTime.now();
                            _endDate = DateTime.now();
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
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
