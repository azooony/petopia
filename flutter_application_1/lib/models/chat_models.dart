class ChatSender {
  final String id;
  final String fullName;

  const ChatSender({required this.id, required this.fullName});

  factory ChatSender.fromJson(Map<String, dynamic> j) => ChatSender(
        id: j['id'] as String? ?? '',
        fullName: j['fullName'] as String? ?? '',
      );
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final ChatSender? sender;
  final String content;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.sender,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) {
    final senderRaw = j['sender'];
    ChatSender? sender;
    if (senderRaw is Map) {
      sender = ChatSender.fromJson(Map<String, dynamic>.from(senderRaw));
    }
    return ChatMessage(
      id: j['id'] as String? ?? '',
      conversationId: j['conversationId'] as String? ?? '',
      senderId: j['senderId'] as String? ?? '',
      sender: sender,
      content: j['content'] as String? ?? '',
      createdAt: j['createdAt'] != null
          ? DateTime.tryParse(j['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class ConversationParticipant {
  final String userId;
  final String fullName;

  const ConversationParticipant({required this.userId, required this.fullName});

  factory ConversationParticipant.fromJson(Map<String, dynamic> j) {
    final userRaw = j['user'];
    final user = userRaw is Map ? Map<String, dynamic>.from(userRaw) : <String, dynamic>{};
    return ConversationParticipant(
      userId: j['userId'] as String? ?? '',
      fullName: user['fullName'] as String? ?? '',
    );
  }
}

class Conversation {
  final String id;
  final String type;
  final List<ConversationParticipant> participants;
  final ChatMessage? lastMessage;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.type,
    required this.participants,
    this.lastMessage,
    required this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> j) {
    final parts = (j['participants'] as List<dynamic>? ?? [])
        .map((p) => ConversationParticipant.fromJson(
            Map<String, dynamic>.from(p as Map)))
        .toList();

    final msgs = j['messages'] as List<dynamic>? ?? [];
    ChatMessage? lastMsg;
    if (msgs.isNotEmpty) {
      lastMsg =
          ChatMessage.fromJson(Map<String, dynamic>.from(msgs.first as Map));
    }

    return Conversation(
      id: j['id'] as String,
      type: j['type'] as String? ?? 'MATCHING',
      participants: parts,
      lastMessage: lastMsg,
      updatedAt: j['updatedAt'] != null
          ? DateTime.tryParse(j['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String otherParticipantName(String myUserId) {
    for (final p in participants) {
      if (p.userId != myUserId) return p.fullName;
    }
    return participants.isNotEmpty ? participants.first.fullName : 'Unknown';
  }
}
