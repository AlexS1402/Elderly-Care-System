import 'package:flutter/material.dart';
import 'package:caregiver_dashboard/services/patient_service.dart';
import 'package:caregiver_dashboard/models/patient.dart';
import 'package:caregiver_dashboard/nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PatientDetailScreen extends StatefulWidget {
  const PatientDetailScreen({super.key});

  @override
  _PatientDetailScreenState createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  Future<Patient>? patientFuture;
  String currentSection = 'Profile';
  final storage = FlutterSecureStorage();
  DateTime selectedDate = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (patientFuture == null) {
      final int patientId = ModalRoute.of(context)!.settings.arguments as int;
      patientFuture = PatientService.getPatientDetails(patientId);
    }
  }

  void _showScheduleDialog(BuildContext context, List schedules) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Medication Schedules'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: schedules.map<Widget>((schedule) {
              return Text(schedule.scheduledTime);
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileSection(Patient patient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Patient Details:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Divider(color: Colors.black),
        SizedBox(height: 8),
        _buildInfoRow(Icons.cake, 'Date of Birth', DateFormat('dd-MM-yyyy').format(patient.dob)),
        _buildInfoRow(Icons.person, 'Gender', patient.gender),
        _buildInfoRow(Icons.location_on, 'Address', patient.address),
        _buildInfoRow(Icons.contact_phone, 'Emergency Contact', patient.emergencyContact),
      ],
    );
  }

  Widget _buildMedicationSection(Patient patient) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Medication:', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Divider(color: Colors.black),
        if (patient.medications.isEmpty)
          Text('No Medications Found.', style: TextStyle(fontSize: 18))
        else
          Column(
            children: patient.medications.map((medication) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.local_hospital, 'Medication Name', medication.name),
                  _buildInfoRow(Icons.format_list_numbered, 'Dosage', medication.dosage),
                  _buildInfoRow(Icons.schedule, 'Frequency Per Day', '${medication.frequencyPerDay}'),
                  GestureDetector(
                    onTap: () => _showScheduleDialog(context, medication.schedules),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          'See more details...',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> fetchHeartRateData(int profileId, DateTime date) async {
    String? token = await storage.read(key: 'jwt');
    final response = await http.get(
      Uri.parse('http://localhost:3000/api/sensorData/$profileId/heartRate?date=${DateFormat('yyyy-MM-dd').format(date)}'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load heart rate data');
    }
  }

  Widget _buildHeartRateChart(List<Map<String, dynamic>> data) {
    // Filter out invalid data points and round the values
    List<FlSpot> validSpots = data.map((point) {
      final DateTime date = DateTime.parse(point['timeInterval']);
      final double avgHeartRate = double.parse((point['avgHeartRate'] as num).toStringAsFixed(2));
      return FlSpot(date.hour.toDouble(), avgHeartRate);
    }).where((spot) => spot.x.isFinite && spot.y.isFinite).toList();

    if (validSpots.isEmpty) {
      return Center(child: Text('No valid heart rate data available.'));
    }

    return SizedBox(
      height: 300, // Ensure the chart has a fixed height
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                if (value.isFinite) {
                  return Text(value.toString());
                } else {
                  return Text('');
                }
              }),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                if (value.isFinite) {
                  return Text('${value.toInt()}:00');
                } else {
                  return Text('');
                }
              }),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: validSpots,
              isCurved: true,
              color: Colors.red,
              barWidth: 2,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorDataSection(int profileId) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedDate = selectedDate.subtract(Duration(days: 1));
                });
              },
              child: Text('Previous Day'),
            ),
            Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
            TextButton(
              onPressed: () {
                setState(() {
                  selectedDate = selectedDate.add(Duration(days: 1));
                });
              },
              child: Text('Next Day'),
            ),
          ],
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchHeartRateData(profileId, selectedDate),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading heart rate data'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No heart rate data found'));
            }

            return _buildHeartRateChart(snapshot.data!);
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool underline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Text('$label:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Text(value, style: TextStyle(fontSize: 18, decoration: underline ? TextDecoration.underline : TextDecoration.none)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Patient Details'),
        ),
        body: FutureBuilder<Patient>(
          future: patientFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading patient details'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No patient found'));
            }

            final patient = snapshot.data!;

            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.7,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${patient.firstName} ${patient.lastName}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    Divider(color: Colors.black),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentSection = 'Profile';
                            });
                          },
                          child: Text('Profile', style: TextStyle(color: currentSection == 'Profile' ? Colors.blue : Colors.black)),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentSection = 'Medication';
                            });
                          },
                          child: Text('Medication', style: TextStyle(color: currentSection == 'Medication' ? Colors.blue : Colors.black)),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              currentSection = 'Heart Rate Data';
                            });
                          },
                          child: Text('Heart Rate Data', style: TextStyle(color: currentSection == 'Heart Rate Data' ? Colors.blue : Colors.black)),
                        ),
                      ],
                    ),
                    Divider(color: Colors.black),
                    if (currentSection == 'Profile') _buildProfileSection(patient),
                    if (currentSection == 'Medication') _buildMedicationSection(patient),
                    if (currentSection == 'Heart Rate Data') _buildSensorDataSection(patient.profileId),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
