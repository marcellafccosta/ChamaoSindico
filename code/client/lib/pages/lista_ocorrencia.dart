import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/utils/utils.dart';
import 'package:client/models/usuario_model.dart';
import 'package:client/utils/api_url.dart';
import 'package:flutter/foundation.dart';

class ListaOcorrenciasPage extends StatefulWidget {
  const ListaOcorrenciasPage({super.key});

  @override
  State<ListaOcorrenciasPage> createState() => _ListaOcorrenciasPageState();
}

class _ListaOcorrenciasPageState extends State<ListaOcorrenciasPage> {
  late Future<List<Map<String, dynamic>>> _futureOcorrencias;
  final Utils _utils = Utils();
  UsuarioModel? _usuario;

  bool _canCreateOccurrence() => kIsWeb;
  bool _canEditOccurrence() => kIsWeb;
  bool _canRemoveOccurrence() => kIsWeb;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _carregarUsuario();
    _carregarOcorrencias();
  }

  Future<void> _carregarUsuario() async {
    _usuario = await _utils.carregarUsuario();
    setState(() {});
  }

  void _carregarOcorrencias() {
    _futureOcorrencias = buscarOcorrencias();
  }

  Future<List<Map<String, dynamic>>> buscarOcorrencias() async {
    if (_usuario?.accessToken == null) {
      throw Exception('Usuário não autenticado');
    }

    final apiBase = getApiBaseUrl();
    final Uri url = Uri.parse('$apiBase/registro-ocorrencia');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${_usuario!.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      final List<Map<String, dynamic>> ocorrencias =
          List<Map<String, dynamic>>.from(jsonDecode(response.body));
      return ocorrencias;
    } else {
      throw Exception('Erro ao buscar ocorrências: ${response.statusCode}');
    }
  }

  bool _canEditOrRemove(Map<String, dynamic> ocorrencia) {
    if (_usuario == null) return false;

    final user = ocorrencia['user'];
    final userId = ocorrencia['userId'];

    if (user != null && user is Map<String, dynamic>) {
      final userIdFromUser = user['id'];
      if (userIdFromUser != null) {
        return userIdFromUser.toString() == _usuario!.id.toString();
      }
    }

    if (userId != null) {
      return userId.toString() == _usuario!.id.toString();
    }

    return false;
  }

  Future<void> _removerOcorrencia(
      int id, Map<String, dynamic> ocorrencia) async {
    if (!_canRemoveOccurrence()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você só pode excluir ocorrências pela versão web'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_canEditOrRemove(ocorrencia)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você só pode excluir ocorrências que você criou'),
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

    final apiBase = getApiBaseUrl();
    final Uri url = Uri.parse('$apiBase/registro-ocorrencia/$id');

    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_usuario!.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocorrência excluída com sucesso')),
      );
      setState(() {
        _carregarOcorrencias();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir ocorrência: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      floatingActionButton: _canCreateOccurrence()
          ? FloatingActionButton(
              onPressed: () async {
                final resultado =
                    await Navigator.pushNamed(context, '/ocorrenciasForm');
                if (resultado == true) {
                  setState(() {
                    _carregarOcorrencias();
                  });
                }
              },
              backgroundColor: const Color(0xFF33477A),
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureOcorrencias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final ocorrencias = snapshot.data ?? [];

          if (ocorrencias.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nenhuma ocorrência registrada.'),
                  if (!kIsWeb) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Para criar ocorrências, acesse a versão web.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: ocorrencias.length,
            itemBuilder: (context, index) {
              final o = ocorrencias[index];
              final podeEditar = _canEditOrRemove(o);

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(
                    o['categoria'] ?? 'Sem categoria',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Período: ${o['periodo']}\nLocalização: ${o['localizacao']}\nDescrição: ${o['descricao']}',
                      ),
                      // ADICIONAR INFORMAÇÃO PARA MOBILE:
                      if (!kIsWeb && podeEditar) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Para editar/excluir, acesse a versão web.',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: kIsWeb && podeEditar && _canEditOccurrence()
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                final resultado = await Navigator.pushNamed(
                                  context,
                                  '/ocorrenciasForm',
                                  arguments: o,
                                );
                                if (resultado == true) {
                                  setState(() {
                                    _carregarOcorrencias();
                                  });
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removerOcorrencia(o['id'], o),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
