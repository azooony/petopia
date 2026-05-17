import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_client.dart';
import 'auth_storage.dart';
import '../models/chat_models.dart';

class ChatService {
  static IO.Socket? _socket;

  // Decoded from the JWT on connect — avoids depending on a separate SharedPreferences key.
  static String? _currentUserId;
  static String? get currentUserId => _currentUserId;

  static final Set<String> _joinedRooms = {};

  // Mutex: prevents two concurrent connect() calls from racing.
  static bool _isConnecting = false;
  static Completer<void>? _connectCompleter;

  static final _msgController = StreamController<ChatMessage>.broadcast();
  static Stream<ChatMessage> get messageStream => _msgController.stream;

  static final _sentController = StreamController<ChatMessage>.broadcast();
  static Stream<ChatMessage> get messageSentStream => _sentController.stream;

  static final _errorController = StreamController<String>.broadcast();
  static Stream<String> get errorStream => _errorController.stream;

  static final _connController = StreamController<bool>.broadcast();
  static Stream<bool> get connectionStream => _connController.stream;

  static bool get isConnected => _socket?.connected ?? false;

  // Decode userId from JWT without requiring connect() to have been called first.
  static Future<String?> ensureCurrentUserId() async {
    if (_currentUserId != null) return _currentUserId;
    final token = await AuthStorage.getToken();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final padded = base64Url.normalize(parts[1]);
        final payload = jsonDecode(utf8.decode(base64Url.decode(padded)))
            as Map<String, dynamic>;
        _currentUserId = payload['userId'] as String?;
      }
    } catch (_) {}
    return _currentUserId;
  }

  // ── HTTP ──────────────────────────────────────────────────────────────────

  static Future<Conversation> initiateConversation({
    required String targetUserId,
    required String context,
  }) async {
    final res = await ApiClient.post('/chat/initiate', {
      'targetUserId': targetUserId,
      'context': context,
    });
    return Conversation.fromJson(res['data'] as Map<String, dynamic>);
  }

  static Future<List<Conversation>> getConversations() async {
    final res = await ApiClient.get('/chat/conversations');
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .map((e) =>
            Conversation.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<List<ChatMessage>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    final res = await ApiClient.get(
        '/chat/conversations/$conversationId/messages?page=$page&limit=$limit');
    final list = res['data'] as List<dynamic>? ?? [];
    return list
        .map((e) =>
            ChatMessage.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ── Socket ────────────────────────────────────────────────────────────────

  static Future<void> connect() async {
    // If another connect() is already running, wait for it to finish.
    if (_isConnecting) {
      print('[ChatService] connect() — already in progress, waiting...');
      if (_connectCompleter != null) await _connectCompleter!.future;
      return;
    }
    _isConnecting = true;
    _connectCompleter = Completer<void>();

    try {
      await _doConnect();
    } catch (_) {
      // Connection errors are broadcast via _connController; swallow here.
    } finally {
      // Capture before nulling — disconnect() may have already nulled it.
      final c = _connectCompleter;
      _isConnecting = false;
      _connectCompleter = null;
      if (c != null && !c.isCompleted) c.complete();
    }
  }

  static Future<void> _doConnect() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      print('[ChatService] _doConnect() — no token, aborting');
      _connController.add(false);
      return;
    }

    // Decode userId from current token first — needed to detect account switch.
    String? newUserId;
    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        final padded = base64Url.normalize(parts[1]);
        final payload = jsonDecode(utf8.decode(base64Url.decode(padded)))
            as Map<String, dynamic>;
        newUserId = payload['userId'] as String?;
      }
    } catch (_) {}

    // If already connected as the SAME user, skip reconnect.
    if (_socket != null && _socket!.connected &&
        newUserId != null && _currentUserId == newUserId) {
      print('[ChatService] _doConnect() — already connected as $newUserId, skipping');
      return;
    }

    // Different user or not yet connected — always (re)connect with fresh socket.
    if (_socket != null) {
      print('[ChatService] _doConnect() — account changed or stale socket, reconnecting');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    _currentUserId = newUserId;
    print('[ChatService] _doConnect() — userId=$_currentUserId');

    // Android emulator reaches host via 10.0.2.2; web uses localhost.
    final url = kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
    print('[ChatService] connecting to $url ...');

    // enableForceNew() bypasses the socket.io-client URL-level Manager cache,
    // ensuring a brand-new authenticated socket every time we (re)connect.
    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .enableForceNew()
          .build(),
    );

    print('[ChatService] socket created, registering handlers...');

    _socket!.onConnect((_) {
      print('[ChatService] socket CONNECTED ✅  userId=$_currentUserId');
      _connController.add(true);
      for (final roomId in _joinedRooms) {
        _socket!.emit('join_room', {'conversationId': roomId});
      }
    });

    _socket!.onDisconnect((_) {
      print('[ChatService] socket DISCONNECTED');
      _connController.add(false);
    });

    _socket!.onConnectError((err) {
      print('[ChatService] socket CONNECT ERROR: $err');
      _connController.add(false);
    });

    _socket!.on('receive_message', (raw) {
      try {
        final data = _unwrap(raw);
        final msg = ChatMessage.fromJson(data);
        print('[ChatService] receive_message  senderId=${msg.senderId}  convId=${msg.conversationId}  _currentUserId=$_currentUserId');
        _msgController.add(msg);
      } catch (_) {}
    });

    _socket!.on('message_sent', (raw) {
      try {
        final data = _unwrap(raw);
        _sentController.add(ChatMessage.fromJson(data));
      } catch (_) {}
    });

    _socket!.on('error', (raw) {
      try {
        final data = _unwrap(raw);
        final msg = data['message'] as String? ?? 'Socket error';
        _errorController.add(msg);
      } catch (_) {
        _errorController.add('An unknown socket error occurred');
      }
    });

    _socket!.connect();
    print('[ChatService] socket.connect() called for userId=$_currentUserId');
  }

  static Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is List) {
      return Map<String, dynamic>.from(raw[0] as Map);
    }
    return Map<String, dynamic>.from(raw as Map);
  }

  static void joinRoom(String conversationId) {
    _joinedRooms.add(conversationId);
    _socket?.emit('join_room', {'conversationId': conversationId});
  }

  static void sendMessage(String conversationId, String content) {
    print('[ChatService] sendMessage  _currentUserId=$_currentUserId  connected=${_socket?.connected}  convId=$conversationId');
    _socket?.emit(
        'send_message', {'conversationId': conversationId, 'content': content});
  }

  static void disconnect() {
    _isConnecting = false;
    if (_connectCompleter != null && !_connectCompleter!.isCompleted) {
      _connectCompleter!.complete();
    }
    _connectCompleter = null;
    _joinedRooms.clear();
    _currentUserId = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connController.add(false);
  }
}
