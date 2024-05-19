import 'package:flutter/material.dart';
import 'package:caregiver_dashboard/services/patient_service.dart';
import 'package:caregiver_dashboard/models/patient.dart';
import 'package:caregiver_dashboard/nav_bar.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Patient> patients = [];
  List<Patient> filteredPatients = [];
  final searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  fetchPatients() async {
    try {
      final response = await PatientService.getAllPatients();
      setState(() {
        patients = response;
        filteredPatients = response;
      });
    } catch (e) {
      print('Failed to load patients: $e');
    }
  }

  void _filterPatients() {
    setState(() {
      filteredPatients = patients.where((patient) {
        return patient.firstName
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            patient.lastName
                .toLowerCase()
                .contains(searchController.text.toLowerCase());
      }).toList();
    });
  }

  void _saveChanges(Patient patient) async {
    try {
      print('Updating patient data: ${patient.toJson()}');
      print('Saving changes for patient ID: ${patient.profileId}');
      print('UserId: ${patient.userId}');
      print('FirstName: ${patient.firstName}');
      print('LastName: ${patient.lastName}');
      print('DOB: ${DateFormat('yyyy-MM-dd').format(patient.dob)}');
      print('Gender: ${patient.gender}');
      print('Address: ${patient.address}');
      print('EmergencyContact: ${patient.emergencyContact}');

      patient.dob = DateFormat('yyyy-MM-dd')
          .parse(DateFormat('yyyy-MM-dd').format(patient.dob));

      await PatientService.updatePatient(patient);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );
    } catch (e) {
      print('Failed to save changes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save changes')),
      );
    }
  }

  void _deletePatient(Patient patient) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${patient.firstName} ${patient.lastName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed) {
      try {
        await PatientService.deletePatient(patient.profileId);
        setState(() {
          patients.remove(patient);
          filteredPatients.remove(patient);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient deleted successfully')),
        );
      } catch (e) {
        print('Failed to delete patient: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete patient')),
        );
      }
    }
  }

  void _navigateToEditMedications(int profileId) {
    Navigator.pushNamed(
      context,
      '/edit-medications',
      arguments: profileId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Admin Dashboard',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search Patients',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _filterPatients();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context,
                            '/add-patient'); // Navigate to add patient screen
                      },
                      child: const Text('Add Patient'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Table(
                      border: TableBorder.all(color: Colors.blue),
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                        4: FlexColumnWidth(1.5),
                        5: FlexColumnWidth(2),
                        6: FlexColumnWidth(2),
                        7: FlexColumnWidth(1),
                        8: FlexColumnWidth(1),
                        9: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(color: Colors.blue),
                          children: [
                            _buildTableHeader('Caregiver Assigned'),
                            _buildTableHeader('First Name'),
                            _buildTableHeader('Last Name'),
                            _buildTableHeader('Gender'),
                            _buildTableHeader('DOB'),
                            _buildTableHeader('Address'),
                            _buildTableHeader('Emergency Contact'),
                            _buildTableHeader('Edit Medications'),
                            _buildTableHeader('Save'),
                            _buildTableHeader('Delete'),
                          ],
                        ),
                        for (var patient in filteredPatients)
                          TableRow(
                            children: [
                              _buildEditableCell(patient.userId.toString(),
                                  (value) {
                                setState(() {
                                  patient.userId = int.parse(value);
                                });
                              }),
                              _buildEditableCell(patient.firstName, (value) {
                                setState(() {
                                  patient.firstName = value;
                                });
                              }),
                              _buildEditableCell(patient.lastName, (value) {
                                setState(() {
                                  patient.lastName = value;
                                });
                              }),
                              _buildEditableCell(patient.gender, (value) {
                                setState(() {
                                  patient.gender = value;
                                });
                              }),
                              _buildEditableCell(
                                  DateFormat('yyyy-MM-dd').format(patient.dob),
                                  (value) {
                                setState(() {
                                  patient.dob =
                                      DateFormat('yyyy-MM-dd').parse(value);
                                });
                              }),
                              _buildEditableCell(patient.address, (value) {
                                setState(() {
                                  patient.address = value;
                                });
                              }),
                              _buildEditableCell(patient.emergencyContact,
                                  (value) {
                                setState(() {
                                  patient.emergencyContact = value;
                                });
                              }),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _navigateToEditMedications(patient.profileId);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.save),
                                onPressed: () {
                                  _saveChanges(patient);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deletePatient(patient);
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEditableCell(String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        initialValue: value,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}
