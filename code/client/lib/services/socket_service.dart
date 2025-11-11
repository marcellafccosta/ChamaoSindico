import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';

class SocketService {
  late IOWebSocketChannel _channel;
  final String _serverUrl = 'ws://10.0.2.2:3000';

  Stream<dynamic> get messages => _channel.stream.map((message) {
    return jsonDecode(message);
  });

  void connect() {
    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(_serverUrl));
      debugPrint('Conectado ao WebSocket: $_serverUrl');
    } catch (e) {
      debugPrint('Erro ao conectar ao WebSocket: $e');
    }
  }

  void disconnect() {
    _channel.sink.close();
  }
}