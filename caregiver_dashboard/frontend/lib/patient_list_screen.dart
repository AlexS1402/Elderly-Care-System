import 'package:flutter/material.dart';
import 'package:caregiver_dashboard/services/patient_service.dart';
import 'package:caregiver_dashboard/models/patient.dart';
import 'package:caregiver_dashboard/nav_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // Ensure this import for date formatting

class PatientListScreen extends StatefulWidget {
  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  List<Patient> patients = [];
  int currentPage = 1;
  int totalPages = 1;
  String searchQuery = '';
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  fetchPatients() async {
    String? userId = await storage.read(key: 'userId');
    if (userId == null) {
      print('No user ID found in storage');
      return;
    }

    try {
      final response = await PatientService.getPatientsForCaregiver(
          int.parse(userId), searchQuery, currentPage, 8);
      setState(() {
        patients = response['patients'];
        totalPages = response['totalPages'];
      });
    } catch (e) {
      print('Failed to load patients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Patient List'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                children: [
                  const Text(
                    'Patient List Page',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(color: Colors.blue),
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(color: Colors.blue),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Patient Name',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'DOB',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Gender',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Emergency Contact',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Address',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'See Patient Details',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      for (var patient in patients)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  '${patient.firstName} ${patient.lastName}'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  DateFormat('yyyy-MM-dd').format(patient.dob)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(patient.gender),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(patient.emergencyContact),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(patient.address),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(Icons.info),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/patient-detail',
                                    arguments: patient.profileId,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: currentPage > 1
                            ? () {
                                setState(() {
                                  currentPage--;
                                  fetchPatients();
                                });
                              }
                            : null,
                        child: const Text('Previous'),
                      ),
                      const SizedBox(width: 10),
                      Text('Page $currentPage of $totalPages'),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: currentPage < totalPages
                            ? () {
                                setState(() {
                                  currentPage++;
                                  fetchPatients();
                                });
                              }
                            : null,
                        child: const Text('Next'),
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
