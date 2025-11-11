import 'dart:io';

import 'package:client/enum/role.dart';
import 'package:client/pages/lista_visitantes_page.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/usuario_model.dart';

class UsuarioController {
  // 1. URL CENTRALIZADA USANDO SEU IP
  // Esta URL funcionará para o seu celular, desde que ele esteja na mesma
  // rede Wi-Fi que o seu computador.
  // static const String _baseUrl = 'http://192.168.0.6:3000/api';

  static String get _baseUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        return 'http://localhost:3000/api';
      } else {
        return 'https://server-10l0.onrender.com/api';
      }
    } else if (Platform.isAndroid) {
      return 'https://server-10l0.onrender.com/api';
    } else {
      return 'https://server-10l0.onrender.com/api';
    }
  }

  String? _nome;
  String? _email;
  String? _senha;
  // String? _senhaRepetida;
  Role _role = Role.values.first;
  String? _accessToken;

  void setNome(String? nome) => _nome = nome;
  void setEmail(String? email) => _email = email;
  void setSenha(String? senha) => _senha = senha;
  // void setSenhaRepetida(String? senha) => _senhaRepetida = senha;
  void setRole(Role role) => _role = role;
  void setToken(String accessToken) => _accessToken = accessToken;

  UsuarioModel get usuario => UsuarioModel(
        id: '', // será preenchido no backend
        name: _nome ?? '',
        email: _email ?? '',
        password: _senha ?? '',
        role: _role,
        accessToken: '',
      );

  // Código comentado mantido como estava, mas com a URL corrigida para referência
  // String? validaSenhaRepetida(String? senha) { ... }
  // Future<UsuarioModel?> getUserFromToken() async { ... }
  // Future<void> makeRequest() async { ... }

  Future<UsuarioModel> loginUsuario() async {
    // 2. USO DA URL CENTRALIZADA
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': _email,
        'password': _senha,
      }),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return UsuarioModel.fromJson(json);
    } else {
      throw ('Credenciais inválidas. Verifique seu e-mail e senha');
    }
  }

  Future<List<UsuarioModel>> getAllUsuarios() async {
    print('Carregando usuarios...');
    final response =
        await http.get(Uri.parse('$_baseUrl/user')); // URL corrigida

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      print('Carregando usuarios...$jsonData');
      return jsonData.map((item) => UsuarioModel.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao carregar usuarios');
    }
  }

  Future<void> vincularUsuario(int apartamentoId, List<int> usuariosIds) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/user/$apartamentoId/users'), // URL corrigida
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'userIds': usuariosIds}),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao vincular usuários: ${response.body}');
    }
  }

  Future<UsuarioModel> getUsuarioById(String id) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/user/$id')); // URL corrigida

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return UsuarioModel.fromJson(jsonData);
    } else {
      throw Exception('Erro ao carregar usuario');
    }
  }

  Future<void> createUsuario() async {
    final user = usuario;
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'), // URL corrigida
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    logger.w(response.statusCode);
    if (response.statusCode == 201) {
    } else if (response.statusCode == 409) {
      logger.w('Email já cadastrado');
      throw ('Email já cadastrado');
    } else {
      throw ('Erro ao criar usuarioSSS');
    }
  }

  Future<void> updateUsuario(UsuarioModel usuario) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/user/${usuario.id}'), // URL corrigida
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(usuario.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar usuario');
    }
  }

  Future<void> deleteUsuario(String id) async {
    final response =
        await http.delete(Uri.parse('$_baseUrl/user/$id')); // URL corrigida

    if (response.statusCode != 200) {
      throw Exception('Erro ao deletar usuario');
    }
  }
}
