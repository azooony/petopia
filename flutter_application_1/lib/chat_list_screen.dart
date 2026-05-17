import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/chat_models.dart';
import 'services/chat_service.dart';
import 'services/auth_storage.dart';
import 'services/api_client.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  static const _coral    = Color(0xFFFF7578);
  static const _pink     = Color(0xFFFFC7C8);
  static const _darkText = Color(0xFF333333);
  static const _greyText = Color(0xFF9E9E9E);
  static const _bgGrey   = Color(0xFFF6F6F6);

  List<Conversation> _conversations = [];
  bool   _isLoading = true;
  String? _error;
  String? _myUserId;

  StreamSubscription? _msgSub;

  @override
  void initState() {
    super.initState();
    _load();
    ChatService.connect();
    _msgSub = ChatService.messageStream.listen((_) => _load());
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      _myUserId ??= await AuthStorage.getUserId();
      final convs = await ChatService.getConversations();
      if (mounted) setState(() { _conversations = convs; _isLoading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Failed to load chats.'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C2632),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
          decoration: BoxDecoration(
            color: _bgGrey,
            borderRadius: BorderRadius.circular(30),
          ),
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: _darkText, size: 20),
                  ),
                  const SizedBox(width: 4),
                  Text('messages',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _darkText)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _isLoading ? null : _load,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: _isLoading ? _bgGrey : _pink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: _coral),
                              ),
                            )
                          : const Icon(Icons.refresh_rounded,
                              color: _coral, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(height: 3, color: _coral),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _conversations.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: _coral, strokeWidth: 2.5));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                    color: _pink, borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.wifi_off_rounded, color: _coral, size: 40),
              ),
              const SizedBox(height: 20),
              Text('Connection error',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18, fontWeight: FontWeight.w700, color: _darkText)),
              const SizedBox(height: 8),
              Text(_error!,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _greyText),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _load,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                      color: _coral, borderRadius: BorderRadius.circular(16)),
                  child: Text('Try again',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_conversations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                    color: _pink, borderRadius: BorderRadius.circular(30)),
                child: const Icon(Icons.forum_outlined, color: _coral, size: 52),
              ),
              const SizedBox(height: 24),
              Text('No chats yet',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 20, fontWeight: FontWeight.w800, color: _darkText)),
              const SizedBox(height: 10),
              Text('Tap "Message Owner" on any pet\nprofile to start chatting.',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, color: _greyText, height: 1.55),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: _coral,
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _conversations.length,
        itemBuilder: (_, i) => _buildTile(_conversations[i]),
      ),
    );
  }

  Widget _buildTile(Conversation conv) {
    final myId    = _myUserId ?? '';
    final name    = conv.otherParticipantName(myId);
    final lastMsg = conv.lastMessage;
    final snippet = lastMsg?.content ?? '';
    final timeStr = lastMsg != null ? _formatTime(lastMsg.createdAt) : '';
    final isSitting = conv.type == 'SITTING';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conv.id,
            recipientName: name,
          ),
        ),
      ).then((_) => _load()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54, height: 54,
              decoration: BoxDecoration(
                  color: _pink, borderRadius: BorderRadius.circular(18)),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 22, fontWeight: FontWeight.w800, color: _coral),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _darkText),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (timeStr.isNotEmpty)
                        Text(timeStr,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11, color: _greyText)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          snippet.isEmpty ? 'No messages yet' : snippet,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: snippet.isEmpty
                                ? const Color(0xFFCCCCCC)
                                : _greyText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSitting
                              ? const Color(0xFFEAF2FF)
                              : const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isSitting ? 'Sitting' : 'Match',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSitting
                                ? const Color(0xFF5B9EF7)
                                : _coral,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFDDDDDD), size: 22),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inDays == 0) {
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[t.weekday - 1];
    }
    return '${t.day}/${t.month}';
  }
}
