
class Booking {
  final int id;
  final String?
      areaName; // Assuming your API provides the area name or an area object
  final DateTime bookingDate;
  final String status;
  // Add any other fields relevant to your Booking entity, e.g.:
  // final int userId;
  // final String userName;
  // final int areaId;
  // final String startTime;
  // final String endTime;

  Booking({
    required this.id,
    this.areaName,
    required this.bookingDate,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    DateTime finalBookingDate; // Declarado como DateTime (não nulo)

    final String? dateString = json['date'] as String?;
    final String? timeString = json['time'] as String?;

    if (dateString != null &&
        dateString.isNotEmpty &&
        timeString != null &&
        timeString.isNotEmpty) {
      final String dateTimeString = "${dateString}T$timeString";
      try {
        finalBookingDate = DateTime.parse(dateTimeString);
      } catch (e) {
        print(
            'Erro ao parsear data e hora combinadas: "$dateTimeString". Usando data atual como padrão. Erro: $e');
        finalBookingDate = DateTime.now(); // <-- VALOR PADRÃO se o parse falhar
      }
    } else {
      print(
          'Alerta: "date" ou "time" ausentes ou inválidos no JSON. Usando data atual como padrão. Recebido date: "$dateString", time: "$timeString"');
      finalBookingDate = DateTime
          .now(); // <-- VALOR PADRÃO se "date" ou "time" estiverem ausentes/inválidos
    }

    // Lógica para 'status'
    final rawStatus = json['status'];
    String finalStatus;
    if (rawStatus == null) {
      finalStatus = 'Desconhecido';
    } else if (rawStatus is String) {
      finalStatus = rawStatus;
    } else {
      finalStatus = rawStatus.toString();
    }

    // Lógica para 'areaName'
    final rawAreaName = json['areaName'];
    String? finalAreaName; // areaName pode ser nulo no seu modelo Booking?
    if (rawAreaName == null) {
      finalAreaName =
          (json['area'] is Map ? json['area']['name'] as String? : null) ??
              'Área comum';
    } else if (rawAreaName is String) {
      finalAreaName = rawAreaName;
    } else {
      finalAreaName = rawAreaName.toString();
    }

    // Verifique se 'id' está presente e é um int
    final rawId = json['id'];
    int finalId;
    if (rawId is int) {
      finalId = rawId;
    } else {
      print(
          'Alerta: "id" ausente ou não é int no JSON. Usando 0 como padrão. Recebido: "$rawId"');
      finalId = 0; // Ou lance um erro se ID é obrigatório e deve ser válido
      // throw FormatException('Campo "id" é obrigatório e deve ser um int. Recebido: $rawId');
    }

    return Booking(
      id: finalId,
      areaName: finalAreaName,
      bookingDate: finalBookingDate, // Agora finalBookingDate é sempre DateTime
      status: finalStatus,
    );
  }
}
