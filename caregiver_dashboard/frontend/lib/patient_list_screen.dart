import 'package:flutter/material.dart';
import 'package:caregiver_dashboard/services/patient_service.dart';
import 'package:caregiver_dashboard/models/patient.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PatientListScreen extends StatefulWidget {
  @override
  _PatientListScreenState createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final storage = FlutterSecureStorage();
  List<Patient> patients = [];

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
      final List<Patient> fetchedPatients = await PatientService.getPatientsForCaregiver(int.parse(userId));
      setState(() {
        patients = fetchedPatients;
      });
    } catch (e) {
      print('Failed to load patients: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient List'),
      ),
      body: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return Column(
            children: [
              ListTile(
                title: Text(
                  '${patient.firstName} ${patient.lastName}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(patient.dob),
                trailing: IconButton(
                  icon: Icon(Icons.info),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/patient-detail',
                      arguments: patient.patientId,
                    );
                  },
                ),
              ),
              Divider(
                thickness: 1,
                indent: 20,
                endIndent: 20,
              ),
            ],
          );
        },
      ),
    );
  }
}
