import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/patient.dart';

class PatientService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';
  static final storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await storage.read(key: 'jwt');
  }

  static Future<List<Patient>> getPatientsForCaregiver(int userId) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/patients/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Patient> patients = body.map((dynamic item) => Patient.fromJson(item)).toList();
      return patients;
    } else {
      throw Exception('Failed to load patients');
    }
  }

  static Future<Patient> getPatientDetails(int patientId) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/patients/detail/$patientId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      return Patient.fromJson(body);
    } else {
      throw Exception('Failed to load patient details');
    }
  }
}
