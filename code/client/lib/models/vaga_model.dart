import 'package:client/models/apartamento_model.dart';

class VagaModel {
  late String id;
  late String name;
  late bool isOcupada;
  late int? apartamentoId;
  ApartamentoModel? apartamento;

  VagaModel({
    required this.id,
    required this.name,
    this.isOcupada = false,
    this.apartamentoId,
    this.apartamento,
  });

  factory VagaModel.fromJson(Map<String, dynamic> json) {
    return VagaModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      isOcupada: json['isOcupada'] ?? '',
      apartamentoId: json['apartamentoId'] ?? '',
      apartamento: json['apartamento'] != null
          ? ApartamentoModel.fromJson(json['apartamento'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isOcupada': isOcupada,
      'apartamentoId': apartamentoId,
    };
  }
}
