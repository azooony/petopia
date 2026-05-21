import 'dart:async';
import 'package:flutter/material.dart';
import 'services/chat_service.dart';
import 'services/auth_storage.dart';

enum MessageStatus { pending, sent, failed }

class Message {
  final String? serverMessageId;
  final String localId;
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;
  final MessageStatus status;

  const Message({
    this.serverMessageId,
    required this.localId,
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  Message copyWith({String? serverMessageId, MessageStatus? status}) =>
      Message(
        serverMessageId: serverMessageId ?? this.serverMessageId,
        localId: localId,
        text: text,
        isSentByMe: isSentByMe,
        timestamp: timestamp,
        status: status ?? this.status,
      );
}

class ChatScreen extends StatefulWidget {
  // null/empty = local-only demo mode (no backend)
  final String? conversationId;
  final String recipientName;
  final String? recipientImage;

  const ChatScreen({
    super.key,
    this.conversationId,
    required this.recipientName,
    this.recipientImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = [];

  int _localIdCounter = 0;

  StreamSubscription? _msgSub;
  StreamSubscription? _sentSub;
  StreamSubscription? _errSub;
  StreamSubscription? _connSub;

  String? _currentUserId;
  bool _isLoading = true;
  bool _isConnected = false;

  bool get _hasBackend =>
      widget.conversationId != null && widget.conversationId!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Prefer SharedPreferences; fall back to userId decoded from JWT.
    // ensureCurrentUserId() decodes the JWT independently — no connect() needed.
    _currentUserId =
        await AuthStorage.getUserId() ?? await ChatService.ensureCurrentUserId();

    // ── Auth diagnostic ──────────────────────────────────────────────────────
    final diagToken = await AuthStorage.getToken();
    debugPrint('\n==== ChatScreen._init ====');
    debugPrint('  userId  : ${_currentUserId ?? "NULL — NOT LOGGED IN"}');
    debugPrint('  token   : ${diagToken != null ? "EXISTS (${diagToken.length} chars)" : "NULL — NOT LOGGED IN"}');
    debugPrint('  convId  : ${widget.conversationId ?? "null (demo mode)"}');
    debugPrint('==========================\n');
    if (mounted) {
      final ok = diagToken != null && _currentUserId != null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          ok
              ? '✓ Logged in | ${_hasBackend ? "conv=${widget.conversationId!.substring(0, 8)}..." : "demo mode"}'
              : '✗ NOT LOGGED IN — token is null. Please log in first.',
        ),
        backgroundColor: ok ? const Color(0xFF388E3C) : Colors.red[800],
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
    // ────────────────────────────────────────────────────────────────────────

    if (!_hasBackend) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    _connSub = ChatService.connectionStream.listen((connected) {
      if (!mounted) return;
      final wasConnected = _isConnected;
      setState(() => _isConnected = connected);
      if (connected && !wasConnected) {
        ChatService.joinRoom(widget.conversationId!);
      }
    });

    await ChatService.connect();

    if (mounted && ChatService.isConnected) {
      setState(() => _isConnected = true);
    }

    await _loadHistory();

    ChatService.joinRoom(widget.conversationId!);

    _msgSub = ChatService.messageStream
        .where((m) => m.conversationId == widget.conversationId)
        .listen((chatMsg) {
      if (!mounted) return;
      final bool isFromMe = chatMsg.senderId == _currentUserId;
      debugPrint('[_msgSub] senderId=${chatMsg.senderId}  _currentUserId=$_currentUserId  isFromMe=$isFromMe  text="${chatMsg.content}"');
      setState(() {
        if (isFromMe) {
          final alreadyConfirmed =
              _messages.any((m) => m.serverMessageId == chatMsg.id);
          if (alreadyConfirmed) return;
          final pendingIdx = _messages.lastIndexWhere(
            (m) =>
                m.status == MessageStatus.pending &&
                m.isSentByMe &&
                m.text == chatMsg.content,
          );
          if (pendingIdx != -1) {
            _messages[pendingIdx] = _messages[pendingIdx].copyWith(
              serverMessageId: chatMsg.id,
              status: MessageStatus.sent,
            );
            return;
          }
        }
        _messages.add(Message(
          serverMessageId: chatMsg.id,
          localId: 'remote_${chatMsg.id}',
          text: chatMsg.content,
          isSentByMe: isFromMe,
          timestamp: chatMsg.createdAt,
          status: MessageStatus.sent,
        ));
      });
      _scrollToBottom();
    });

    _sentSub = ChatService.messageSentStream
        .where((m) => m.conversationId == widget.conversationId)
        .listen((chatMsg) {
      if (!mounted) return;
      setState(() {
        final pendingIdx = _messages.lastIndexWhere(
          (m) =>
              m.status == MessageStatus.pending &&
              m.isSentByMe &&
              m.text == chatMsg.content,
        );
        if (pendingIdx != -1) {
          _messages[pendingIdx] = _messages[pendingIdx].copyWith(
            serverMessageId: chatMsg.id,
            status: MessageStatus.sent,
          );
        }
      });
    });

    _errSub = ChatService.errorStream.listen((errMsg) {
      if (!mounted) return;
      setState(() {
        final pendingIdx = _messages.lastIndexWhere(
          (m) => m.status == MessageStatus.pending && m.isSentByMe,
        );
        if (pendingIdx != -1) {
          _messages[pendingIdx] =
              _messages[pendingIdx].copyWith(status: MessageStatus.failed);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Message failed: $errMsg'),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    });
  }

  Future<void> _loadHistory() async {
    try {
      final msgs = await ChatService.getMessages(widget.conversationId!);
      if (!mounted) return;
      debugPrint('\n==== _loadHistory ====');
      debugPrint('  _currentUserId : $_currentUserId');
      for (final m in msgs) {
        debugPrint('  msg senderId=${m.senderId}  isMine=${m.senderId == _currentUserId}  text="${m.content}"');
      }
      debugPrint('======================\n');
      setState(() {
        _messages.clear();
        _messages.addAll(msgs.map((m) => Message(
              serverMessageId: m.id,
              localId: 'history_${m.id}',
              text: m.content,
              isSentByMe: m.senderId == _currentUserId,
              timestamp: m.createdAt,
              status: MessageStatus.sent,
            )));
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not load messages: $e'),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 5),
      ));
    }
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _sentSub?.cancel();
    _errSub?.cancel();
    _connSub?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    final localId = 'local_${_localIdCounter++}';
    final optimistic = Message(
      localId: localId,
      text: text,
      isSentByMe: true,
      timestamp: DateTime.now(),
      status: _hasBackend ? MessageStatus.pending : MessageStatus.sent,
    );
    setState(() => _messages.add(optimistic));
    _scrollToBottom();

    if (_hasBackend && _isConnected) {
      ChatService.sendMessage(widget.conversationId!, text);
    }
  }

  void _retryMessage(Message msg) {
    if (!_isConnected || !_hasBackend) return;
    setState(() {
      final idx = _messages.indexOf(msg);
      if (idx != -1) {
        _messages[idx] = msg.copyWith(status: MessageStatus.pending);
      }
    });
    ChatService.sendMessage(widget.conversationId!, msg.text);
  }

  void _scrollToBottom() {
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
  Widget build(BuildContext context) {
    final canSend = !_hasBackend || _isConnected;
    return Container(
      color: const Color(0xFF1C2632),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFFFFB5B5),
                          backgroundImage: widget.recipientImage == null ||
                                  widget.recipientImage!.isEmpty
                              ? null
                              : widget.recipientImage!.startsWith('http')
                                  ? NetworkImage(widget.recipientImage!)
                                      as ImageProvider
                                  : AssetImage(widget.recipientImage!)
                                      as ImageProvider,
                          child: (widget.recipientImage == null ||
                                  widget.recipientImage!.isEmpty)
                              ? Text(
                                  widget.recipientName.isNotEmpty
                                      ? widget.recipientName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.recipientName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                // Connection status banner (only in backend mode)
                if (_hasBackend)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    child: _isConnected
                        ? const SizedBox.shrink()
                        : Container(
                            width: double.infinity,
                            color: const Color(0xFFFFF3CD),
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 16),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: Color(0xFF856404),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Connecting to chat…',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF856404))),
                              ],
                            ),
                          ),
                  ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFFFB5B5)))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) =>
                              _buildMessageBubble(_messages[index]),
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        color: const Color(0xFFFFB5B5),
                        onPressed: () {},
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          minLines: 1,
                          maxLines: 5,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: canSend
                            ? const Color(0xFFFFB5B5)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(25),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: canSend ? _sendMessage : null,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            child: Icon(Icons.send,
                                color: canSend
                                    ? Colors.white
                                    : Colors.grey[500]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isPending = message.status == MessageStatus.pending;
    final isFailed = message.status == MessageStatus.failed;

    return Align(
      alignment:
          message.isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: isFailed && message.isSentByMe ? () => _retryMessage(message) : null,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7),
          decoration: BoxDecoration(
            color: isFailed
                ? Colors.red[100]
                : message.isSentByMe
                    ? const Color(0xFFFFB5B5)
                    : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(message.isSentByMe ? 16 : 4),
              bottomRight: Radius.circular(message.isSentByMe ? 4 : 16),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: isFailed ? Colors.red[900] : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isSentByMe
                          ? Colors.black.withValues(alpha: 0.7)
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  if (message.isSentByMe && _hasBackend) ...[
                    const SizedBox(width: 4),
                    if (isPending)
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      )
                    else if (isFailed)
                      const Icon(Icons.error_outline,
                          size: 12, color: Colors.red)
                    else
                      Icon(Icons.done_all,
                          size: 12,
                          color: Colors.black.withValues(alpha: 0.5)),
                  ],
                ],
              ),
              if (isFailed && message.isSentByMe)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('Tap to retry',
                      style: TextStyle(fontSize: 11, color: Colors.red[700])),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
