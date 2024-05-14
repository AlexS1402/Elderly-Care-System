import 'package:flutter/material.dart';
import 'package:caregiver_dashboard/services/alert_service.dart';
import 'package:caregiver_dashboard/nav_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> alertLogs = [];
  int currentPage = 1;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    fetchAlertLogs();
  }

  fetchAlertLogs() async {
    try {
      final logs = await AlertService.getAlertLogs();
      setState(() {
        alertLogs = logs;
        totalPages = (logs.length / 5).ceil();
      });
    } catch (e) {
      print('Failed to load alert logs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Welcome to the Caregiver Dashboard',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  'Alert Logs',
                  style: TextStyle(fontSize: 20, color: Colors.blue),
                ),
                SizedBox(height: 8),
                Table(
                  border: TableBorder.all(color: Colors.blue),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.blue),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Patient Name',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Timestamp',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Type',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Emergency Contact',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    for (var log in alertLogs)
                      TableRow(
                        decoration: BoxDecoration(
                          color: log['Resolved'] == 0 ? Colors.red[100] : Colors.white,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('${log['PatientProfile']['FirstName']} ${log['PatientProfile']['LastName']}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(log['AlertTimestamp']),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(log['AlertType']),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(log['PatientProfile']['EmergencyContact']),
                          ),
                        ],
                      ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: currentPage > 1
                          ? () {
                              setState(() {
                                currentPage--;
                                fetchAlertLogs();
                              });
                            }
                          : null,
                      child: Text('Previous'),
                    ),
                    SizedBox(width: 10),
                    Text('Page $currentPage of $totalPages'),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: currentPage < totalPages
                          ? () {
                              setState(() {
                                currentPage++;
                                fetchAlertLogs();
                              });
                            }
                          : null,
                      child: Text('Next'),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Text(
                  'FAQ',
                  style: TextStyle(fontSize: 20, color: Colors.blue),
                ),
                SizedBox(height: 8),
                Text(
                  'Here you will find answers to the most frequently asked questions...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
