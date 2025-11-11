import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'form_reserva_page.dart';
import 'package:client/utils/utils.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/enum/role.dart';
import 'package:logger/logger.dart';
import 'package:client/utils/api_url.dart';

final Logger logger = Logger();

class AreaComum {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int peopleLimit;

  AreaComum({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.peopleLimit,
  });

  factory AreaComum.fromJson(Map<String, dynamic> json) {
    return AreaComum(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      peopleLimit: json['peopleLimit'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'peopleLimit': peopleLimit,
    };
  }
}

class ListaAreasPage extends StatefulWidget {
  const ListaAreasPage({super.key});

  @override
  State<ListaAreasPage> createState() => _ListaAreasPageState();
}

class _ListaAreasPageState extends State<ListaAreasPage> {
  final Utils _utils = Utils();
  UsuarioModel? _usuario;
  late Future<List<AreaComum>> _futureAreas = Future.value([]);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _carregarUsuario();
    setState(() {
      _futureAreas = _fetchAreas();
    });
  }

  Future<void> _carregarUsuario() async {
    _usuario = await _utils.carregarUsuario();
    logger.i(
        'Usuário carregado: ${_usuario?.name ?? 'Desconhecido'} - Role: ${_usuario?.role}');
    setState(() {});
  }

  bool get _isSindico => _usuario?.role == Role.SYNDIC;

