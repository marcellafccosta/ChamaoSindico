import 'package:client/enum/tipo_visitante.dart';
import 'package:client/models/apartamento_model.dart';
import 'package:client/models/usuario_model.dart';

class VisitanteModel {
  late int id;
  late String name;
  late String document;
  late String? phone;
  late String? model;
  late DateTime? checkIn;
  late DateTime? checkOut;
  late int? apartamentoId;
  late int userId;
  late TipoVisitante typeVisitant;
  ApartamentoModel? apartamento;
  UsuarioModel? usuario;

  VisitanteModel({
    required this.id,
    required this.name,
    required this.document,
    this.phone,
    this.model,
    this.checkIn,
    this.checkOut,
    required this.userId,
    required this.typeVisitant,
    this.apartamentoId,
    this.apartamento,
    this.usuario,
  });

  factory VisitanteModel.fromJson(Map<String, dynamic> json) {
    return VisitanteModel(
      id: json['id'],
      name: json['name'] ?? '',
      document: json['document'] ?? '',
      phone: json['phone'] ?? '',
      model: json['model'] ?? '',
      checkIn: json['checkIn'] != null ? DateTime.parse(json['checkIn']) : null,
      checkOut:
          json['checkOut'] != null ? DateTime.parse(json['checkOut']) : null,
      userId: json['userId'] ?? 0,
      typeVisitant: TipoVisitante.values.firstWhere(
        (e) => e.name == json['typeVisitant'],
        orElse: () => TipoVisitante.PESSOAL,
      ),
      apartamentoId: json['apartamentoId'] != null
          ? int.tryParse(json['apartamentoId'].toString())
          : null,
      apartamento: json['apartamento'] != null
          ? ApartamentoModel.fromJson(json['apartamento'])
          : null,
      usuario: json['usuario'] != null
          ? UsuarioModel.fromJson(json['usuario'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'name': name,
      'document': document,
      'phone': phone,
      'model': model,
      'userId': userId,
      'typeVisitant': typeVisitant.name,
      'apartamentoId': apartamentoId,
    };

    if (checkIn != null) data['checkIn'] = checkIn!.toIso8601String();
    if (checkOut != null) data['checkOut'] = checkOut!.toIso8601String();

    return data;
  }
}