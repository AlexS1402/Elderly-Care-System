import 'package:flutter/material.dart';
import 'package:caregiver_dashboard/services/alert_service.dart';
import 'package:caregiver_dashboard/nav_bar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> alertLogs = [];
  int currentPage = 1;
  int totalPages = 1;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchAlertLogs();
  }

  fetchAlertLogs() async {
    String? userId = await storage.read(key: 'userId');
    if (userId == null) {
      print('No user ID found in storage');
      return;
    }

    try {
      final response = await AlertService.getAlertLogs(int.parse(userId), currentPage);
      setState(() {
        alertLogs = List<Map<String, dynamic>>.from(response['logs']);
        totalPages = response['totalPages'];
      });
    } catch (e) {
      print('Failed to load alert logs: $e');
    }
  }

  String _formatDate(String dateStr) {
    final DateTime dateTime = DateTime.parse(dateStr);
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(dateTime);
  }

  Future<void> _resolveAlert(int alertId) async {
    try {
      await AlertService.resolveAlert(alertId);
      fetchAlertLogs();
    } catch (e) {
      print('Failed to resolve alert: $e');
    }
  }

  void _showResolveDialog(int alertId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Resolve Alert'),
          content: Text('Are you sure you would like to mark this alert as resolved?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resolveAlert(alertId);
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Resolved',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        for (var log in alertLogs)
                          TableRow(
                            decoration: BoxDecoration(
                              color: log['Resolved'] ? Colors.white : Colors.red[100],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  child: Text(
                                    '${log['PatientProfile']['FirstName']} ${log['PatientProfile']['LastName']}',
                                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/patient-detail',
                                      arguments: log['PatientProfile']['ProfileID'],
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(_formatDate(log['AlertTimestamp'])),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(log['AlertType']),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(log['PatientProfile']['EmergencyContact']),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: log['Resolved']
                                    ? Text(
                                        'YES',
                                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                      )
                                    : Row(
                                        children: [
                                          Text(
                                            'NO',
                                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                          ),
                                          Checkbox(
                                            value: false,
                                            onChanged: (bool? value) {
                                              _showResolveDialog(log['AlertID']);
                                            },
                                          ),
                                        ],
                                      ),
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
        ),
      ),
    );
  }
}