  Future<List<AreaComum>> _fetchAreas() async {
    try {
      logger.i('Carregando áreas comuns...');
      final response = await http.get(Uri.parse('${getApiBaseUrl()}/areas'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        final areas =
        body.map((dynamic item) => AreaComum.fromJson(item)).toList();
        logger.i('${areas.length} áreas carregadas com sucesso');
        return areas;
      } else {
        logger.e('Falha ao carregar áreas: ${response.statusCode}');
        throw Exception('Falha ao carregar áreas: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Erro ao carregar áreas: $e');
      throw Exception('Erro ao carregar áreas. Verifique sua conexão.');
    }
  }

  void _refreshAreas() {
    logger.i('Atualizando lista de áreas...');
    setState(() {
      _futureAreas = _fetchAreas();
    });
  }

  Color _getAreaColor(String areaName) {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFF44336),
      const Color(0xFF607D8B),
    ];

    final index = areaName.hashCode % colors.length;
    return colors[index.abs()];
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
          'Áreas Comuns',
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
              onPressed: _refreshAreas,
              tooltip: 'Atualizar',
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchAreas();
          setState(() {
            _futureAreas = _fetchAreas();
          });
        },
        color: const Color(0xFF33477A),
        child: FutureBuilder<List<AreaComum>>(
          future: _futureAreas,
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
                      'Carregando áreas...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              logger.e('Erro no FutureBuilder: ${snapshot.error}');
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
                        'Não foi possível carregar as áreas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _refreshAreas,
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
                        Icons.deck_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Nenhuma área encontrada',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isSindico
                          ? 'Não há áreas comuns cadastradas.\nQue tal criar uma nova área?'
                          : 'Não há áreas comuns cadastradas.\nAguarde o síndico adicionar as áreas.',
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
            } else {
              List<AreaComum> areas = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: areas.length,
                itemBuilder: (context, index) {
                  final area = areas[index];
                  final areaColor = _getAreaColor(area.name);

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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          logger.i(
                              'Navegando para reserva da área: ${area.name}');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FormReservaPage(area: area),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  color: areaColor,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: areaColor.withOpacity(0.1),
                                            borderRadius:
                                            BorderRadius.circular(16),
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
                                                area.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              if (area.description != null &&
                                                  area.description!
                                                      .isNotEmpty) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  area.description!,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                ),
                                              ],
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _buildInfoChip(
                                                      Icons.people_rounded,
                                                      '${area.peopleLimit} pessoas',
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: _buildInfoChip(
                                                      Icons
                                                          .attach_money_rounded,
                                                      'R\$ ${area.price.toStringAsFixed(2)}',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 16,
                                            color: Colors.grey.shade600,
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
                    ),
                  );
                },
              );
            }
          },
        ),
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
            logger.i('Síndico navegando para criar nova área');
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CriarAreaPage()),
            );
            if (result == true) {
              logger.i('Nova área criada, atualizando lista');
              _refreshAreas();
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text(
            "Nova Área",
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

class CriarAreaPage extends StatefulWidget {
  const CriarAreaPage({super.key});

  @override
  State<CriarAreaPage> createState() => _CriarAreaPageState();
}

class _CriarAreaPageState extends State<CriarAreaPage> {
  final Utils _utils = Utils();
  UsuarioModel? _usuario;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _peopleLimitController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _carregarUsuario();
    if (_usuario?.role != Role.SYNDIC) {
      logger.w('Usuário não-síndico tentou acessar tela de criar área');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
          _showErrorSnackBar(
              'Apenas síndicos podem cadastrar áreas.', Colors.orange);
        }
      });
    }
  }

  Future<void> _carregarUsuario() async {
    _usuario = await _utils.carregarUsuario();
    logger.i(
        'Usuário carregado na tela de criar área: ${_usuario?.name ?? 'Desconhecido'} - Role: ${_usuario?.role}');
    if (mounted) {
      setState(() {});
    }
  }

  void _showErrorSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                color == Colors.orange
                    ? Icons.warning_rounded
                    : Icons.error_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          elevation: 8,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
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
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          elevation: 8,
        ),
      );
    }
  }

  Future<void> _criarArea() async {
    if (_usuario?.role != Role.SYNDIC) {
      logger.w('Tentativa de criação de área por usuário não-síndico');
      _showErrorSnackBar(
          'Acesso negado. Apenas síndicos podem criar áreas.', Colors.red);
      Navigator.of(context).pop();
      return;
    }

    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final areaData = {
      'name': _nameController.text,
      'description': _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      'price':
      double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0,
      'peopleLimit': int.tryParse(_peopleLimitController.text) ?? 0,
    };

    logger.i('Síndico criando nova área: ${areaData['name']}');

    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/areas'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(areaData),
      );

      if (!mounted) return;

      if (response.statusCode == 201 || response.statusCode == 200) {
        logger.i('Área criada com sucesso pelo síndico: ${areaData['name']}');
        _showSuccessSnackBar('Área "${areaData['name']}" criada com sucesso!');

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        logger.e(
            'Falha ao criar área: ${response.statusCode} - ${response.body}');
        _showErrorSnackBar('Falha ao criar área. Tente novamente.', Colors.red);
      }
    } catch (e) {
      logger.e('Erro de rede ao criar área: $e');
      if (!mounted) return;
      _showErrorSnackBar(
          'Erro de conexão. Verifique sua internet.', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _peopleLimitController.dispose();
    super.dispose();
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
          'Nova Área Comum',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 24),
                _buildFormSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        _buildInputCard(
          child: TextFormField(
            controller: _nameController,
            decoration: _buildInputDecoration(
              'Nome da Área',
              Icons.text_fields_rounded,
              isRequired: true,
            ),
            textInputAction: TextInputAction.next,
            validator: (value) => (value == null || value.isEmpty)
                ? 'O nome é obrigatório'
                : null,
          ),
        ),
        const SizedBox(height: 20),
        _buildInputCard(
          child: TextFormField(
            controller: _descriptionController,
            decoration: _buildInputDecoration(
              'Descrição (Opcional)',
              Icons.description_outlined,
            ),
            maxLines: 3,
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(height: 20),
        _buildInputCard(
          child: TextFormField(
            controller: _priceController,
            decoration: _buildInputDecoration(
              'Preço',
              Icons.attach_money_outlined,
              isRequired: true,
              prefix: 'R\$ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'O preço é obrigatório';
              }
              if (double.tryParse(value.replaceAll(',', '.')) == null) {
                return 'Insira um número válido';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildInputCard(
          child: TextFormField(
            controller: _peopleLimitController,
            decoration: _buildInputDecoration(
              'Limite de Pessoas',
              Icons.groups_outlined,
              isRequired: true,
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'O limite é obrigatório';
              }
              if (int.tryParse(value) == null) {
                return 'Insira um número inteiro válido';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF33477A), Color(0xFF4A5B8C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF33477A).withOpacity(0.4),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isLoading ? null : _criarArea,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading) ...[
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'CRIANDO ÁREA...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'CRIAR ÁREA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  InputDecoration _buildInputDecoration(
      String label,
      IconData icon, {
        bool isRequired = false,
        String? prefix,
      }) {
    return InputDecoration(
      labelText: isRequired ? '$label *' : label,
      prefixIcon: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF33477A).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF33477A),
          size: 20,
        ),
      ),
      prefixText: prefix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF33477A),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      labelStyle: TextStyle(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 16,
      ),
    );
  }
}