import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/patient.dart';
import '../models/medication.dart';
import '../models/sensor_data.dart';

class PatientService {
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';
  static final storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await storage.read(key: 'jwt');
  }

  static Future<Map<String, dynamic>> getPatientsForCaregiver(
      int userId, String searchQuery, int page, int pageSize) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse(
          '$baseUrl/patients/$userId?search=$searchQuery&page=$page&pageSize=$pageSize'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      final patients = (jsonResponse['patients'] as List)
          .map((patientJson) => Patient.fromJson(patientJson))
          .toList();
      return {
        'patients': patients,
        'totalPages': jsonResponse['totalPages'],
      };
    } else {
      throw Exception('Failed to load patients');
    }
  }

  static Future<List<Patient>> getAllPatients() async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/patients'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse
          .map((patientJson) => Patient.fromJson(patientJson))
          .toList();
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

  static Future<void> addPatient({
    required String firstName,
    required String lastName,
    required String gender,
    required String dob,
    required String address,
    required String emergencyContact,
    required int userId,
  }) async {
    String? token = await _getToken();
    final body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'dob': dob,
      'address': address,
      'emergencyContact': emergencyContact,
      'userId': userId,
    });
    final response = await http.post(
      Uri.parse('$baseUrl/patients'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add patient');
    }
  }

  static Future<void> updatePatient(Patient patient) async {
    String? token = await _getToken();
    final body = jsonEncode(patient.toJson());
    print('Sending update request: $body');
    final response = await http.put(
      Uri.parse('$baseUrl/patients/${patient.profileId}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update patient');
    }
  }

  static Future<void> deletePatient(int profileId) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/patients/$profileId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete patient');
    }
  }

  static Future<List<SensorData>> getHeartRateData(int profileId) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/sensorData/$profileId/heartRate'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => SensorData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load heart rate data');
    }
  }
}
