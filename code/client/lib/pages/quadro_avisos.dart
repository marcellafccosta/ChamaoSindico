import 'dart:async';
import 'dart:convert';
import 'package:client/enum/role.dart';
import 'package:client/pages/post_it.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:client/services/socket_service.dart';
import 'package:client/utils/api_url.dart';

class QuadroAvisos extends StatefulWidget {
  final String userId;
  final String userName;
  final Role userRole;

  const QuadroAvisos({
    super.key,
    required this.userId,
    required this.userName,
    required this.userRole,
  });

  @override
  QuadroAvisosState createState() => QuadroAvisosState();
}

class QuadroAvisosState extends State<QuadroAvisos> {
  List<Map<String, dynamic>> postItData = [];
  bool showAll = false;
  bool isLoading = false;
  String? errorMessage;

  Uri get baseUrl => Uri.parse('${getApiBaseUrl()}/aviso');

  SocketService? _socketService; // ← Nullable

  @override
  void initState() {
    super.initState();

    fetchPostIts();
    _setupSocketIfNotWeb();

    _setupAutoRefresh();
  }

  Timer? _refreshTimer;

  void _setupAutoRefresh() {
    if (kIsWeb) {
      print('🔄 Configurando auto-refresh para web (5 minutos)');
      _refreshTimer = Timer.periodic(Duration(minutes: 5), (timer) {
        if (mounted) {
          print('🔄 Auto-refresh executando...');
          fetchPostIts();
        } else {
          timer.cancel();
        }
      });
    }
  }

  void _setupSocketIfNotWeb() {
    try {
      if (!kIsWeb) {
        print('🔌 Conectando socket (não-web)');
        _socketService = SocketService();
        _socketService!.connect();
        _socketService!.messages.listen((message) {
          if (message != null && message['event'] == 'novo_aviso') {
            final novoAviso = message['data'];
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Novo Aviso: ${novoAviso['assunto']}'),
                  backgroundColor: Colors.blueAccent,
                ),
              );
              setState(() {
                postItData.insert(0, _formatAviso(novoAviso));
                _sortPostIts();
              });
            }
          }
        });
      } else {
        print('🌐 Web detectada - Socket desabilitado');
      }
    } catch (e) {
      print('❌ Erro ao conectar socket: $e');
    }
  }

  @override
  void dispose() {
    try {
      _socketService?.disconnect();
      _refreshTimer?.cancel();
    } catch (e) {
      print('❌ Erro ao desconectar socket: $e');
    }
    super.dispose();
  }


  Map<String, dynamic> _formatAviso(Map<String, dynamic> item) {
    try {
      final isImportant = item['isImportant'] as bool? ?? false;
      final isReuniao = item['isReuniao'] as bool? ?? false;

      String? dataReuniao;
      if (isReuniao && item['dataReuniao'] != null) {
        try {
          dataReuniao = DateFormat('dd/MM/yyyy')
              .format(DateTime.parse(item['dataReuniao']));
        } catch (e) {
          print('⚠️ Erro ao formatar data reunião: $e');
          dataReuniao = null;
        }
      }

      return {
        "color": const Color(0xFFE8DB6D),
        "isImportant": isImportant,
        "isReuniao": isReuniao,
        "dataReuniao": dataReuniao,
        "assunto": item['assunto']?.toString() ?? 'Sem assunto',
        "aviso": item['aviso']?.toString() ?? 'Sem conteúdo',
        "id": item['id'],
        "autor": item['autor']?.toString() ?? 'Anônimo',
      };
    } catch (e) {
      print('❌ Erro ao formatar aviso: $e');
      
      return {
        "color": const Color(0xFFE8DB6D),
        "isImportant": false,
        "isReuniao": false,
        "dataReuniao": null,
        "assunto": 'Erro',
        "aviso": 'Erro ao carregar aviso',
        "id": item['id'] ?? 0,
        "autor": 'Sistema',
      };
    }
  }

  void _sortPostIts() {
    try {
      postItData.sort((a, b) {
        int getPriority(Map<String, dynamic> item) {
          final bool imp = item['isImportant'] ?? false;
          final bool reun = item['isReuniao'] ?? false;
          if (imp && reun) return 0;
          if (imp && !reun) return 1;
          if (!imp && reun) return 2;
          return 3;
        }

        return getPriority(a).compareTo(getPriority(b));
      });
    } catch (e) {
      print('❌ Erro ao ordenar post-its: $e');
    }
  }

