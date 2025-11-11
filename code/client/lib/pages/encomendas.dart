import 'package:client/utils/storage_helper.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:client/utils/utils.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/enum/role.dart';
import 'package:client/utils/api_url.dart'; 

class EncomendasPage extends StatefulWidget {
  const EncomendasPage({super.key});

  @override
  State<EncomendasPage> createState() => _EncomendasPageState();
}

class _EncomendasPageState extends State<EncomendasPage> {
  final List<Map<String, dynamic>> _encomendas = [];
  Map<int, String> _apartamentos = {};
  bool _showForm = false;
  bool _showFinalizadas = false;

  bool _isEditing = false;
  int? _editingId;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController storeController = TextEditingController();
  final TextEditingController keywordController = TextEditingController();
  final TextEditingController recipientController = TextEditingController();
  DateTime? estimatedDelivery;

  final Utils _utils = Utils();
  UsuarioModel? _usuario;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _carregarUsuario();
    _fetchEncomendas();
    _fetchApartamentos();
  }

  Future<void> _carregarUsuario() async {
    _usuario = await _utils.carregarUsuario();
    setState(() {});
  }

  bool _canChangeStatus() {
    return _usuario?.role == Role.EMPLOYEE || _usuario?.role == Role.RESIDENT;
  }

  bool _canCreatePackage() {
    return _usuario?.role == Role.RESIDENT && kIsWeb;
  }

  bool _canSeeAllPackages() {
    return _usuario?.role == Role.EMPLOYEE;
  }

  bool _canEditPackage() {
    return _usuario?.role == Role.RESIDENT && kIsWeb;
  }

  bool _canRemovePackage() {
    return _usuario?.role == Role.RESIDENT && kIsWeb;
  }

  bool _canCancelPackage() {
    return _usuario?.role == Role.RESIDENT;
  }

  bool _canMarkAsDelivered() {
    return _usuario?.role == Role.EMPLOYEE;
  }

  void _removerEncomenda(int id) async {
    if (_usuario?.accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário não autenticado')),
      );
      return;
    }

    final response = await http.delete(
      Uri.parse('${getApiBaseUrl()}/package/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_usuario!.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Encomenda excluída com sucesso')),
      );
      _fetchEncomendas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir encomenda: ${response.body}')),
      );
    }
  }

  void _fetchEncomendas() async {
    if (_usuario?.accessToken == null) {
      print('Usuário não autenticado');
      return;
    }

    try {
      String url = '${getApiBaseUrl()}/package';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${_usuario!.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _encomendas.clear();

          if (_usuario!.role == Role.RESIDENT) {
            final filtradas = data.where((encomenda) {
              int? encomendaApartamentoId;

              if (encomenda['apartamento'] != null) {
                encomendaApartamentoId = encomenda['apartamento']['id'];
              }

              return encomendaApartamentoId == _usuario!.apartamentoId;
            }).toList();

            _encomendas.addAll(
                filtradas.map((e) => e as Map<String, dynamic>).toList());
          } else {
            _encomendas
                .addAll(data.map((e) => e as Map<String, dynamic>).toList());
          }
        });
      }
    } catch (e) {
      print('Erro completo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: ${e.toString()}')),
      );
    }
  }

  void _fetchApartamentos() async {
    if (_usuario?.accessToken == null) {
      print('Usuário não autenticado');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${getApiBaseUrl()}/apartamento'),
        headers: {
          'Authorization': 'Bearer ${_usuario!.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _apartamentos = {
            for (var apartamento in data)
              apartamento['id']: apartamento['name'],
          };
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao carregar apartamentos: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: ${e.toString()}')),
      );
    }
  }

  void _submitForm() async {
    if (!_canCreatePackage()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apenas moradores podem criar encomendas'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_usuario?.apartamentoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Você precisa estar vinculado a um apartamento para registrar uma encomenda. Entre em contato com o síndico.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (estimatedDelivery == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe a data estimada de entrega.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> payload = {
        'store': storeController.text,
        'keyword': keywordController.text,
        'recipient': recipientController.text,
        'estimatedDelivery': estimatedDelivery!.toIso8601String(),
        'apartamentoId': _usuario!.apartamentoId,
        "status": 'PENDENTE',
      };

      try {
        final response = _isEditing
            ? await http.patch(
          Uri.parse('${getApiBaseUrl()}/package/$_editingId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_usuario!.accessToken}',
          },
          body: jsonEncode(payload),
        )
            : await http.post(
          Uri.parse('${getApiBaseUrl()}/package'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_usuario!.accessToken}',
          },
          body: jsonEncode(payload),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          _fetchEncomendas();
          setState(() {
            storeController.clear();
            keywordController.clear();
            recipientController.clear();
            estimatedDelivery = null;
            _showForm = false;
            _isEditing = false;
            _editingId = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_isEditing
                    ? 'Encomenda atualizada com sucesso'
                    : 'Encomenda registrada com sucesso!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Erro ao ${_isEditing ? 'atualizar' : 'registrar'} encomenda: ${response.statusCode} ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de conexão: ${e.toString()}')),
        );
      }
    }
  }

  void _editarEncomenda(Map<String, dynamic> encomenda) {
    setState(() {
      _isEditing = true;
      _editingId = encomenda['id'];
      _showForm = true;

      storeController.text = encomenda['store'] ?? '';
      keywordController.text = encomenda['keyword'] ?? '';
      recipientController.text = encomenda['recipient'] ?? '';

      if (encomenda['estimatedDelivery'] != null) {
        estimatedDelivery = DateTime.parse(encomenda['estimatedDelivery']);
      }
    });
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: storeController,
              decoration: const InputDecoration(labelText: 'Loja'),
              validator: (value) =>
              value == null || value.isEmpty ? 'Informe a loja' : null,
            ),
            TextFormField(
              controller: keywordController,
              decoration: const InputDecoration(labelText: 'Palavra-chave (opcional)'),
            ),
            TextFormField(
              controller: recipientController,
              decoration: const InputDecoration(labelText: 'Destinatário'),
              validator: (value) => value == null || value.isEmpty
                  ? 'Informe o destinatário'
                  : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(estimatedDelivery == null
                  ? 'Selecionar data estimada'
                  : 'Entrega estimada: ${_utils.formatarData(estimatedDelivery)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 100)),
                );
                if (picked != null) {
                  setState(() => estimatedDelivery = picked);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(_isEditing ? 'Atualizar' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEncomendaCard(Map<String, dynamic> encomenda) {
    final statusAtual = encomenda['status'] ?? 'Desconhecido';
    final int id = encomenda['id'];

    DateTime? dataEntrega;
    if (encomenda['estimatedDelivery'] != null) {
      try {
        dataEntrega = DateTime.parse(encomenda['estimatedDelivery']);
      } catch (e) {
        print('Erro ao parsear data: $e');
      }
    }

    void _atualizarStatus(String novoStatus) async {
      if (!_canChangeStatus()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Apenas funcionários podem alterar o status das encomendas'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_usuario?.accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado')),
        );
        return;
      }

      final response = await http.patch(
        Uri.parse('${getApiBaseUrl()}/package/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_usuario!.accessToken}',
        },
        body: jsonEncode({'status': novoStatus}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status atualizado para $novoStatus')),
        );
        _fetchEncomendas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar status: ${response.body}')),
        );
      }
    }

    final apartamentoName = encomenda['apartamento']?['name'] ?? 'Desconhecido';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.local_shipping, size: 40),
              title: Text(
                '${encomenda['store']} - $apartamentoName',
                style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Palavra-chave: ${encomenda['keyword']?.isEmpty == true || encomenda['keyword'] == null ? 'Não informada' : encomenda['keyword']}',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: $statusAtual',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Destinatário: ${encomenda['recipient'] ?? 'Não informado'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Entrega estimada: ${_utils.formatarData(dataEntrega)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!['ENTREGUE', 'CANCELADO'].contains(statusAtual) &&
                    _canEditPackage())
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _editarEncomenda(encomenda);
                    },
                  ),
                if (_canRemovePackage())
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _removerEncomenda(id);
                    },
                  ),
              ],
            ),
            if (['PENDENTE', 'ATRASADO'].contains(statusAtual) &&
                _canChangeStatus()) ...[
              const Divider(height: 32),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: statusAtual,
                      isDense: true,
                      items: [
                        DropdownMenuItem<String>(
                          value: statusAtual,
                          child: Text(statusAtual),
                          enabled: false,
                        ),
                        if (_canCancelPackage())
                          DropdownMenuItem<String>(
                            value: 'CANCELADO',
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                const Text('CANCELADO'),
                              ],
                            ),
                          ),
                        if (_canMarkAsDelivered())
                          DropdownMenuItem<String>(
                            value: 'ENTREGUE',
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                const Text('ENTREGUE'),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (String? novo) {
                        if (novo != null && novo != statusAtual) {
                          _atualizarStatus(novo);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_usuario == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final encomendasAtivas = _encomendas.where((encomenda) {
      final status = encomenda['status'] ?? '';
      return !['ENTREGUE', 'CANCELADO'].contains(status);
    }).toList();

    final encomendasFinalizadas = _encomendas.where((encomenda) {
      final status = encomenda['status'] ?? '';
      return ['ENTREGUE', 'CANCELADO'].contains(status);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _encomendas.isEmpty
          ? const Center(child: Text('Nenhuma encomenda registrada.'))
          : ListView(
        children: [
          ...encomendasAtivas.map(_buildEncomendaCard).toList(),
          if (encomendasFinalizadas.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showFinalizadas = !_showFinalizadas;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.archive_outlined,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Encomendas Finalizadas (${encomendasFinalizadas.length})',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _showFinalizadas ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: _showFinalizadas ? null : 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showFinalizadas ? 1.0 : 0.0,
                child: Column(
                  children: _showFinalizadas
                      ? encomendasFinalizadas
                      .map(_buildEncomendaCard)
                      .toList()
                      : [],
                ),
              ),
            ),
          ],
          if (encomendasAtivas.isEmpty && encomendasFinalizadas.isEmpty)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhuma encomenda registrada',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          if (encomendasAtivas.isEmpty &&
              encomendasFinalizadas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 48, color: Colors.green[400]),
                    const SizedBox(height: 12),
                    Text(
                      'Todas as encomendas foram finalizadas!',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_showForm
            ? (_isEditing ? 'Editar Encomenda' : 'Nova Encomenda')
            : 'Encomendas'),
        centerTitle: true,
        backgroundColor: const Color(0xFF33477A),
        foregroundColor: Colors.white,
        leading: _showForm
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showForm = false;
              _isEditing = false;
              _editingId = null;
              storeController.clear();
              keywordController.clear();
              recipientController.clear();
              estimatedDelivery = null;
            });
          },
        )
            : null,
      ),
      body: _showForm ? _buildForm() : _buildList(),
      floatingActionButton: (!_showForm && _canCreatePackage())
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _showForm = true;
            _isEditing = false;
            _editingId = null;
          });
        },
        backgroundColor: const Color(0xFF33477A),
        child: const Icon(Icons.add, color: Colors.white),
      )
          : null,
    );
  }
}