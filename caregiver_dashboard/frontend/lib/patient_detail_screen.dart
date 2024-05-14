import 'package:flutter/material.dart';
import 'package:caregiver_dashboard/services/patient_service.dart';
import 'package:caregiver_dashboard/models/patient.dart';

class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int patientId = ModalRoute.of(context)!.settings.arguments as int;

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
      ),
      body: FutureBuilder<Patient>(
        future: PatientService.getPatientDetails(patientId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading patient details'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No patient found'));
          }

          final patient = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${patient.firstName} ${patient.lastName}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('DOB: ${patient.dob}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Gender: ${patient.gender}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Address: ${patient.address}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Emergency Contact: ${patient.emergencyContact}', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );
  }
}
