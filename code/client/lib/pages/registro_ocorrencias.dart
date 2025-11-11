import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/utils/utils.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/utils/api_url.dart';
import 'package:flutter/foundation.dart';

class RegistroOcorrenciasPage extends StatelessWidget {
  const RegistroOcorrenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Registro de Ocorrências'),
          centerTitle: true,
          backgroundColor: const Color(0xFF33477A),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.web,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Registro de Ocorrências',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Esta funcionalidade está disponível apenas na versão web.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Acesse pelo navegador para criar e editar ocorrências.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Ocorrências'),
        centerTitle: true,
        backgroundColor: const Color(0xFF33477A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: OcorrenciaForm(),
      ),
    );
  }
}

class OcorrenciaForm extends StatefulWidget {
  final Map<String, dynamic>? dadosEdicao;
  const OcorrenciaForm({super.key, this.dadosEdicao});

  @override
  State<OcorrenciaForm> createState() => _OcorrenciaFormState();
}

class _OcorrenciaFormState extends State<OcorrenciaForm> {
  final _formKey = GlobalKey<FormState>();
  final Utils _utils = Utils();
  UsuarioModel? _usuario;

  final TextEditingController _localizacaoController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  final List<String> ocorrencias = [
    'Infrações das Regras Condominio',
    'Ocorrências de Seguranca',
    'Ocorrências Ambientais',
    'Ocorrências Administrativas',
    'Problemas Estruturais',
    'Outros'
  ];

  final List<String> periodos = ['Manhã', 'Tarde', 'Noite'];

  String? ocorrenciaSelecionada;
  String? periodoOcorrencia;
  String? idOcorrencia;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  Future<void> _inicializarDados() async {
    _usuario = await _utils.carregarUsuario();

    if (widget.dadosEdicao != null) {
      final dados = widget.dadosEdicao!;
      _preencherFormulario(dados);
    }

    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (idOcorrencia == null) {
      final Map<String, dynamic>? args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _preencherFormulario(args);
      }
    }
  }

  void _preencherFormulario(Map<String, dynamic> dados) {
    idOcorrencia = dados['id']?.toString();
    ocorrenciaSelecionada = dados['categoria'];
    periodoOcorrencia = dados['periodo'];
    _localizacaoController.text = dados['localizacao'] ?? '';
    _descricaoController.text = dados['descricao'] ?? '';
  }

  @override
  void dispose() {
    _localizacaoController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> enviarOcorrencia() async {
    if (_usuario?.accessToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário não autenticado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final apiBase = getApiBaseUrl();
    final Uri url = Uri.parse('$apiBase/registro-ocorrencia');

    final dados = {
      'categoria': ocorrenciaSelecionada,
      'periodo': periodoOcorrencia,
      'localizacao': _localizacaoController.text,
      'descricao': _descricaoController.text,
    };

    final body = jsonEncode(dados);

    final response = await (idOcorrencia != null
        ? http.patch(
            url.replace(path: '${url.path}/$idOcorrencia'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${_usuario!.accessToken}',
            },
            body: body,
          )
        : http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${_usuario!.accessToken}',
            },
            body: body,
          ));

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(idOcorrencia != null
                ? 'Ocorrência atualizada com sucesso'
                : 'Ocorrência criada com sucesso')),
      );

      _formKey.currentState!.reset();
      setState(() {
        ocorrenciaSelecionada = null;
        periodoOcorrencia = null;
        _localizacaoController.clear();
        _descricaoController.clear();
      });

      Navigator.pop(context, true);
    } else if (response.statusCode == 403) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você não tem permissão para esta ação'),
        ),
      );
    } else if (response.statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorrência não encontrada'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Erro ao salvar: ${response.statusCode} - ${response.body}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_usuario == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Categoria da Ocorrência',
              hintText: 'Escolha a categoria',
              border: OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            value: ocorrenciaSelecionada,
            items: ocorrencias.map((String ocorrencia) {
              return DropdownMenuItem<String>(
                  value: ocorrencia, child: Text(ocorrencia));
            }).toList(),
            validator: (value) => value == null || value.isEmpty
                ? 'Por favor, selecione uma ocorrência'
                : null,
            onChanged: (String? newValue) {
              setState(() {
                ocorrenciaSelecionada = newValue;
              });
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
              decoration: const InputDecoration(
                labelText: 'Localização',
                hintText: 'ex: bloco, andar, área comum...',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              maxLines: 1,
              controller: _localizacaoController,
              validator: (value) => value == null || value.isEmpty
                  ? 'Por favor, fale onde ocorreu a ocorrência'
                  : null),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Período da Ocorrência',
              hintText: 'Escolha o período',
              border: OutlineInputBorder(),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            value: periodoOcorrencia,
            items: periodos.map((String periodo) {
              return DropdownMenuItem<String>(
                  value: periodo, child: Text(periodo));
            }).toList(),
            validator: (value) => value == null || value.isEmpty
                ? 'Por favor, selecione o período'
                : null,
            onChanged: (String? newValue) {
              setState(() {
                periodoOcorrencia = newValue;
              });
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Descreva detalhadamente a sua ocorrência',
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelStyle:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              maxLines: 5,
              controller: _descricaoController,
              validator: (value) => value == null || value.isEmpty
                  ? 'Por favor, descreva como ocorreu a ocorrência'
                  : null),
          const SizedBox(height: 20),
          if (kIsWeb)
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await enviarOcorrencia();
                  }
                },
                child: Text(idOcorrencia != null
                    ? 'Atualizar Ocorrência'
                    : 'Registrar Ocorrência'),
              ),
            ),
        ],
      ),
    );
  }
}
