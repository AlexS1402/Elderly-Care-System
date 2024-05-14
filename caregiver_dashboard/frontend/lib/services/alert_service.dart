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

  static Future<List<Map<String, dynamic>>> getAlertLogs() async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/alerts/recent'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(body);
    } else {
      throw Exception('Failed to load alert logs');
    }
  }
}
