import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';

import '../models/visitante_model.dart';
import '../utils/api_url.dart';

final Logger logger = Logger();

class VisitanteController {
  Future<List<VisitanteModel>> getAllVisitantes() async {
    try {
      final apiBase = getApiBaseUrl();
      final response = await http.get(Uri.parse('$apiBase/visitante'));

      print('Status Code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        print('Dados decodificados: $jsonData');

        if (jsonData.isEmpty) {
          print('Lista de visitantes está vazia!');
        }
        return jsonData.map((item) => VisitanteModel.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao carregar visitantes');
      }
    } catch (e, stack) {
      print('Erro na requisição: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<VisitanteModel> getVisitanteById(int id) async {
    final apiBase = getApiBaseUrl();
    final response = await http.get(Uri.parse('$apiBase/visitante/$id'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return VisitanteModel.fromJson(jsonData);
    } else {
      throw Exception('Erro ao carregar visitante');
    }
  }

  Future<List<VisitanteModel>> getVisitantesByApartamento(String id) async {
    try {
      final apiBase = getApiBaseUrl();
      final response = await http.get(Uri.parse('$apiBase/visitante/apartamento/$id'));

      print('Status Code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        print('Dados decodificados: $jsonData');

        if (jsonData.isEmpty) {
          print('Lista de visitantes está vazia!');
        }
        return jsonData.map((item) => VisitanteModel.fromJson(item)).toList();
      } else {
        throw Exception('Erro ao carregar visitantes');
      }
    } catch (e, stack) {
      print('Erro na requisição: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<void> createVisitante(VisitanteModel visitante) async {
    try {
      final apiBase = getApiBaseUrl();
      final response = await http.post(
        Uri.parse('$apiBase/visitante'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(visitante.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar visitante');
      }
    } catch (e) {
      logger.w('Erro ao criar visitante: $e');
      rethrow;
    }
  }

  Future<void> check(VisitanteModel visitante) async {
    final isCheckin = visitante.checkIn == null;
    final now = DateTime.now().toIso8601String();

    final body = isCheckin ? {'checkIn': now} : {'checkOut': now};

    final apiBase = getApiBaseUrl();
    final response = await http.patch(
      Uri.parse('$apiBase/visitante/check/${visitante.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar visitante');
    }
  }

  Future<void> updateVisitante(VisitanteModel visitante) async {
    final apiBase = getApiBaseUrl();
    final response = await http.patch(
      Uri.parse('$apiBase/visitante/${visitante.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(visitante.toJson()),
    );

    if (response.statusCode != 200) {
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception('Erro ao atualizar visitante');
    }
  }

  Future<void> deleteVisitante(String id) async {
    final apiBase = getApiBaseUrl();
    final response = await http.delete(Uri.parse('$apiBase/visitante/$id'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar visitante');
    }
  }
}