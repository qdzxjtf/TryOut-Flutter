import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://api-test.eksam.cloud';

  static Future<http.Response> post(String endpoint, Map<String, String> body, {bool useToken = false}) async {
    final headers = await _buildHeaders(useToken);
    final url = Uri.parse('$_baseUrl$endpoint');
    return http.post(url, headers: headers, body: body);
  }

  static Future<http.Response> get(String endpoint, {bool useToken = false}) async {
    final headers = await _buildHeaders(useToken);
    final url = Uri.parse('$_baseUrl$endpoint');
    return http.get(url, headers: headers);
  }

  static Future<Map<String, String>> _buildHeaders(bool withToken) async {
    final headers = {'Accept': 'application/json'};
    if (withToken) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }
}