// ✅ Requisição mais robusta
  Future<void> fetchPostIts() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('📡 Buscando avisos: $baseUrl');

      final response = await http.get(
        baseUrl,
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10)); // ← Timeout

      print('📡 Resposta avisos: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('📄 ${data.length} avisos recebidos');

        final formattedData = <Map<String, dynamic>>[];

        // Processar cada item com try-catch individual
        for (int i = 0; i < data.length; i++) {
          try {
            final formatted = _formatAviso(data[i]);
            formattedData.add(formatted);
          } catch (e) {
            print('❌ Erro ao formatar aviso $i: $e');
            // Continua processando os outros
          }
        }

        if (mounted) {
          setState(() {
            postItData = formattedData;
            _sortPostIts();
            isLoading = false;
          });
        }
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('❌ Erro ao buscar avisos: $e');
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
          // Não limpar postItData - manter dados anteriores se houver
        });
      }
    }
  }

  void _showPostItDialog(BuildContext context, Map<String, dynamic> data) {
    try {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Fechar',
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => _PostItDialog(
          data: data,
          userRole: widget.userRole,
          userId: widget.userId,
          onUpdated: fetchPostIts,
        ),
        transitionBuilder: (_, anim, __, child) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
            child: FadeTransition(
              opacity: anim,
              child: child,
            ),
          );
        },
      );
    } catch (e) {
      print('❌ Erro ao abrir dialog: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao abrir aviso: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ Indicador de loading
            if (isLoading)
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('Carregando avisos...'),
                  ],
                ),
              )

            // ✅ Mensagem de erro
            else if (errorMessage != null && postItData.isEmpty)
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 32),
                    SizedBox(height: 10),
                    Text('Erro ao carregar avisos'),
                    SizedBox(height: 5),
                    Text(
                      errorMessage!,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: fetchPostIts,
                      child: Text('Tentar Novamente'),
                    ),
                  ],
                ),
              )

            // ✅ Grid de avisos
            else if (postItData.isNotEmpty) ...[
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 130,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: (showAll ? postItData : postItData.take(6)).length,
                itemBuilder: (context, index) {
                  final displayList =
                      showAll ? postItData : postItData.take(6).toList();
                  final data = displayList[index];

                  return PostIt(
                    color: data['color'],
                    isImportant: data['isImportant'],
                    isReuniao: data['isReuniao'],
                    dataReuniao: data['dataReuniao'],
                    assunto: data['assunto'],
                    onTap: () => _showPostItDialog(context, data),
                  );
                },
              ),
              if (postItData.length > 6)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: TextButton(
                    onPressed: () => setState(() => showAll = !showAll),
                    child: Text(
                        showAll ? 'Ver menos avisos' : 'Ver todos os avisos'),
                  ),
                ),
            ]

            // ✅ Estado vazio
            else
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey, size: 32),
                    SizedBox(height: 10),
                    Text(
                      'Nenhum aviso disponível',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    } catch (e) {
      print('❌ Erro no build QuadroAvisos: $e');
      return Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error, color: Colors.red, size: 32),
            SizedBox(height: 10),
            Text('Erro no Quadro de Avisos'),
            Text('$e', style: TextStyle(fontSize: 12)),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: Text('Recarregar'),
            ),
          ],
        ),
      );
    }
  }
}

class _PostItDialog extends StatefulWidget {
  final Map<String, dynamic> data;
  final Role userRole;
  final String userId;
  final VoidCallback onUpdated;

