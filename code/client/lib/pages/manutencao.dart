import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/utils/utils.dart';
import 'package:client/models/usuario_model.dart';
import 'package:logger/logger.dart';
import 'package:client/utils/api_url.dart';

final Logger logger = Logger();

const List<String> tiposManutencao = ['Preventiva', 'Preditiva'];
const List<String> tiposEquipamento = [
  'Elevador',
  'Câmera de segurança',
  'Porta automática',
  'Portão da Garagem',
  'Portão de Pedestre',
  'Outro'
];
const List<String> frequenciasManutencao = [
  'Diária',
  'Semanal',
  'Mensal',
  'Anual'
];

class ManutencaoPage extends StatefulWidget {
  const ManutencaoPage({super.key});

  @override
  State<ManutencaoPage> createState() => _ManutencaoPageState();
}

class _ManutencaoPageState extends State<ManutencaoPage> {
  final _formKey = GlobalKey<FormState>();
  final Utils _utils = Utils();
  UsuarioModel? _usuario;
  Map<String, dynamic>? _manutencaoParaEditar;

  String? _tipoManutencaoSelecionado;
  String? _tipoEquipamentoSelecionado;
  String? _frequenciaSelecionada;
  bool _isLoading = false;
  bool _carregandoUsuario = true;

  final TextEditingController _dataManutencaoController =
  TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();
  final TextEditingController _responsavelController = TextEditingController();
  final TextEditingController _dataProximaManutencaoController =
  TextEditingController();

