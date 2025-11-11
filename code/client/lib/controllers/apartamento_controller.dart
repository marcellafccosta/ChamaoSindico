import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/api_url.dart';

import '../models/apartamento_model.dart';

class ApartamentoController {
  
  final apiBase = getApiBaseUrl();
  Future<List<ApartamentoModel>> getAllApartamentos() async {
    final response = await http.get(Uri.parse('${apiBase}/apartamento'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => ApartamentoModel.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao carregar apartamentos');
    }
  }

  Future<ApartamentoModel> getApartamentoById(String id) async {
    final response = await http.get(Uri.parse('${apiBase}/apartamento/$id'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return ApartamentoModel.fromJson(jsonData);
    } else {
      throw Exception('Erro ao carregar apartamento');
    }
  }

  Future<ApartamentoModel> createApartamento(
      ApartamentoModel apartamento) async {
    final response = await http.post(
      Uri.parse('${apiBase}/apartamento'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(apartamento.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar apartamento');
    }

    final json = jsonDecode(response.body);
    return ApartamentoModel.fromJson(json);
  }

  Future<void> updateApartamento(ApartamentoModel apartamento) async {
    final response = await http.patch(
      Uri.parse('${apiBase}/apartamento/${apartamento.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(apartamento.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar apartamento');
    }
  }

  Future<void> deleteApartamento(String id) async {
    final response = await http.delete(Uri.parse('${apiBase}/apartamento/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar apartamento');
    }
  }
}
