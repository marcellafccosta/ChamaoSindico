import 'dart:convert';

import 'package:client/enum/role.dart';
import 'package:client/models/apartamento_model.dart';

class UsuarioModel {
  final String id;
  final String name;
  final String email;
  final String? password;
  final Role role;
  final String accessToken;
  final ApartamentoModel? apartamento;
  final int? apartamentoId;

  UsuarioModel({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.role,
    required this.accessToken,
    this.apartamento,
    this.apartamentoId,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    if (json['accessToken'] != null) {
      final token = json['accessToken'];
      final payloadBase64 = token.split('.')[1];
      final normalized = base64Url.normalize(payloadBase64);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));

      return UsuarioModel(
        id: payload['sub'].toString(),
        name: payload['name'] ?? '',
        email: payload['email'] ?? '',
        role: Role.values[payload['role'] ?? 0],
        accessToken: token,
        apartamento: json['apartamento'] != null
            ? ApartamentoModel.fromJson(json['apartamento'])
            : null,
        apartamentoId: payload['apartamentoId'] != null
            ? int.tryParse(payload['apartamentoId'].toString())
            : null,
      );
    } else {
      return UsuarioModel(
        id: json['id'].toString(),
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        role: Role.values[json['role'] ?? 0],
        accessToken: '',
        apartamento: json['apartamento'] != null
            ? ApartamentoModel.fromJson(json['apartamento'])
            : null,
        apartamentoId: json['apartamentoId'],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.index,
      'accessToken': accessToken,
      'apartamentoId': apartamentoId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UsuarioModel(id: $id, name: $name, email: $email, role: $role, apartamento: ${apartamento?.id}, token: $accessToken)';
  }
}
