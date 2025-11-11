import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/vaga_model.dart';
import '../utils/api_url.dart';

class VagaController {
  Future<List<VagaModel>> getAllVagas() async {
    final apiBase = getApiBaseUrl();
    final response = await http.get(Uri.parse('$apiBase/vaga'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => VagaModel.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao carregar vagas');
    }
  }

  Future<List<VagaModel>> getByApartamento(String apartamentoId) async {
    final apiBase = getApiBaseUrl();
    final response = await http.get(Uri.parse('$apiBase/vaga/apartamento/$apartamentoId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => VagaModel.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao carregar vagas por apartamento');
    }
  }

  Future<VagaModel> getVagaById(String id) async {
    final apiBase = getApiBaseUrl();
    final response = await http.get(Uri.parse('$apiBase/vaga/$id'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return VagaModel.fromJson(jsonData);
    } else {
      throw Exception('Erro ao carregar vaga');
    }
  }

  Future<void> createVaga(VagaModel vaga) async {
    final apiBase = getApiBaseUrl();
    final response = await http.post(
      Uri.parse('$apiBase/vaga'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vaga.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao criar vaga');
    }
  }

  Future<void> updateVaga(VagaModel vaga) async {
    final apiBase = getApiBaseUrl();
    final response = await http.patch(
      Uri.parse('$apiBase/vaga/${vaga.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(vaga.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar vaga');
    }
  }

  Future<void> deleteVaga(String id) async {
    final apiBase = getApiBaseUrl();
    final response = await http.delete(Uri.parse('$apiBase/vaga/$id'));

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar vaga');
    }
  }
}