  final Color primaryColor = const Color(0xFF33477A);

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      _manutencaoParaEditar = arguments;
      _preencherCamposParaEdicao();
    }
  }

  void _preencherCamposParaEdicao() {
    if (_manutencaoParaEditar != null) {
      final manutencao = _manutencaoParaEditar!;
      if (manutencao['status'] == 'CONCLUIDO') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Não é possível editar manutenções concluídas.'),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.pop(context);
        });
        return;
      }
      _tipoManutencaoSelecionado = manutencao['tipoManutencao'];
      _tipoEquipamentoSelecionado = manutencao['tipoEquipamento'];
      _frequenciaSelecionada = manutencao['frequencia'];
      _responsavelController.text = manutencao['responsavel'] ?? '';
      _observacoesController.text = manutencao['observacoes'] ?? '';

      if (manutencao['dataManutencao'] != null) {
        try {
          final date = DateTime.parse(manutencao['dataManutencao']);
          _dataManutencaoController.text =
              DateFormat('dd/MM/yyyy').format(date);
        } catch (e) {
          logger.e('Erro ao formatar data de manutenção: $e');
        }
      }

      if (manutencao['dataProximaManutencao'] != null) {
        try {
          final date = DateTime.parse(manutencao['dataProximaManutencao']);
          _dataProximaManutencaoController.text =
              DateFormat('dd/MM/yyyy').format(date);
        } catch (e) {
          logger.e('Erro ao formatar data próxima manutenção: $e');
        }
      }
    }
  }

  bool get _isEditMode => _manutencaoParaEditar != null;

  Future<void> _init() async {
    await _carregarUsuario();
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
    setState(() {});
  }

  @override
  void dispose() {
    _dataManutencaoController.dispose();
    _observacoesController.dispose();
    _responsavelController.dispose();
    _dataProximaManutencaoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
        calcularDataProximaManutencao();
      });
    }
  }

  void calcularDataProximaManutencao() {
    if (_dataManutencaoController.text.isEmpty ||
        _frequenciaSelecionada == null) {
      _dataProximaManutencaoController.clear();
      return;
    }

    try {
      final DateTime dataManutencao =
      DateFormat('dd/MM/yyyy').parse(_dataManutencaoController.text);
      late DateTime proximaData;

      switch (_frequenciaSelecionada) {
        case 'Diária':
          proximaData = dataManutencao.add(const Duration(days: 1));
          break;
        case 'Semanal':
          proximaData = dataManutencao.add(const Duration(days: 7));
          break;
        case 'Mensal':
          proximaData = DateTime(dataManutencao.year, dataManutencao.month + 1,
              dataManutencao.day);
          break;
        case 'Anual':
          proximaData = DateTime(dataManutencao.year + 1, dataManutencao.month,
              dataManutencao.day);
          break;
        default:
          _dataProximaManutencaoController.clear();
          return;
      }

      _dataProximaManutencaoController.text =
          DateFormat('dd/MM/yyyy').format(proximaData);
    } catch (e) {
      logger.e('Erro ao calcular próxima manutenção: $e');
      _dataProximaManutencaoController.clear();
    }
  }

  Future<void> _submitForm() async {
    if (_usuario == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Sessão inválida. Por favor, faça login novamente.'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (_dataManutencaoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Text('Por favor, selecione a data da manutenção.'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final DateFormat inputFormat = DateFormat('dd/MM/yyyy');
      final DateFormat outputFormat = DateFormat('yyyy-MM-dd');

      final manutencaoData = {
        'tipoManutencao': _tipoManutencaoSelecionado,
        'tipoEquipamento': _tipoEquipamentoSelecionado,
        'frequencia': _frequenciaSelecionada,
        'dataManutencao': outputFormat
            .format(inputFormat.parse(_dataManutencaoController.text)),
        'dataProximaManutencao':
        _dataProximaManutencaoController.text.isNotEmpty
            ? outputFormat.format(
            inputFormat.parse(_dataProximaManutencaoController.text))
            : null,
        'responsavel': _responsavelController.text,
        'observacoes': _observacoesController.text,
        'manutencaoRealizada': false,
      };

      try {
        final token = await _utils.obterToken();

        final Uri url = _isEditMode
            ? Uri.parse('${getApiBaseUrl()}/manutencao/${_manutencaoParaEditar!['id']}')
            : Uri.parse('${getApiBaseUrl()}/manutencao');

        final response = _isEditMode
            ? await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(manutencaoData),
        )
            : await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(manutencaoData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(_isEditMode
                      ? 'Manutenção atualizada com sucesso!'
                      : 'Manutenção criada com sucesso!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception(
              'Erro ao ${_isEditMode ? 'atualizar' : 'criar'} manutenção: ${response.body}');
        }
      } catch (e) {
        logger
            .e('Erro ao ${_isEditMode ? 'atualizar' : 'criar'} manutenção: $e');
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Falha na comunicação: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregandoUsuario) {
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
        title: Text(
          _isEditMode ? 'Editar Manutenção' : 'Agendar Manutenção',
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
              _buildFormCard(
                title: 'Detalhes da Manutenção',
                icon: Icons.build_circle_outlined,
                children: [
                  _buildDropdownField(
                    label: 'Tipo de Manutenção',
                    icon: Icons.shield_outlined,
                    value: _tipoManutencaoSelecionado,
                    items: tiposManutencao,
                    onChanged: (value) =>
                        setState(() => _tipoManutencaoSelecionado = value),
                    validator: (v) => v == null ? 'Selecione o tipo' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Tipo de Equipamento',
                    icon: Icons.devices_other_outlined,
                    value: _tipoEquipamentoSelecionado,
                    items: tiposEquipamento,
                    onChanged: (value) =>
                        setState(() => _tipoEquipamentoSelecionado = value),
                    validator: (v) =>
                    v == null ? 'Selecione o equipamento' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFormCard(
                title: 'Agendamento',
                icon: Icons.calendar_month_outlined,
                children: [
                  _buildDropdownField(
                    label: 'Frequência',
                    icon: Icons.event_repeat_outlined,
                    value: _frequenciaSelecionada,
                    items: frequenciasManutencao,
                    onChanged: (value) {
                      setState(() {
                        _frequenciaSelecionada = value;
                        calcularDataProximaManutencao();
                      });
                    },
                    validator: (v) =>
                    v == null ? 'Selecione a frequência' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildSelectTile(
                    icon: Icons.calendar_today_outlined,
                    title: _dataManutencaoController.text.isEmpty
                        ? 'Selecione a data da manutenção'
                        : 'Data: ${_dataManutencaoController.text}',
                    isSelected: _dataManutencaoController.text.isNotEmpty,
                    onTap: () =>
                        _selectDate(context, _dataManutencaoController),
                  ),
                  const SizedBox(height: 16),
                  if (_dataProximaManutencaoController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border:
                        Border.all(color: primaryColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.update_outlined,
                              color: primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Próxima manutenção: ${_dataProximaManutencaoController.text}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFormCard(
                title: 'Informações Adicionais',
                icon: Icons.info_outline,
                children: [
                  _buildTextField(
                    controller: _responsavelController,
                    label: 'Responsável',
                    icon: Icons.person_outline,
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Insira o responsável' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _observacoesController,
                    label: 'Observações',
                    icon: Icons.notes_outlined,
                    maxLines: 4,
                  ),
                ],
              ),
              const SizedBox(height: 32),
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
                  onPressed: _isLoading ? null : _submitForm,
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
                      : Icon(
                      _isEditMode
                          ? Icons.update_rounded
                          : Icons.send_outlined,
                      color: Colors.white),
                  label: Text(
                    _isLoading
                        ? (_isEditMode ? 'ATUALIZANDO...' : 'AGENDANDO...')
                        : (_isEditMode
                        ? 'ATUALIZAR MANUTENÇÃO'
                        : 'AGENDAR MANUTENÇÃO'),
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
                Icon(icon, color: primaryColor, size: 24),
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

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required FormFieldValidator<String?> validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    FormFieldValidator<String?>? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryColor),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        maxLines: maxLines,
        validator: validator,
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
                ? primaryColor.withOpacity(0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? primaryColor.withOpacity(0.3)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isEnabled
                    ? (isSelected ? primaryColor : Colors.grey.shade600)
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
                        ? (isSelected ? primaryColor : Colors.grey.shade700)
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
}