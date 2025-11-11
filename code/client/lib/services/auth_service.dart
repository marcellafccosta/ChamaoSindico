import 'dart:convert';

import 'package:client/utils/storage_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

Future<Map<String, dynamic>?> getDecodedToken() async {
    final token = await StorageHelper.instance.getItem('token');
    if (token == null || token.isEmpty) {
      return null;
    }
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(payload));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      print('Erro ao decodificar token: $e');
      return null;
    }
  }

  Future<int?> getCurrentUserRole() async {
    final payload = await getDecodedToken();
    if (payload == null) {
      return null;
    }
    return payload['role'] as int?;
  }

  Future<void> logout() async {
    await StorageHelper.instance.removeItem('token');
    await StorageHelper.instance.removeItem('usuario');
  }
}
