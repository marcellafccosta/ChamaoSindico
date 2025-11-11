import 'dart:convert';

import 'package:client/models/usuario_model.dart';
import 'package:client/utils/storage_helper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  Future<void> salvarUsuarioEtoken(UsuarioModel usuario) async {
    try {
      final usuarioJson = jsonEncode(usuario.toJson());

      if (kIsWeb) {
        await StorageHelper.instance.setItem('token', usuario.accessToken);
        await StorageHelper.instance.setItem('usuario', usuarioJson);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', usuario.accessToken);
        await prefs.setString('usuario', usuarioJson);
      }
    } catch (e) {
      throw Exception('Erro ao salvar usuário e token: $e');
    }
  }

  Future<UsuarioModel?> carregarUsuario() async {
    try {
      String? usuarioJson;

      if (kIsWeb) {
        // IMPORTANTE: SEM 'final' aqui!
        usuarioJson = await StorageHelper.instance.getItem('usuario');
      } else {
        final prefs = await SharedPreferences.getInstance();
        usuarioJson = prefs.getString('usuario');
      }

      print('=== CARREGANDO USUÁRIO ===');
      print('JSON recuperado: ${usuarioJson?.substring(0, 100) ?? 'null'}...');

      final usuario = UsuarioModel.fromJson(jsonDecode(usuarioJson!));
      print('Usuário carregado: ${usuario.name} (ID: ${usuario.id})');
      return usuario;
    
      print('Nenhum usuário encontrado no storage');
      return null;
    } catch (e) {
      print('Erro ao carregar usuário: $e');
      throw Exception('Erro ao carregar usuário no utils: $e');
    }
  }

  Future<String> obterToken() async {
    try {
      String? token;

      if (kIsWeb) {
        token = await StorageHelper.instance.getItem('token');
      } else {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString('token');
      }

      return token ?? '';
    } catch (e) {
      throw Exception('Erro ao obter token: $e');
    }
  }

  String? formatarData(DateTime? data) {
    if (data == null) return '---';
    return DateFormat('dd/MM/yyyy HH:mm').format(data);
  }
}
