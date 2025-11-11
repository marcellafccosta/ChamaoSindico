import 'package:client/controllers/usuario_controller.dart';
import 'package:client/controllers/vaga_controller.dart';
import 'package:client/controllers/apartamento_controller.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/models/vaga_model.dart';
import 'package:client/models/apartamento_model.dart';
import 'package:flutter/material.dart';

class FormVagaPage extends StatefulWidget {
  const FormVagaPage({super.key, this.vaga});

  final VagaModel? vaga;

  @override
  State<FormVagaPage> createState() => _FormVagaPageState();
}

class _FormVagaPageState extends State<FormVagaPage> {
  final _formKey = GlobalKey<FormState>();
  final _controllerApt = VagaController();
  final _controllerApartamento = ApartamentoController();
  final _controllerUsuario = UsuarioController();

  late VagaModel _model;
  List<ApartamentoModel> _apartamento = [];
  List<UsuarioModel> _condominos = [];
  bool _carregandoCondominos = true;
  bool _carregandoApartamentos = true;

  @override
  void initState() {
    super.initState();
    _model = widget.vaga ?? VagaModel(id: '', name: '', isOcupada: false);
    _carregarApartamentos();
    _carregarCondominos();
  }

  Future<void> _carregarApartamentos() async {
    try {
      _apartamento = await _controllerApartamento.getAllApartamentos();
      print('Apartamentos cadastros: $_apartamento');
    } catch (e) {
      print(e);
    }
    setState(() {
      _carregandoApartamentos = false;
    });
  }

  Future<void> _carregarCondominos() async {
    try {
      List<UsuarioModel> usuarios = await _controllerUsuario.getAllUsuarios();
      _condominos = usuarios.where((u) => u.role == 'RESIDENT').toList();
      print('Condominos cadastros: $_condominos');
    } catch (e) {
      print(e);
    }
    setState(() {
      _carregandoCondominos = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNovo = _model.id.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNovo ? 'Novo Vaga' : 'Editar Vaga'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              final form = _formKey.currentState;
              if (form!.validate()) {
                form.save();

                if (isNovo) {
                  print(_model.apartamentoId);
                  await _controllerApt.createVaga(_model);
                } else {
                  await _controllerApt.updateVaga(_model);
                }

                Navigator.of(context).pop();
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _carregandoApartamentos
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _model.name,
                      decoration: InputDecoration(
                        labelText: 'Nome da Vaga',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Campo obrigatório'
                          : null,
                      onSaved: (value) => _model.name = value ?? '',
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _model.apartamentoId,
                      decoration: InputDecoration(
                        labelText: 'Apartamento responsável',
                        border: OutlineInputBorder(),
                      ),
                      items: _apartamento
                          .map((a) => DropdownMenuItem(
                                value: int.parse(a.id),
                                child: Text(a.name),
                              ))
                          .toList(),
                      validator: (value) =>
                          value == null ? 'Selecione um apartamento' : null,
                      onChanged: (value) {
                        setState(() {
                          _model.apartamentoId = value;
                          _model.apartamento =
                              _apartamento.firstWhere((a) => a.id == value);
                        });
                      },
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
