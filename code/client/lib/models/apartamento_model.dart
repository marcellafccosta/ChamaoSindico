class ApartamentoModel {
  late String id;
  late String name;
  List<String> userIds;
  List<String> vagasIds;

  ApartamentoModel({
    required this.id,
    required this.name,
    this.userIds = const [],
    this.vagasIds = const [],
  });

  factory ApartamentoModel.fromJson(Map<String, dynamic> json) {
    return ApartamentoModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      userIds: (json['users'] as List<dynamic>?)
          ?.map((e) => e['id'].toString())
          .toList() ??
      [],
      vagasIds: (json['vaga'] as List<dynamic>?)
          ?.map((e) => e['id'].toString())
          .toList() ??
      [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'users': userIds.map((e) => int.tryParse(e) ?? 0).toList(),
      'vaga': vagasIds.map((e) => int.tryParse(e) ?? 0).toList(),
    };
  }
}