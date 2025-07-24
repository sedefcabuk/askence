import 'dart:async';
import 'dart:convert';
import 'package:web_socket_client/web_socket_client.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ChatWebService {
  static final _instance = ChatWebService._internal();
  WebSocket? _socket;
  factory ChatWebService() => _instance;
  ChatWebService._internal();
  final _searchResultController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _contentController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get searchResultStream =>
      _searchResultController.stream;
  Stream<Map<String, dynamic>> get contentStream => _contentController.stream;

  void connect() {
    String url;
    if (kIsWeb) {
      url = "ws://localhost:8000/ws/chat";
    } else if (Platform.isAndroid) {
      url = "ws://10.0.2.2:8000/ws/chat"; // Emülatör için özel IP
    } else {
      url =
          "ws://localhost:8000/ws/chat"; // iOS simülatör veya diğer platformlar
    }

    _socket = WebSocket(Uri.parse(url));
    _socket!.messages.listen((message) {
      final data = json.decode(message);
      if (data['type'] == 'search_result') {
        _searchResultController.add(data);
      } else if (data['type'] == 'content') {
        _contentController.add(data);
      }
    });
  }

  void chat(String query) {
    _socket!.send(json.encode({'query': query}));
  }

  void dispose() {
    _socket?.close();
    _searchResultController.close();
    _contentController.close();
  }
}
