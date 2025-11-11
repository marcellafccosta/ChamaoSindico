import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
// ✅ URL do seu backend no Render
static String get _baseUrl {
  return 'https://server-10l0.onrender.com/api';
}

static Map<String, String> get _headers => {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};

static Future<void> atualizarFcmToken(String usuarioId, String fcmToken) async {
  final url = Uri.parse('$_baseUrl/user/$usuarioId/fcm-token');

  try {
    print('🚀 Enviando FCM Token para: $url');
    
    final response = await http.patch(
      url,
      headers: _headers,
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    if (response.statusCode == 200) {
      print('✅ FCM Token atualizado no backend com sucesso.');
    } else {
      print('❌ Falha ao atualizar FCM Token. Status: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('🔥 Erro de rede ao atualizar FCM Token: $e');
  }
}

// ✅ Método para testar conexão
static Future<bool> testConnection() async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/../health'), // Endpoint de health check
      headers: _headers,
    );
    return response.statusCode == 200;
  } catch (e) {
    print('🔥 Connection test failed: $e');
    return false;
  }
}

// ✅ Outros métodos que você pode precisar
static Future<Map<String, dynamic>> get(String endpoint) async {
  final url = Uri.parse('$_baseUrl$endpoint');
  final response = await http.get(url, headers: _headers);
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('GET failed: ${response.statusCode}');
  }
}

static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
  final url = Uri.parse('$_baseUrl$endpoint');
  final response = await http.post(
    url,
    headers: _headers,
    body: jsonEncode(data),
  );
  
  if (response.statusCode == 200 || response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('POST failed: ${response.statusCode}');
  }
}
}