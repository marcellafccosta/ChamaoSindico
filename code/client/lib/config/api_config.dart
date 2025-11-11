
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;

class ApiConfig {
static const String _prodUrl = 'https://server-10l0.onrender.com';
static const String _devUrl = 'http://localhost:3000';

static String get baseUrl {
  // Para web sempre usar produção
  if (kIsWeb) {
    return _prodUrl;
  }
  // Para desenvolvimento local
  return kDebugMode ? _devUrl : _prodUrl;
}

static Map<String, String> get headers => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};
}

// class ApiService {
// static Future<Map<String, dynamic>> get(String endpoint) async {
//   try {
//     final response = await http.get(
//       Uri.parse('${ApiConfig.baseUrl}$endpoint'),
//       headers: ApiConfig.headers,
//     );
    
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('HTTP ${response.statusCode}: ${response.body}');
//     }
//   } catch (e) {
//     print('API Error: $e');
//     rethrow;
//   }
// }

// static Future<Map<String, dynamic>> post(
//   String endpoint, 
//   Map<String, dynamic> data
// ) async {
//   try {
//     final response = await http.post(
//       Uri.parse('${ApiConfig.baseUrl}$endpoint'),
//       headers: ApiConfig.headers,
//       body: json.encode(data),
//     );
    
//     if (response.statusCode == 200 || response.statusCode == 201) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('HTTP ${response.statusCode}: ${response.body}');
//     }
//   } catch (e) {
//     print('API Error: $e');
//     rethrow;
//   }
// }
// }