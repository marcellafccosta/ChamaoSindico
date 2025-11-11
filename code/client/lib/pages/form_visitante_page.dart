import 'package:client/controllers/apartamento_controller.dart';
import 'package:client/controllers/visitante_controller.dart';
import 'package:client/enum/role.dart';
import 'package:client/enum/tipo_visitante.dart';
import 'package:client/models/apartamento_model.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/models/visitante_model.dart';
import 'package:client/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger();

class FormVisitantePage extends StatefulWidget {
  const FormVisitantePage({super.key, this.visitante});
  final VisitanteModel? visitante;

  @override
  State<FormVisitantePage> createState() => _FormVisitantePageState();
}

class _FormVisitantePageState extends State<FormVisitantePage> {
  final _formKey = GlobalKey<FormState>();
  final _controllerVisitante = VisitanteController();
  final _controllerApartamento = ApartamentoController();
  final Utils _utils = Utils();
  UsuarioModel? _usuario;

  late VisitanteModel? _model;
  List<ApartamentoModel> _apartamento = [];
  bool _carregandoApartamentos = true;

  @override
  void initState() {
    super.initState();
    _model = widget.visitante ??
        VisitanteModel(
          id: 0,
          name: '',
          document: '',
          phone: '',
          model: '',
          typeVisitant: TipoVisitante.PESSOAL,
          userId: 0,
          apartamentoId: null,
        );
    _init();
  }

  Future<void> _init() async {
    await _carregarUsuario();

    await userApartamentoId();
    await _carregarApartamentos();
    setState(() {});
  }

  userApartamentoId() async {
    if (_usuario!.role != Role.EMPLOYEE) {
      _model!.apartamentoId = _usuario!.apartamentoId;
    }
  }

  Future<void> _carregarUsuario() async {
    _usuario = await _utils.carregarUsuario();
    logger.i('Usuário carregado: ${_usuario?.name ?? 'Desconhecido'}');
    setState(() {});
  }

  Future<void> _carregarApartamentos() async {
    try {
      _apartamento = await _controllerApartamento.getAllApartamentos();
    } catch (e) {
      print(e);
    }
    setState(() {
      _carregandoApartamentos = false;
    });
  }

  Future<void> _salvar() async {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();

      // limpa os campos de checkIn/out antes de salvar
      final visitanteParaSalvar = VisitanteModel(
        id: _model!.id,
        name: _model!.name,
        document: _model!.document,
        phone: _model!.phone,
        model: _model!.model,
        userId: _model!.userId,
        typeVisitant: _model!.typeVisitant,
        apartamentoId: _model!.apartamentoId,
      );

      if (_model!.id == 0) {
        await _controllerVisitante.createVisitante(visitanteParaSalvar);
      } else {
        await _controllerVisitante.updateVisitante(visitanteParaSalvar);
      }

      if (context.mounted) Navigator.pop(context, true);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  InputDecoration _inputDecorationSemIcone(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_model == null || _carregandoApartamentos) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isNovo = _model!.id == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNovo ? 'Novo Visitante' : 'Editar Visitante'),
        centerTitle: true,
        backgroundColor: const Color(0xFF33477A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              final form = _formKey.currentState;
              if (form!.validate()) {
                form.save();
                if (isNovo) {
                  _model!.userId = int.parse(_usuario!.id);
                  if (_model!.apartamentoId == null &&
                      _usuario!.role != Role.EMPLOYEE) {
                    _model!.apartamentoId = _usuario!.apartamentoId;
                  }
                  await _controllerVisitante.createVisitante(_model!);
                } else {
                  _model!
                    ..checkIn = null
                    ..checkOut = null;
                  await _controllerVisitante.updateVisitante(_model!);
                }
                Navigator.of(context).pop();
              }
            },
          )
        ],
      ),
      body: _carregandoApartamentos
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _model!.name,
                      decoration:
                          _inputDecoration('Nome do Visitante', Icons.person),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obrigatório' : null,
                      onSaved: (value) => _model!.name = value!,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      initialValue: _model!.document,
                      decoration: _inputDecoration('Documento', Icons.badge),
                      validator: (value) =>
                          value!.isEmpty ? 'Campo obrigatório' : null,
                      onSaved: (value) => _model!.document = value!,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<TipoVisitante>(
                      value: _model!.typeVisitant,
                      decoration: _inputDecorationSemIcone('Tipo de Visitante'),
                      items: TipoVisitante.values.map((tipo) {
                        return DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo.name),
                        );
                      }).toList(),
                      validator: (value) =>
                          value == null ? 'Selecione um tipo' : null,
                      onChanged: (value) {
                        setState(() => _model!.typeVisitant = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    ...(_model!.typeVisitant != TipoVisitante.ENTREGADOR
                        ? [
                            TextFormField(
                              initialValue: _model!.phone,
                              decoration: InputDecoration(
                                labelText: 'Telefone do Visitante',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
                              onSaved: (value) => _model!.phone = value ?? '',
                            ),
                          ]
                        : [
                            TextFormField(
                              initialValue: _model!.model,
                              decoration: InputDecoration(
                                labelText: 'Modelo do Automóvel do Visitante',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Campo obrigatório'
                                      : null,
                              onSaved: (value) => _model!.model = value ?? '',
                            ),
                          ]),

                    SizedBox(height: 16),
                    ...(_usuario?.role == Role.EMPLOYEE
                        ? [
                            DropdownButtonFormField<int>(
                              value: _model!.apartamentoId,
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
                              validator: (value) => value == null
                                  ? 'Selecione um apartamento'
                                  : null,
                              onChanged: (value) {
                                setState(() {
                                  _model!.apartamentoId = value;
                                  _model!.apartamento = _apartamento.firstWhere(
                                      (a) => int.parse(a.id) == value);
                                });
                              },
                            ),
                          ]
                        : []),
                    SizedBox(height: 24),

                    ...(isNovo
                        ? []
                        : [
                            Text(
                              'Check-in: ${_utils.formatarData(_model!.checkIn)}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Check-out: ${_utils.formatarData(_model!.checkOut)}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 24),
                          ]),
                    SizedBox(height: 24),

                    // Botão final
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _usuario?.role == Role.EMPLOYEE &&
              _model!.checkOut == null &&
              !isNovo
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  await _controllerVisitante.check(_model!);
                  final visitanteAtt =
                      await _controllerVisitante.getVisitanteById((_model!.id));
                  setState(() {
                    _model = visitanteAtt;
                  }); // atualiza a UI com novo checkIn
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                      _model!.checkIn == null
                          ? '✅ Check-in realizado com sucesso'
                          : '✅ Check-out realizado com sucesso',
                    )),
                  );
                },
                child: Text(
                  _model!.checkIn == null
                      ? 'Fazer Check-In'
                      : 'Fazer Check-Out',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            )
          : null,
    );
  }
}