  const _PostItDialog({
    required this.data,
    required this.userRole,
    required this.userId,
    required this.onUpdated,
  });

  @override
  State<_PostItDialog> createState() => _PostItDialogState();
}

class _PostItDialogState extends State<_PostItDialog> {
  late bool isEditing;
  late bool isImportant;
  late bool isReuniao;
  late String assunto;
  late String aviso;
  DateTime? dataReuniao;

  @override
  void initState() {
    super.initState();
    isEditing = false;
    isImportant = widget.data['isImportant'];
    isReuniao = widget.data['isReuniao'];
    assunto = widget.data['assunto'] ?? '';
    aviso = widget.data['aviso'] ?? '';
    if (widget.data['dataReuniao'] != null) {
      dataReuniao = DateFormat('dd/MM/yyyy').parse(widget.data['dataReuniao']);
    }
  }

  Future<void> _deleteAviso() async {
    final url = Uri.parse('${getApiBaseUrl()}/aviso/${widget.data['id']}');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200 || response.statusCode == 204) {
        widget.onUpdated();
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.userId == widget.data['autor'];

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFFFF59D),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black38, blurRadius: 10, offset: Offset(3, 3)),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.push_pin, size: 38, color: Colors.red[700]),
                const SizedBox(height: 8),
                if (!isEditing) ...[
                  if (isImportant)
                    Text(
                      'IMPORTANTE!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[900],
                        fontSize: 18,
                      ),
                    ),
                  if (isReuniao && dataReuniao != null)
                    Text(
                      'Reunião: ${DateFormat('dd/MM/yyyy').format(dataReuniao!)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    assunto,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const Divider(),
                  Text(
                    aviso,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.justify,
                  ),
                ] else ...[
                  CheckboxListTile(
                    title: const Text('Marcar como importante'),
                    value: isImportant,
                    onChanged: (v) => setState(() => isImportant = v ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  CheckboxListTile(
                    title: const Text('É uma reunião?'),
                    value: isReuniao,
                    onChanged: (v) {
                      setState(() {
                        isReuniao = v ?? false;
                        if (!isReuniao) dataReuniao = null;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (isReuniao)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dataReuniao == null
                                ? 'Selecione a data'
                                : DateFormat('dd/MM/yyyy').format(dataReuniao!),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: dataReuniao ??
                                  DateTime.now().add(const Duration(days: 1)),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 365 * 2)),
                            );
                            if (picked != null) {
                              setState(() => dataReuniao = picked);
                            }
                          },
                          child: const Text('Escolher'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: assunto,
                    maxLength: 50,
                    decoration: InputDecoration(
                      labelText: 'Assunto',
                      prefixIcon: const Icon(Icons.subject),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (v) => assunto = v,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: aviso,
                    minLines: 3,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: 'Aviso',
                      prefixIcon: const Icon(Icons.note_alt),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: (v) => aviso = v,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF33477A),
                      minimumSize: const Size.fromHeight(42),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (assunto.trim().isEmpty || aviso.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Preencha todos os campos')),
                        );
                        return;
                      }

                      final body = {
                        "assunto": assunto,
                        "aviso": aviso,
                        "isImportant": isImportant,
                        "isReuniao": isReuniao,
                        "dataReuniao": isReuniao && dataReuniao != null
                            ? dataReuniao!.toIso8601String()
                            : null,
                      };

                      final url = Uri.parse(
                          '${getApiBaseUrl()}/aviso/${widget.data['id']}');

                      try {
                        final response = await http.patch(
                          url,
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(body),
                        );
                        if (response.statusCode == 200) {
                          widget.onUpdated();
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Erro: ${response.statusCode}')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao salvar: $e')),
                        );
                      }
                    },
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (canEdit && !isEditing)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => setState(() => isEditing = true),
                        tooltip: 'Editar',
                      ),
                    if (canEdit && !isEditing)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: _deleteAviso,
                        tooltip: 'Excluir',
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Fechar',
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
