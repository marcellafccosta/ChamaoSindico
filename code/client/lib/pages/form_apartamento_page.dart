import 'package:client/controllers/apartamento_controller.dart';
import 'package:client/controllers/usuario_controller.dart';
import 'package:client/models/apartamento_model.dart';
import 'package:client/models/usuario_model.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:dropdown_search/dropdown_search.dart';

final Logger logger = Logger();

class CadastroApartamentoPage extends StatefulWidget {
  const CadastroApartamentoPage({super.key, this.apartamento});

  final ApartamentoModel? apartamento;

  @override
  State<CadastroApartamentoPage> createState() =>
      _CadastroApartamentoPageState();
}

class _CadastroApartamentoPageState extends State<CadastroApartamentoPage> {
  final _formKey = GlobalKey<FormState>();
  final _controllerApt = ApartamentoController();
  final _controllerUsuario = UsuarioController();

  late ApartamentoModel _model;
  List<UsuarioModel> _usuarios = [];
  bool _carregandoUsuarios = true;

  @override
  void initState() {
    super.initState();
    _model = widget.apartamento ?? ApartamentoModel(id: '', name: '');
    _carregarUsuarios();
  }

Future<void> _carregarUsuarios() async {
  try {
    _usuarios = await _controllerUsuario.getAllUsuarios();
    logger.i('Total de usuários carregados: ${_usuarios.length}');

    if (_model.id.isNotEmpty) {
      // pega os usuários já vinculados a esse apartamento
      final vinculados = _usuarios.where((u) => u.apartamentoId?.toString() == _model.id).toList();
      _model.userIds = vinculados.map((u) => u.id).toList();
    }

    for (var u in _usuarios) {
      logger.i('Usuário: ${u.name} - ID: ${u.id} - AptID: ${u.apartamentoId}');
    }
  } catch (e) {
    logger.e('Erro ao carregar usuários: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar usuários')),
    );
  }

  setState(() {
    _carregandoUsuarios = false;
  });
}

  @override
  Widget build(BuildContext context) {
    final isNovo = _model.id.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNovo ? 'Novo Apartamento' : 'Editar Apartamento'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              final form = _formKey.currentState;
              if (form!.validate()) {
                form.save();

                if (isNovo) {
                  final novoApt =
                      await _controllerApt.createApartamento(_model);
                  logger.i('Novo apartamento criado: ${novoApt.id}');
                  await _controllerUsuario.vincularUsuario(
                      int.parse(novoApt.id),
                      _model.userIds.map(int.parse).toList());
                } else {
                  await _controllerApt.updateApartamento(_model);
                  await _controllerUsuario.vincularUsuario(
                    int.parse(_model.id),
                    _model.userIds.map(int.parse).toList(),
                  );
                }

                Navigator.of(context).pop();
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _carregandoUsuarios
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _model.name,
                      decoration: InputDecoration(
                        labelText: 'Número do Apartamento',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo obrigatório'
                          : null,
                      onSaved: (value) => _model.name = value ?? '',
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 60, // altura total do campo
                      child: DropdownSearch<UsuarioModel>.multiSelection(
                        items: _usuarios,
                        selectedItems: _usuarios
                            .where((user) => _model.userIds.contains(user.id))
                            .toList(),
                        itemAsString: (user) => user.name,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: 'Usuários responsáveis',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        onChanged: (List<UsuarioModel> selectedUsers) {
                          setState(() {
                            _model.userIds =
                                selectedUsers.map((u) => u.id).toList();
                          });
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Selecione pelo menos um usuário'
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
