import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:client/utils/utils.dart';
import 'package:client/models/usuario_model.dart';
import 'package:logger/logger.dart';
import 'package:client/utils/api_url.dart';

final Logger logger = Logger();

class IndicacaoProfissionaisPage extends StatefulWidget {
  const IndicacaoProfissionaisPage({super.key});

  @override
  State<IndicacaoProfissionaisPage> createState() =>
      _IndicacaoProfissionaisPageState();
}

class _IndicacaoProfissionaisPageState
    extends State<IndicacaoProfissionaisPage> {
  late Future<List<Map<String, dynamic>>> _futureProfissionais;
  final Utils _utils = Utils();
  UsuarioModel? _usuario;
  bool _carregandoUsuario = true;

  final Color primaryColor = const Color(0xFF33477A);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _carregarUsuario();
    await _carregarProfissionais();
    setState(() {
      _carregandoUsuario = false;
    });
  }

  Future<void> _carregarUsuario() async {
    try {
      _usuario = await _utils.carregarUsuario();
      logger.i('Usuário carregado: ${_usuario?.name ?? 'Desconhecido'}');
    } catch (e) {
      logger.e('Erro ao carregar usuário: $e');
    }
  }

  Future<void> _carregarProfissionais() async {
    setState(() {
      _futureProfissionais = buscarProfissionais();
    });
  }

  Future<List<Map<String, dynamic>>> buscarProfissionais() async {
    try {
      final token = await _utils.obterToken();
      final Uri url = Uri.parse('${getApiBaseUrl()}/profissional');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return [];
        try {
          final decodedJson = jsonDecode(response.body);
          if (decodedJson is List) {
            return List<Map<String, dynamic>>.from(decodedJson);
          } else if (decodedJson is Map && decodedJson.containsKey('data')) {
            final data = decodedJson['data'];
            if (data is List) {
              return List<Map<String, dynamic>>.from(data);
            }
          }
          return [];
        } catch (jsonError) {
          logger.e('Erro ao decodificar JSON: $jsonError');
          throw Exception('Erro ao processar dados do servidor');
        }
      } else {
        throw Exception('Erro ao buscar profissionais: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Erro ao buscar profissionais: $e');
      throw Exception('Falha na comunicação: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_carregandoUsuario) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: const Center(child: CircularProgressIndicator()),
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
          'Indicação de Profissionais',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: Container(
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
        child: FloatingActionButton(
          onPressed: () async {
            if (_usuario == null) {
              _showErrorSnackBar(
                  'Sessão inválida. Por favor, faça login novamente.');
              return;
            }

            final resultado =
            await Navigator.pushNamed(context, '/profissionalForm');
            if (resultado == true) {
              _showSuccessSnackBar('Profissional adicionado com sucesso!');
              _carregarProfissionais();
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          tooltip: 'Adicionar Profissional',
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureProfissionais,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          }

          final profissionais = snapshot.data ?? [];

          if (profissionais.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _carregarProfissionais,
            color: primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: profissionais.length,
              itemBuilder: (context, index) {
                final profissional = profissionais[index];
                return _buildProfessionalCard(profissional, index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 16),
          Text(
            'Carregando profissionais...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard(Map<String, dynamic> profissional, int index) {
    final cardColor = _getColorByArea(profissional['areaAtuacao'] ?? '');
    final isMyIndication =
        profissional['usuario']?['id']?.toString() == _usuario?.id;
    final indicadorNome = profissional['usuario']?['name'] ??
        profissional['indicadoPor'] ??
        'Usuário não identificado';

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
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
              Container(width: 6, color: cardColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIconByArea(profissional['areaAtuacao'] ?? ''),
                              color: cardColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profissional['areaAtuacao'] ??
                                      'Especialidade não informada',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isMyIndication
                                        ? Colors.green.withOpacity(0.1)
                                        : cardColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isMyIndication
                                          ? Colors.green.withOpacity(0.3)
                                          : cardColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isMyIndication
                                            ? Icons.person_rounded
                                            : Icons.person_outline_rounded,
                                        size: 12,
                                        color: isMyIndication
                                            ? Colors.green.shade700
                                            : cardColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isMyIndication
                                            ? 'Minha indicação'
                                            : 'Indicado por $indicadorNome',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isMyIndication
                                              ? Colors.green.shade700
                                              : cardColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMyIndication) ...[
                            const SizedBox(width: 8),
                            _buildActionButtons(profissional, cardColor),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.person_rounded,
                        profissional['nome'] ?? 'Nome não informado',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.phone_rounded,
                        profissional['contato'] ?? 'Contato não informado',
                      ),
                      if (profissional['createdAt'] != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.schedule_rounded,
                          'Indicado em ${_formatDate(profissional['createdAt'])}',
                          isSecondary: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
      Map<String, dynamic> profissional, Color cardColor) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: cardColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => _editarProfissional(profissional),
            icon: Icon(
              Icons.edit_rounded,
              color: cardColor,
              size: 20,
            ),
            tooltip: 'Editar',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => _confirmarExclusao(profissional),
            icon: const Icon(
              Icons.delete_rounded,
              color: Colors.red,
              size: 20,
            ),
            tooltip: 'Excluir',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _editarProfissional(Map<String, dynamic> profissional) async {
    try {
      final resultado = await Navigator.pushNamed(
        context,
        '/profissionalForm',
        arguments: profissional,
      );

      if (resultado == true) {
        _showSuccessSnackBar('Profissional atualizado com sucesso!');
        _carregarProfissionais();
      }
    } catch (e) {
      logger.e('Erro ao editar profissional: $e');
      _showErrorSnackBar('Erro ao abrir edição do profissional');
    }
  }

  Future<void> _confirmarExclusao(Map<String, dynamic> profissional) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.orange.shade700,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Confirmar Exclusão',
                  style: TextStyle(
                    fontSize: 20,
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
              Text(
                'Tem certeza que deseja excluir a indicação de:',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profissional['nome'] ?? 'Nome não informado',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profissional['areaAtuacao'] ?? 'Área não informada',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Esta ação não pode ser desfeita.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Excluir',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      await _excluirProfissional(profissional);
    }
  }

  Future<void> _excluirProfissional(Map<String, dynamic> profissional) async {
    try {
      setState(() => _carregandoUsuario = true);

      final token = await _utils.obterToken();
      final Uri url = Uri.parse('${getApiBaseUrl()}/profissional/${profissional['id']}');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSuccessSnackBar('Profissional excluído com sucesso!');
        _carregarProfissionais();
      } else {
        String errorMessage = 'Erro ao excluir profissional';

        try {
          if (response.body.isNotEmpty) {
            final responseBody = jsonDecode(response.body);
            if (responseBody is Map) {
              errorMessage = responseBody['message'] ??
                  responseBody['error'] ??
                  errorMessage;
            }
          }
        } catch (e) {}

        logger.e(
            'Erro ao excluir profissional: ${response.statusCode} - ${response.body}');
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      logger.e('Erro ao excluir profissional: $e');
      if (!mounted) return;
      _showErrorSnackBar('Falha na comunicação: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _carregandoUsuario = false);
      }
    }
  }

  Widget _buildInfoRow(IconData icon, String text, {bool isSecondary = false}) {
    return Row(
      children: [
        Icon(icon,
            size: 16,
            color: isSecondary ? Colors.grey.shade500 : Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSecondary ? 12 : 14,
              color: isSecondary ? Colors.grey.shade500 : Colors.grey.shade700,
              fontWeight: isSecondary ? FontWeight.w400 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        return 'hoje';
      } else if (difference == 1) {
        return 'ontem';
      } else if (difference < 7) {
        return 'há $difference dias';
      } else if (difference < 30) {
        final weeks = (difference / 7).floor();
        return 'há ${weeks == 1 ? '1 semana' : '$weeks semanas'}';
      } else if (difference < 365) {
        final months = (difference / 30).floor();
        return 'há ${months == 1 ? '1 mês' : '$months meses'}';
      } else {
        final years = (difference / 365).floor();
        return 'há ${years == 1 ? '1 ano' : '$years anos'}';
      }
    } catch (e) {
      return dateString;
    }
  }

  Color _getColorByArea(String area) {
    final areaLower = area.toLowerCase();
    if (areaLower.contains('eletric')) return const Color(0xFFFF9800);
    if (areaLower.contains('encanador') || areaLower.contains('hidráulica')) return const Color(0xFF2196F3);
    if (areaLower.contains('mecânic') || areaLower.contains('mecanico')) return const Color(0xFF424242);
    if (areaLower.contains('ar condicionado') || areaLower.contains('refrigeração')) return const Color(0xFF00BCD4);
    if (areaLower.contains('soldador') || areaLower.contains('solda')) return const Color(0xFFFF6F00);
    if (areaLower.contains('serralheiro')) return const Color(0xFF607D8B);
    if (areaLower.contains('pedreiro') || areaLower.contains('construção')) return const Color(0xFFFF5722);
    if (areaLower.contains('pintor') || areaLower.contains('pintura')) return const Color(0xFF9C27B0);
    if (areaLower.contains('gesseiro') || areaLower.contains('gesso')) return const Color(0xFFE0E0E0);
    if (areaLower.contains('azulejista') || areaLower.contains('azulejo')) return const Color(0xFF00ACC1);
    if (areaLower.contains('vidraceiro') || areaLower.contains('vidro')) return const Color(0xFF81C784);
    if (areaLower.contains('marceneiro')) return const Color(0xFF795548);
    if (areaLower.contains('limpeza')) return const Color(0xFF4CAF50);
    if (areaLower.contains('diarista') || areaLower.contains('doméstica')) return const Color(0xFFE91E63);
    if (areaLower.contains('jardin')) return const Color(0xFF8BC34A);
    if (areaLower.contains('cozinheir') || areaLower.contains('chef')) return const Color(0xFFFF8F00);
    if (areaLower.contains('babá') || areaLower.contains('baba')) return const Color(0xFFFF80AB);
    if (areaLower.contains('cuidador') || areaLower.contains('enfermag')) return const Color(0xFF26A69A);
    if (areaLower.contains('massagista') || areaLower.contains('massagem')) return const Color(0xFF9575CD);
    if (areaLower.contains('barbeir') || areaLower.contains('cabeleir')) return const Color(0xFF8D6E63);
    if (areaLower.contains('manicure') || areaLower.contains('estética')) return const Color(0xFFEC407A);
    if (areaLower.contains('segurança') || areaLower.contains('porteiro')) return const Color(0xFF3F51B5);
    if (areaLower.contains('motorista') || areaLower.contains('uber')) return const Color(0xFF5D4037);
    if (areaLower.contains('técnico') && areaLower.contains('informática')) return const Color(0xFF009688);
    if (areaLower.contains('costureira') || areaLower.contains('alfaiate')) return const Color(0xFFAB47BC);
    if (areaLower.contains('advogad') || areaLower.contains('jurídic')) return const Color(0xFF1976D2);
    if (areaLower.contains('contador') || areaLower.contains('contabil')) return const Color(0xFF388E3C);
    if (areaLower.contains('arquitet') || areaLower.contains('design')) return const Color(0xFF7B1FA2);
    if (areaLower.contains('veterinári') || areaLower.contains('pet')) return const Color(0xFF689F38);
    if (areaLower.contains('professor') || areaLower.contains('tutor')) return const Color(0xFF303F9F);
    if (areaLower.contains('personal') || areaLower.contains('fitness')) return const Color(0xFFD32F2F);
    if (areaLower.contains('fotógraf') || areaLower.contains('fotografo')) return const Color(0xFF512DA8);
    return const Color(0xFF757575);
  }

  IconData _getIconByArea(String area) {
    final areaLower = area.toLowerCase();
    if (areaLower.contains('eletric')) return Icons.electrical_services_rounded;
    if (areaLower.contains('encanador') || areaLower.contains('hidráulica')) return Icons.plumbing_rounded;
    if (areaLower.contains('mecânic') || areaLower.contains('mecanico')) return Icons.build_circle_rounded;
    if (areaLower.contains('ar condicionado') || areaLower.contains('refrigeração')) return Icons.ac_unit_rounded;
    if (areaLower.contains('soldador') || areaLower.contains('solda')) return Icons.whatshot_rounded;
    if (areaLower.contains('serralheiro')) return Icons.construction_rounded;
    if (areaLower.contains('pedreiro') || areaLower.contains('construção')) return Icons.engineering_rounded;
    if (areaLower.contains('pintor') || areaLower.contains('pintura')) return Icons.format_paint_rounded;
    if (areaLower.contains('gesseiro') || areaLower.contains('gesso')) return Icons.layers_rounded;
    if (areaLower.contains('azulejista') || areaLower.contains('azulejo')) return Icons.grid_on_rounded;
    if (areaLower.contains('vidraceiro') || areaLower.contains('vidro')) return Icons.crop_free_rounded;
    if (areaLower.contains('marceneiro')) return Icons.carpenter_rounded;
    if (areaLower.contains('limpeza')) return Icons.cleaning_services_rounded;
    if (areaLower.contains('diarista') || areaLower.contains('doméstica')) return Icons.home_work_rounded;
    if (areaLower.contains('jardin')) return Icons.local_florist_rounded;
    if (areaLower.contains('cozinheir') || areaLower.contains('chef')) return Icons.restaurant_rounded;
    if (areaLower.contains('babá') || areaLower.contains('baba')) return Icons.child_care_rounded;
    if (areaLower.contains('cuidador') || areaLower.contains('enfermag')) return Icons.medical_services_rounded;
    if (areaLower.contains('massagista') || areaLower.contains('massagem')) return Icons.spa_rounded;
    if (areaLower.contains('barbeir') || areaLower.contains('cabeleir')) return Icons.content_cut_rounded;
    if (areaLower.contains('manicure') || areaLower.contains('estética')) return Icons.face_rounded;
    if (areaLower.contains('segurança') || areaLower.contains('porteiro')) return Icons.security_rounded;
    if (areaLower.contains('motorista') || areaLower.contains('uber')) return Icons.drive_eta_rounded;
    if (areaLower.contains('técnico') && areaLower.contains('informática')) return Icons.computer_rounded;
    if (areaLower.contains('costureira') || areaLower.contains('alfaiate')) return Icons.design_services_rounded;
    if (areaLower.contains('advogad') || areaLower.contains('jurídic')) return Icons.gavel_rounded;
    if (areaLower.contains('contador') || areaLower.contains('contabil')) return Icons.calculate_rounded;
    if (areaLower.contains('arquitet') || areaLower.contains('design')) return Icons.architecture_rounded;
    if (areaLower.contains('veterinári') || areaLower.contains('pet')) return Icons.pets_rounded;
    if (areaLower.contains('professor') || areaLower.contains('tutor')) return Icons.school_rounded;
    if (areaLower.contains('personal') || areaLower.contains('fitness')) return Icons.fitness_center_rounded;
    if (areaLower.contains('fotógraf') || areaLower.contains('fotografo')) return Icons.camera_alt_rounded;
    return Icons.handyman_rounded;
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade700,
                size: 64,
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Não foi possível carregar a lista de profissionais.\nVerifique sua conexão e tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _carregarProfissionais,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar Novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.people_outline_rounded,
                color: primaryColor,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhum profissional encontrado',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Ainda não há profissionais cadastrados.\nSeja o primeiro a adicionar uma indicação!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF33477A), Color(0xFF4A5B8C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_usuario == null) {
                    _showErrorSnackBar(
                        'Sessão inválida. Por favor, faça login novamente.');
                    return;
                  }

                  final resultado =
                  await Navigator.pushNamed(context, '/profissionalForm');
                  if (resultado == true) {
                    _showSuccessSnackBar(
                        'Profissional adicionado com sucesso!');
                    _carregarProfissionais();
                  }
                },
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text('Adicionar Profissional',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}