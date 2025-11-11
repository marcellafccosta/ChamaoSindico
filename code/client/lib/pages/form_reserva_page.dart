import 'package:client/models/usuario_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'lista_areas_page.dart';
import 'package:client/utils/utils.dart';
import 'package:client/utils/api_url.dart';

class FormReservaPage extends StatefulWidget {
  final AreaComum area;

  const FormReservaPage({super.key, required this.area});

  @override
  State<FormReservaPage> createState() => _FormReservaPageState();
}

class _FormReservaPageState extends State<FormReservaPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  TimeOfDay? _selectedEndTime;
  final TextEditingController _numberOfPeopleController =
      TextEditingController();
  bool _isLoading = false;

  final Utils _utils = Utils();
  UsuarioModel? _usuario;

  @override
  void initState() {
    super.initState();
    _carregarUsuario(); // Corrigido aqui
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

  Future<void> _carregarUsuario() async {
    _usuario = await _utils.carregarUsuario();
    setState(() {}); // Corrigido: removido o "f" extra
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ??
          (_selectedTime != null
              ? TimeOfDay(
                  hour: _selectedTime!.hour + 1, minute: _selectedTime!.minute)
              : TimeOfDay.now()),
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale('pt', 'BR'),
          child: child,
        );
      },
    );

    if (picked != null && picked != _selectedEndTime) {
      if (picked.hour >= 22 || picked.hour < 7) {
        _showErrorSnackBar(
            'Horário de reserva não permitido entre 22:00 e 07:00.');
        return;
      }

      if (_selectedTime != null) {
        final startMinutes = _selectedTime!.hour * 60 + _selectedTime!.minute;
        final endMinutes = picked.hour * 60 + picked.minute;

        if (endMinutes <= startMinutes) {
          _showErrorSnackBar(
              'Horário de fim deve ser posterior ao horário de início.');
          return;
        }
      }

      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale('pt', 'BR'),
          child: child,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      if (picked.hour >= 22 || picked.hour < 7) {
        _showErrorSnackBar(
            'Horário de reserva não permitido entre 22:00 e 07:00.');
        return;
      }

      setState(() {
        _selectedTime = picked;
        if (_selectedEndTime != null) {
          final startMinutes = picked.hour * 60 + picked.minute;
          final endMinutes =
              _selectedEndTime!.hour * 60 + _selectedEndTime!.minute;
          if (endMinutes <= startMinutes) {
            _selectedEndTime = null;
          }
        }
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null ||
          _selectedTime == null ||
          _selectedEndTime == null) {
        _showErrorSnackBar(
            'Por favor, selecione data, horário de início e fim.');
        return;
      }

      // Corrigido: usar _usuario ao invés de _userId
      if (_usuario?.accessToken == null) {
        await _carregarUsuario();
        if (_usuario?.accessToken == null) {
          _showErrorSnackBar('Usuário não autenticado. Faça login novamente.');
          return;
        }
      }

      if (_usuario?.id == null) {
        _showErrorSnackBar(
            'Não foi possível obter o ID do usuário. Tente novamente.');
        return;
      }

      setState(() => _isLoading = true);

      int? userIdInt;
      try {
        userIdInt = int.parse(_usuario!.id); // Corrigido: usar _usuario!.id
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Erro: ID do usuário inválido.');
        return;
      }

      final bookingData = {
        'userId': userIdInt,
        'areaId': widget.area.id,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        'time':
            '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        'endTime':
            '${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}',
        'numberOfPeople': int.parse(_numberOfPeopleController.text),
      };

      try {
        final response = await http.post(
          Uri.parse('${getApiBaseUrl()}/bookings'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_usuario!.accessToken}',
          },
          body: jsonEncode(bookingData),
        );

        if (!mounted) return;

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Reserva criada com sucesso!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          final responseBody = jsonDecode(response.body);
          final errorMessage =
              responseBody['message'] ?? 'Falha ao criar reserva.';

          Color snackBarColor =
              response.statusCode == 409 ? Colors.orange : Colors.red;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(errorMessage)),
                ],
              ),
              backgroundColor: snackBarColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar('Erro de conexão: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _numberOfPeopleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Verificar se o usuário foi carregado
    if (_usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final areaColor = _getAreaColor(widget.area.name);

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
        title: Text(
          'Reservar ${widget.area.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Card de informações da área
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
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
                        Container(width: 6, color: areaColor),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: areaColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.deck_rounded,
                                    color: areaColor,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.area.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoChip(
                                              Icons.people_rounded,
                                              '${widget.area.peopleLimit} pessoas',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: _buildInfoChip(
                                              Icons.attach_money_rounded,
                                              'R\$ ${widget.area.price.toStringAsFixed(2)}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Card de seleção de data e horário
              _buildFormCard(
                title: 'Data e Horário',
                icon: Icons.schedule_rounded,
                children: [
                  _buildSelectTile(
                    icon: Icons.calendar_today_rounded,
                    title: _selectedDate == null
                        ? 'Selecione a data'
                        : DateFormat(
                                'EEEE, dd \'de\' MMMM \'de\' yyyy', 'pt_BR')
                            .format(_selectedDate!),
                    isSelected: _selectedDate != null,
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 12),
                  _buildSelectTile(
                    icon: Icons.access_time_rounded,
                    title: _selectedTime == null
                        ? 'Horário de início'
                        : 'Início: ${_selectedTime!.format(context)}',
                    isSelected: _selectedTime != null,
                    onTap: () => _selectTime(context),
                  ),
                  const SizedBox(height: 12),
                  _buildSelectTile(
                    icon: Icons.access_time_filled_rounded,
                    title: _selectedEndTime == null
                        ? 'Horário de fim'
                        : 'Fim: ${_selectedEndTime!.format(context)}',
                    isSelected: _selectedEndTime != null,
                    onTap: _selectedTime != null
                        ? () => _selectEndTime(context)
                        : null,
                    isEnabled: _selectedTime != null,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Card de número de pessoas
              _buildFormCard(
                title: 'Número de Pessoas',
                icon: Icons.groups_rounded,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextFormField(
                      controller: _numberOfPeopleController,
                      decoration: InputDecoration(
                        hintText: 'Digite o número de pessoas',
                        prefixIcon:
                            Icon(Icons.people_rounded, color: areaColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe o número de pessoas.';
                        }
                        final n = int.tryParse(value);
                        if (n == null) {
                          return 'Número inválido.';
                        }
                        if (n <= 0) {
                          return 'O número de pessoas deve ser maior que zero.';
                        }
                        if (n > widget.area.peopleLimit) {
                          return 'Excede a capacidade de ${widget.area.peopleLimit} pessoas.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Botão de confirmar
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF33477A), Color(0xFF4A5B8C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF33477A).withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_circle_outline,
                          color: Colors.white),
                  label: Text(
                    _isLoading ? 'CONFIRMANDO...' : 'CONFIRMAR RESERVA',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF33477A), size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSelectTile({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isEnabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF33477A).withOpacity(0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF33477A).withOpacity(0.3)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isEnabled
                    ? (isSelected
                        ? const Color(0xFF33477A)
                        : Colors.grey.shade600)
                    : Colors.grey.shade400,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isEnabled
                        ? (isSelected
                            ? const Color(0xFF33477A)
                            : Colors.grey.shade700)
                        : Colors.grey.shade400,
                  ),
                ),
              ),
              if (isEnabled)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
