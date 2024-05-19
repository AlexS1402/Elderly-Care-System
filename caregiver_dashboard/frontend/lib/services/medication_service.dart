import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/medication.dart';
import '../models/medication_schedule.dart';

class MedicationService {
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';
  static final storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await storage.read(key: 'jwt');
  }

  static Future<List<Medication>> getMedications(int profileId) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/medications/$profileId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((med) => Medication.fromJson(med)).toList();
    } else {
      throw Exception('Failed to load medications');
    }
  }

  static Future<void> updateMedication(Medication medication) async {
    String? token = await _getToken();
    final body = jsonEncode(medication.toJson());
    final response = await http.put(
      Uri.parse('$baseUrl/medications/${medication.medicationId}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update medication');
    }
  }

  static Future<void> deleteMedication(int medicationId) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/medications/$medicationId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete medication');
    }
  }

  static Future<void> addMedication(Medication medication) async {
    String? token = await _getToken();
    final body = jsonEncode(medication.toJson());
    final response = await http.post(
      Uri.parse('$baseUrl/medications'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add medication');
    }
  }

  static Future<void> addMedicationSchedule(
      int medicationId, MedicationSchedule schedule) async {
    String? token = await _getToken();
    final body = jsonEncode(schedule.toJson());
    final response = await http.post(
      Uri.parse('$baseUrl/medications/$medicationId/schedules'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add medication schedule');
    }
  }
}
