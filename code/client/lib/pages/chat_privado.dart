import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:client/utils/api_url.dart';

class ChatPrivadoPage extends StatefulWidget {
  final String userId;
  final String targetUserId;
  final String? targetUserName;

  const ChatPrivadoPage({
    super.key,
    required this.userId,
    required this.targetUserId,
    this.targetUserName,
  });

  @override
  State<ChatPrivadoPage> createState() => _ChatPrivadoPageState();
}

class _ChatPrivadoPageState extends State<ChatPrivadoPage> {
  final ScrollController _scrollController = ScrollController();

  late IO.Socket socket;
  final TextEditingController messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  bool get isGeral => widget.targetUserId == '0';

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadChatHistory();
    connectSocket();
  }

  void connectSocket() {
    final url = getSocketBaseUrl();
    socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      socket.emit('register-user', widget.userId);
    });

    socket.on('general-message', (data) {
      if (isGeral) {
        final fromUserId = data['fromUserId'].toString();
        setState(() {
          messages.add({
            'fromUserId': fromUserId,
            'content': data['content'] ?? '',
            'senderName':
            fromUserId == widget.userId ? 'Você' : data['senderName'],
          });
        });
        scrollToBottom();
      }
    });

    socket.on('private-message', (data) {
      final fromUserId = data['fromUserId'].toString();
      final toUserId = data['toUserId'].toString();

      final isChatWithTarget =
          (fromUserId == widget.targetUserId && toUserId == widget.userId) ||
              (fromUserId == widget.userId && toUserId == widget.targetUserId);

      if (isChatWithTarget) {
        final isMine = fromUserId == widget.userId;
        setState(() {
          messages.add({
            'fromUserId': fromUserId,
            'content': data['content'],
            'senderName': isMine ? 'Você' : data['senderName'],
          });
        });
      }
    });
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      socket.emit('private-message', {
        'fromUserId': int.parse(widget.userId),
        'toUserId': int.parse(widget.targetUserId),
        'content': text,
      });

      messageController.clear();
    }
  }

  Future<void> loadChatHistory() async {
    final baseUrl = getSocketBaseUrl();
    final url = isGeral
        ? Uri.parse('$baseUrl/api/chat-geral')
        : Uri.parse(
        '$baseUrl/api/chat-privado?user1=${widget.userId}&user2=${widget.targetUserId}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        messages = List<Map<String, dynamic>>.from(data.map((e) {
          final isMine = e['fromUserId'].toString() == widget.userId;
          return {
            'fromUserId': e['fromUserId'].toString(),
            'content': e['content'],
            'senderName': isMine ? 'Você' : e['senderName'],
          };
        }));

        scrollToBottom();
      });
    } else {
      print("Erro ao carregar histórico: ${response.body}");
    }
  }

  @override
  void dispose() {
    socket.off('general-message');
    socket.off('private-message');
    socket.disconnect();
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = isGeral ? 'Chat Geral' : 'Chat com ${widget.targetUserName}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF33477A),
        foregroundColor: Colors.white,
        title: Text(title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: messages.length,
              itemBuilder: (_, index) {
                final message = messages[index];
                final isMine =
                    message['fromUserId']?.toString() == widget.userId;

                final content = message['content'] ?? '';
                final senderName = message['senderName'] ?? 'Desconhecido';

                return Align(
                  alignment:
                  isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isMine
                          ? const Color(0xFF33477A)
                          : const Color(0xFFE1EFF6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMine && isGeral)
                          Text(
                            senderName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF33477A),
                            ),
                          ),
                        Text(
                          content,
                          style: TextStyle(
                            color: isMine ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: messageController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Digite sua mensagem...',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF33477A),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}