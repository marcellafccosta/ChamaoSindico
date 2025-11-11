import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:client/utils/utils.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/enum/role.dart';
import 'package:logger/logger.dart';
import 'package:client/utils/api_url.dart';

final Logger logger = Logger();

class ManutencaoCard extends StatelessWidget {
  final Map<String, dynamic> manutencao;
  final VoidCallback onRealizar;
  final VoidCallback? onEditar;
  final bool canEdit;
  final bool canMarkAsDone;

  const ManutencaoCard({
    required this.manutencao,
    required this.onRealizar,
    this.onEditar,
    this.canEdit = false,
    this.canMarkAsDone = false,
    super.key,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ATRASADO':
        return Colors.red;
      case 'CONCLUIDO':
        return Colors.grey;
      case 'EM DIA':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'ATRASADO':
        return Icons.warning_rounded;
      case 'CONCLUIDO':
        return Icons.check_circle_rounded;
      case 'EM DIA':
        return Icons.schedule_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(manutencao['status']);
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
              Container(width: 6, color: statusColor),
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
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getStatusIcon(manutencao['status']),
                              color: statusColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  manutencao['tipoEquipamento'] ??
                                      'Equipamento',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  manutencao['tipoManutencao'] ?? '',
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: statusColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              manutencao['status'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                          if (canEdit && onEditar != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: onEditar,
                                icon: const Icon(Icons.edit_rounded,
                                    color: Colors.blue, size: 20),
                                tooltip: 'Editar',
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                    minWidth: 36, minHeight: 36),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.calendar_today_rounded,
                          'Data da Manutenção', manutencao['dataManutencao']),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.repeat_rounded, 'Frequência',
                          manutencao['frequencia']),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.person_rounded, 'Responsável',
                          manutencao['responsavel']),
                      if (manutencao['observacoes'] != null &&
                          manutencao['observacoes'].toString().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.note_rounded,
                                      size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Observações:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                manutencao['observacoes'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildInfoRow(
                          Icons.schedule_rounded,
                          'Próxima Manutenção',
                          manutencao['dataProximaManutencao']),
                      if (manutencao['status'] != 'CONCLUIDO' &&
                          canMarkAsDone) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: onRealizar,
                            icon: const Icon(Icons.check_circle_outline_rounded,
                                size: 20),
                            label: const Text('Marcar como Realizada'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
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

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value ?? 'N/A',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class ExibirManutencaoPage extends StatefulWidget {
  const ExibirManutencaoPage({super.key});

  @override
  State<ExibirManutencaoPage> createState() => _ExibirManutencaoPageState();
}

class _ExibirManutencaoPageState extends State<ExibirManutencaoPage> {
  final Utils _utils = Utils();
  UsuarioModel? _usuario;
  List<Map<String, dynamic>> manutencoes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _carregarUsuario();
    await fetchManutencoes();
  }

  Future<void> _carregarUsuario() async {
    _usuario = await _utils.carregarUsuario();
    logger.i(
        'Usuário carregado na tela de manutenções: ${_usuario?.name ?? 'Desconhecido'} - Role: ${_usuario?.role}');
    if (mounted) setState(() {});
  }

  bool get _isSindico => _usuario?.role == Role.SYNDIC;

  Future<void> fetchManutencoes() async {
    try {
      logger.i('Carregando manutenções...');
      setState(() {
        isLoading = true;
      });
      final Uri url = Uri.parse('${getApiBaseUrl()}/manutencao');
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final dados =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
        dados.sort((a, b) {
          const ordem = {'ATRASADO': 0, 'EM DIA': 1, 'CONCLUIDO': 2};
          return ordem[a['status']]!.compareTo(ordem[b['status']]!);
        });
        logger.i('${dados.length} manutenções carregadas com sucesso');
        setState(() {
          manutencoes = dados;
          isLoading = false;
        });
      } else {
        logger.e('Erro ao buscar manutenções: ${response.statusCode}');
        throw Exception('Erro ao buscar manutenções: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Erro ao carregar manutenções: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Erro ao carregar manutenções. Tente novamente.');
      }
    }
  }

  Future<void> _marcarComoRealizada(int id) async {
    if (!_isSindico) {
      _showErrorSnackBar(
          'Apenas síndicos podem marcar manutenções como realizadas.');
      return;
    }
    try {
      logger.i('Marcando manutenção $id como realizada');
      final url = Uri.parse('${getApiBaseUrl()}/manutencao/$id');
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'manutencaoRealizada': true}),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        logger.i('Manutenção $id marcada como realizada com sucesso');
        _showSuccessSnackBar('Manutenção marcada como realizada!');
        await fetchManutencoes();
      } else {
        logger.e(
            'Erro ao marcar manutenção como realizada: ${response.statusCode}');
        _showErrorSnackBar('Erro ao marcar manutenção como realizada.');
      }
    } catch (e) {
      logger.e('Erro de rede ao marcar manutenção: $e');
      if (!mounted) return;
      _showErrorSnackBar('Erro de conexão. Tente novamente.');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Colors.white),
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

  Future<void> _editarManutencao(Map<String, dynamic> manutencao) async {
    try {
      final resultado = await Navigator.pushNamed(
        context,
        '/manutencaoForm',
        arguments: manutencao,
      );
      if (resultado == true) {
        _showSuccessSnackBar('Manutenção atualizada com sucesso!');
        fetchManutencoes();
      }
    } catch (e) {
      logger.e('Erro ao editar manutenção: $e');
      _showErrorSnackBar('Erro ao abrir edição da manutenção');
    }
  }

  Widget _buildManutencaoCard(Map<String, dynamic> manutencao) {
    return ManutencaoCard(
      manutencao: manutencao,
      onRealizar: () => _marcarComoRealizada(manutencao['id']),
      onEditar: _isSindico ? () => _editarManutencao(manutencao) : null,
      canEdit: _isSindico,
      canMarkAsDone: _isSindico,
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Manutenções',
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
              onPressed: fetchManutencoes,
              tooltip: 'Atualizar',
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchManutencoes,
        color: const Color(0xFF33477A),
        child: _buildBody(),
      ),
      floatingActionButton: _usuario == null
          ? null
          : _isSindico
              ? Container(
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
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      logger.i('Síndico navegando para criar nova manutenção');
                      final resultado =
                          await Navigator.pushNamed(context, '/manutencaoForm');
                      if (resultado == true) {
                        logger.i('Nova manutenção criada, atualizando lista');
                        fetchManutencoes();
                      }
                    },
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text(
                      "Nova Manutenção",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : null,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33477A)),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Carregando manutenções...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (manutencoes.isEmpty) {
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
                Icons.build_outlined,
                size: 80,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nenhuma manutenção encontrada',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isSindico
                  ? 'Não há manutenções cadastradas.\nQue tal adicionar uma nova manutenção?'
                  : 'Não há manutenções cadastradas.\nAguarde o síndico adicionar as manutenções.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: manutencoes.length,
      itemBuilder: (context, index) => _buildManutencaoCard(manutencoes[index]),
    );
  }
}
