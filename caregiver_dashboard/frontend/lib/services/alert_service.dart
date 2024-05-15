import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AlertService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:3000/api';
  static final storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await storage.read(key: 'jwt');
  }

  static Future<Map<String, dynamic>> getAlertLogs(int userId, int page) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/alerts/recent/$userId?page=$page'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load alert logs');
    }
  }

  static Future<void> resolveAlert(int alertId) async {
    String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/alerts/resolve/$alertId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to resolve alert');
    }
  }
}
