import 'package:client/models/usuario_model.dart';
import 'package:client/utils/utils.dart';
import 'package:client/utils/api_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Booking {
  final int id;
  final String areaName;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final int numberOfPeople;

  Booking({
    required this.id,
    required this.areaName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.numberOfPeople,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    try {
      int id = json['id'] as int;
      DateTime bookingDate = DateTime.parse(json['date']);
      String startTime = json['time']?.toString() ?? 'N/A';

      String endTime;
      if (json['endTime'] != null && json['endTime'].toString().isNotEmpty) {
        endTime = json['endTime'].toString();
      } else {
        if (startTime != 'N/A' && startTime.contains(':')) {
          try {
            final parts = startTime.split(':');
            final hour = int.parse(parts[0]);
            final minute = int.parse(parts[1]);
            final endHour = hour + 1;
            endTime =
                '${endHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
          } catch (e) {
            endTime = startTime;
          }
        } else {
          endTime = startTime;
        }
      }

      int numberOfPeople = json['numberOfPeople'] as int;

      String areaName = 'Área Desconhecida';
      if (json['area'] != null && json['area']['name'] != null) {
        areaName = json['area']['name'].toString();
      }

      return Booking(
        id: id,
        areaName: areaName,
        bookingDate: bookingDate,
        startTime: startTime,
        endTime: endTime,
        numberOfPeople: numberOfPeople,
      );
    } catch (e) {
      print('ERRO ao criar Booking: $e');
      rethrow;
    }
  }
}

class ListaBookingsPage extends StatefulWidget {
  const ListaBookingsPage({super.key});

  @override
  State<ListaBookingsPage> createState() => _ListaBookingsPageState();
}

class _ListaBookingsPageState extends State<ListaBookingsPage> {
  late Future<List<Booking>> _futureBookings;
  final Utils _utils = Utils();
  UsuarioModel? _usuario;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _carregarUsuario();
    _futureBookings = _fetchBookings();
  }

  Future<void> _carregarUsuario() async {
    _usuario = await _utils.carregarUsuario();
    setState(() {});
  }

  Future<List<Booking>> _fetchBookings() async {
    try {
      if (_usuario?.accessToken == null) {
        throw Exception('Token de autenticação não encontrado.');
      }

      String url = '${getApiBaseUrl()}/bookings';
      if (_usuario?.id != null) {
        url += '?userId=${_usuario!.id}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${_usuario!.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        List<dynamic> bookingsData = responseData as List;

        List<Booking> bookings = [];
        for (int i = 0; i < bookingsData.length; i++) {
          try {
            final booking = Booking.fromJson(bookingsData[i]);
            bookings.add(booking);
          } catch (e) {
            print('ERRO ao processar reserva $i: $e');
          }
        }

        return bookings;
      } else {
        throw Exception('Falha ao carregar reservas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de rede ao carregar reservas: $e');
    }
  }

  Future<void> _deleteBooking(int bookingId) async {
    try {
      if (_usuario?.accessToken == null) {
        throw Exception('Token de autenticação não encontrado.');
      }

      final response = await http.delete(
        Uri.parse('${getApiBaseUrl()}/bookings/$bookingId'),
        headers: {
          'Authorization': 'Bearer ${_usuario!.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Reserva cancelada com sucesso!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );

          setState(() {
            _futureBookings = _fetchBookings();
          });
        }
      } else {
        throw Exception('Falha ao cancelar reserva');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(Booking booking) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Confirmar Cancelamento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deseja realmente cancelar esta reserva?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(Icons.place, 'Área', booking.areaName),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.calendar_today, 'Data',
                        DateFormat('dd/MM/yyyy').format(booking.bookingDate)),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.access_time, 'Horário',
                        '${booking.startTime} às ${booking.endTime}'),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.people, 'Pessoas',
                        '${booking.numberOfPeople} pessoas'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Manter Reserva',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancelar Reserva',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteBooking(booking.id);
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Color _getAreaColor(String areaName) {
    final colors = [
      const Color(0xFF4CAF50), // Verde
      const Color(0xFF2196F3), // Azul
      const Color(0xFFFF9800), // Laranja
      const Color(0xFF9C27B0), // Roxo
      const Color(0xFFF44336), // Vermelho
      const Color(0xFF607D8B), // Azul acinzentado
    ];

    final index = areaName.hashCode % colors.length;
    return colors[index.abs()];
  }

  @override
  Widget build(BuildContext context) {
    if (_usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF33477A), Color(0xFF4A5B8C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Minhas Reservas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () {
                setState(() {
                  _futureBookings = _fetchBookings();
                });
              },
              tooltip: 'Atualizar',
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Booking>>(
        future: _futureBookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF33477A)),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Carregando suas reservas...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ops! Algo deu errado',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Não foi possível carregar suas reservas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _futureBookings = _fetchBookings();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar Novamente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF33477A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_available_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Nenhuma reserva encontrada',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Você ainda não fez nenhuma reserva.\nQue tal reservar uma área agora?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/reserva');
                    },
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.white),
                    label: const Text('Fazer Reserva'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF33477A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            );
          } else {
            List<Booking> bookings = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final areaColor = _getAreaColor(booking.areaName);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Barra colorida lateral
                          Container(
                            width: 6,
                            color: areaColor,
                          ),
                          // Conteúdo principal
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header com nome da área e botão delete
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: areaColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.place_rounded,
                                          color: areaColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              booking.areaName,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateFormat('dd/MM/yyyy')
                                                  .format(booking.bookingDate),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _showDeleteConfirmation(booking),
                                          tooltip: 'Cancelar reserva',
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // Informações detalhadas
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildDetailCard(
                                          Icons.access_time_rounded,
                                          'Horário',
                                          '${booking.startTime} às ${booking.endTime}',
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildDetailCard(
                                          Icons.people_rounded,
                                          'Pessoas',
                                          '${booking.numberOfPeople} pessoas',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
