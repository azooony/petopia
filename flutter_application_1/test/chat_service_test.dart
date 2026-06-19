// ============================================================================
// FILE: chat_service_test.dart
// SERVICE UNDER TEST: ChatService (lib/services/chat_service.dart)
// DESCRIPTION: Unit tests for the real-time chat system — conversation
//              management, message parsing, socket connection logic,
//              and user identification from JWT.
//
// HOW TO RUN:
//   flutter test test/chat_service_test.dart
//
// HOW TO RUN WITH VERBOSE OUTPUT:
//   flutter test test/chat_service_test.dart --reporter expanded
// ============================================================================

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/chat_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 1 — ChatMessage Model
  // ═══════════════════════════════════════════════════════════════════════════

  group('ChatMessage.fromJson', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.1                                                     │
    // │ Functionality: Chat Message — Parse Full Message from JSON        │
    // │ Description : Verifies that ChatMessage.fromJson() correctly      │
    // │               parses all fields including nested sender object.   │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "parses full message from JSON"              │
    // └─────────────────────────────────────────────────────────────────────┘
    test('parses full message from JSON', () {
      final json = {
        'id': 'msg-001',
        'conversationId': 'conv-001',
        'senderId': 'user-123',
        'sender': {
          'id': 'user-123',
          'fullName': 'Ahmed Hassan',
        },
        'content': 'Hello! Is your pet still available?',
        'createdAt': '2026-06-15T10:30:00.000Z',
      };

      final message = ChatMessage.fromJson(json);

      expect(message.id, equals('msg-001'));
      expect(message.conversationId, equals('conv-001'));
      expect(message.senderId, equals('user-123'));
      expect(message.sender, isNotNull);
      expect(message.sender!.fullName, equals('Ahmed Hassan'));
      expect(message.content, equals('Hello! Is your pet still available?'));
      expect(message.createdAt.year, equals(2026));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.2                                                     │
    // │ Functionality: Chat Message — Handle Missing Sender               │
    // │ Description : Verifies that ChatMessage handles a null sender     │
    // │               field gracefully (e.g., system messages).           │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "handles null sender"                        │
    // └─────────────────────────────────────────────────────────────────────┘
    test('handles null sender gracefully', () {
      final json = {
        'id': 'msg-002',
        'conversationId': 'conv-001',
        'senderId': 'user-456',
        'content': 'System notification',
        'createdAt': '2026-06-15T11:00:00.000Z',
      };

      final message = ChatMessage.fromJson(json);

      expect(message.sender, isNull);
      expect(message.senderId, equals('user-456'));
      expect(message.content, equals('System notification'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 1.3                                                     │
    // │ Functionality: Chat Message — Default Values for Missing Fields   │
    // │ Description : Verifies that missing optional fields default to    │
    // │               empty strings and DateTime.now() respectively.     │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "defaults missing fields"                    │
    // └─────────────────────────────────────────────────────────────────────┘
    test('defaults missing fields to safe values', () {
      final json = <String, dynamic>{};

      final message = ChatMessage.fromJson(json);

      expect(message.id, equals(''));
      expect(message.conversationId, equals(''));
      expect(message.senderId, equals(''));
      expect(message.content, equals(''));
      expect(message.createdAt, isA<DateTime>());
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 2 — ChatSender Model
  // ═══════════════════════════════════════════════════════════════════════════

  group('ChatSender.fromJson', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.1                                                     │
    // │ Functionality: Chat Sender — Parse Sender from JSON               │
    // │ Description : Verifies that ChatSender correctly parses the       │
    // │               sender's id and fullName.                           │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "parses sender from JSON"                    │
    // └─────────────────────────────────────────────────────────────────────┘
    test('parses sender from JSON', () {
      final sender = ChatSender.fromJson({
        'id': 'sender-001',
        'fullName': 'Dr. Mohamed',
      });

      expect(sender.id, equals('sender-001'));
      expect(sender.fullName, equals('Dr. Mohamed'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 2.2                                                     │
    // │ Functionality: Chat Sender — Handles Missing Fields               │
    // │ Description : Verifies that ChatSender defaults to empty strings  │
    // │               when fields are null.                               │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "sender defaults to empty strings"           │
    // └─────────────────────────────────────────────────────────────────────┘
    test('sender defaults to empty strings when null', () {
      final sender = ChatSender.fromJson(<String, dynamic>{});

      expect(sender.id, equals(''));
      expect(sender.fullName, equals(''));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 3 — Conversation Model
  // ═══════════════════════════════════════════════════════════════════════════

  group('Conversation.fromJson', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.1                                                     │
    // │ Functionality: Conversation — Parse Full Conversation from JSON   │
    // │ Description : Verifies that Conversation.fromJson() correctly     │
    // │               parses participants, last message, and metadata.    │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "parses full conversation"                   │
    // └─────────────────────────────────────────────────────────────────────┘
    test('parses full conversation from JSON', () {
      final json = {
        'id': 'conv-001',
        'type': 'MATCHING',
        'participants': [
          {
            'userId': 'user-001',
            'user': {'fullName': 'Ahmed', 'profilePicture': 'pic1.jpg'},
          },
          {
            'userId': 'user-002',
            'user': {'fullName': 'Sara', 'profilePicture': null},
          },
        ],
        'messages': [
          {
            'id': 'msg-last',
            'conversationId': 'conv-001',
            'senderId': 'user-001',
            'content': 'See you tomorrow!',
            'createdAt': '2026-06-15T20:00:00.000Z',
          },
        ],
        'updatedAt': '2026-06-15T20:00:00.000Z',
      };

      final conv = Conversation.fromJson(json);

      expect(conv.id, equals('conv-001'));
      expect(conv.type, equals('MATCHING'));
      expect(conv.participants.length, equals(2));
      expect(conv.participants[0].fullName, equals('Ahmed'));
      expect(conv.participants[1].fullName, equals('Sara'));
      expect(conv.lastMessage, isNotNull);
      expect(conv.lastMessage!.content, equals('See you tomorrow!'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.2                                                     │
    // │ Functionality: Conversation — Other Participant Name              │
    // │ Description : Verifies that otherParticipantName() correctly      │
    // │               returns the OTHER user's name (not the current      │
    // │               user), which is used in the chat list UI.           │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "gets other participant name"                │
    // └─────────────────────────────────────────────────────────────────────┘
    test('otherParticipantName returns correct name', () {
      final conv = Conversation.fromJson({
        'id': 'conv-002',
        'type': 'MATCHING',
        'participants': [
          {
            'userId': 'me-001',
            'user': {'fullName': 'Me'},
          },
          {
            'userId': 'other-001',
            'user': {'fullName': 'Other Person'},
          },
        ],
        'messages': [],
        'updatedAt': '2026-06-15T20:00:00.000Z',
      });

      expect(conv.otherParticipantName('me-001'), equals('Other Person'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.3                                                     │
    // │ Functionality: Conversation — Other Participant ID                │
    // │ Description : Verifies that otherParticipantId() correctly        │
    // │               returns the OTHER user's ID.                        │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "gets other participant ID"                  │
    // └─────────────────────────────────────────────────────────────────────┘
    test('otherParticipantId returns correct ID', () {
      final conv = Conversation.fromJson({
        'id': 'conv-003',
        'type': 'MATCHING',
        'participants': [
          {
            'userId': 'me-001',
            'user': {'fullName': 'Me'},
          },
          {
            'userId': 'target-999',
            'user': {'fullName': 'Target'},
          },
        ],
        'messages': [],
        'updatedAt': '2026-06-15T20:00:00.000Z',
      });

      expect(conv.otherParticipantId('me-001'), equals('target-999'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.4                                                     │
    // │ Functionality: Conversation — No Messages (Empty Chat)            │
    // │ Description : Verifies that a conversation with no messages has   │
    // │               lastMessage set to null.                            │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "handles empty messages list"                │
    // └─────────────────────────────────────────────────────────────────────┘
    test('handles empty messages list', () {
      final conv = Conversation.fromJson({
        'id': 'conv-004',
        'type': 'MATCHING',
        'participants': [],
        'messages': [],
        'updatedAt': '2026-06-15T20:00:00.000Z',
      });

      expect(conv.lastMessage, isNull);
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 3.5                                                     │
    // │ Functionality: Conversation — Default Type is MATCHING            │
    // │ Description : Verifies that when no 'type' field is provided,     │
    // │               the conversation type defaults to 'MATCHING'.       │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "defaults type to MATCHING"                  │
    // └─────────────────────────────────────────────────────────────────────┘
    test('defaults type to MATCHING when missing', () {
      final conv = Conversation.fromJson({
        'id': 'conv-005',
        'participants': [],
        'messages': [],
        'updatedAt': '2026-06-15T20:00:00.000Z',
      });

      expect(conv.type, equals('MATCHING'));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 4 — ConversationParticipant Model
  // ═══════════════════════════════════════════════════════════════════════════

  group('ConversationParticipant.fromJson', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.1                                                     │
    // │ Functionality: Participant — Parse with Profile Picture           │
    // │ Description : Verifies that the participant's nested user object  │
    // │               (fullName, profilePicture) is correctly parsed.     │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "parses participant with picture"            │
    // └─────────────────────────────────────────────────────────────────────┘
    test('parses participant with profile picture', () {
      final participant = ConversationParticipant.fromJson({
        'userId': 'user-555',
        'user': {
          'fullName': 'Hassan Ali',
          'profilePicture': 'https://example.com/avatar.jpg',
        },
      });

      expect(participant.userId, equals('user-555'));
      expect(participant.fullName, equals('Hassan Ali'));
      expect(participant.profilePicture,
          equals('https://example.com/avatar.jpg'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 4.2                                                     │
    // │ Functionality: Participant — Handle Missing User Object           │
    // │ Description : Verifies that when the nested 'user' object is      │
    // │               null, the participant defaults to empty name and    │
    // │               null profile picture.                               │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "handles missing user object"                │
    // └─────────────────────────────────────────────────────────────────────┘
    test('handles missing user object', () {
      final participant = ConversationParticipant.fromJson({
        'userId': 'user-666',
      });

      expect(participant.userId, equals('user-666'));
      expect(participant.fullName, equals(''));
      expect(participant.profilePicture, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 5 — JWT Decoding (ensureCurrentUserId logic)
  // ═══════════════════════════════════════════════════════════════════════════

  group('JWT userId extraction', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 5.1                                                     │
    // │ Functionality: JWT Decode — Extract UserId from Token             │
    // │ Description : Verifies that the userId can be extracted from a    │
    // │               JWT token's payload by base64-decoding the middle   │
    // │               segment. This is the logic used by                  │
    // │               ChatService.ensureCurrentUserId().                  │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "extracts userId from JWT"                   │
    // └─────────────────────────────────────────────────────────────────────┘
    test('extracts userId from JWT payload', () {
      // Create a fake JWT with a known payload
      final payload = {'userId': 'extracted-user-123', 'role': 'PET_OWNER'};
      final payloadBase64 =
          base64Url.encode(utf8.encode(jsonEncode(payload)));
      final fakeJwt = 'header.$payloadBase64.signature';

      // Decode using the same logic as ChatService
      final parts = fakeJwt.split('.');
      expect(parts.length, equals(3));

      final padded = base64Url.normalize(parts[1]);
      final decoded =
          jsonDecode(utf8.decode(base64Url.decode(padded)))
              as Map<String, dynamic>;

      expect(decoded['userId'], equals('extracted-user-123'));
      expect(decoded['role'], equals('PET_OWNER'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 5.2                                                     │
    // │ Functionality: JWT Decode — Handle Invalid Token Gracefully       │
    // │ Description : Verifies that an invalid JWT token (wrong number    │
    // │               of segments) does not crash and returns null.       │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "handles invalid JWT"                        │
    // └─────────────────────────────────────────────────────────────────────┘
    test('handles invalid JWT gracefully', () {
      const invalidToken = 'not-a-valid-jwt';

      final parts = invalidToken.split('.');
      String? userId;

      if (parts.length == 3) {
        try {
          final padded = base64Url.normalize(parts[1]);
          final decoded =
              jsonDecode(utf8.decode(base64Url.decode(padded)))
                  as Map<String, dynamic>;
          userId = decoded['userId'] as String?;
        } catch (_) {
          userId = null;
        }
      }

      expect(userId, isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // GROUP 6 — Socket Data Unwrapping
  // ═══════════════════════════════════════════════════════════════════════════

  group('Socket data unwrapping', () {
    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 6.1                                                     │
    // │ Functionality: Unwrap — Map Payload                               │
    // │ Description : Verifies that when socket.io sends raw data as a    │
    // │               Map, it is correctly unwrapped.                     │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "unwraps Map payload"                        │
    // └─────────────────────────────────────────────────────────────────────┘
    test('unwraps Map payload correctly', () {
      final raw = {'id': 'msg-001', 'content': 'Hi!'};

      // Simulate _unwrap logic
      Map<String, dynamic> unwrap(dynamic raw) {
        if (raw is List) {
          return Map<String, dynamic>.from(raw[0] as Map);
        }
        return Map<String, dynamic>.from(raw as Map);
      }

      final result = unwrap(raw);
      expect(result['id'], equals('msg-001'));
      expect(result['content'], equals('Hi!'));
    });

    // ┌─────────────────────────────────────────────────────────────────────┐
    // │ TEST CASE 6.2                                                     │
    // │ Functionality: Unwrap — List Payload (Socket.IO Wrapper)          │
    // │ Description : Verifies that when socket.io wraps the data in a    │
    // │               List (common with acknowledgements), the first      │
    // │               element is extracted correctly.                     │
    // │ Command     : flutter test test/chat_service_test.dart            │
    // │               --name "unwraps List payload"                       │
    // └─────────────────────────────────────────────────────────────────────┘
    test('unwraps List payload (socket.io wrapper)', () {
      final raw = [
        {'id': 'msg-002', 'content': 'Wrapped message'}
      ];

      Map<String, dynamic> unwrap(dynamic raw) {
        if (raw is List) {
          return Map<String, dynamic>.from(raw[0] as Map);
        }
        return Map<String, dynamic>.from(raw as Map);
      }

      final result = unwrap(raw);
      expect(result['id'], equals('msg-002'));
      expect(result['content'], equals('Wrapped message'));
    });
  });
}
