import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/chat_models.dart';
import 'services/chat_service.dart';
import 'services/auth_storage.dart';
import 'services/api_client.dart';
import 'chat_screen.dart';
import 'petopia_bottom_nav.dart';

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
  bool    _isLoading = true;
  String? _error;
  String? _myUserId;

  final _searchController = TextEditingController();
  final _searchFocus      = FocusNode();
  String _searchQuery     = '';

  StreamSubscription? _msgSub;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() => setState(() {}));
    _load();
    ChatService.connect();
    _msgSub = ChatService.messageStream.listen((_) => _load());
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
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

  List<Conversation> get _filtered {
    if (_searchQuery.isEmpty) return _conversations;
    final q = _searchQuery.toLowerCase();
    return _conversations.where((conv) {
      final name = conv.otherParticipantName(_myUserId ?? '').toLowerCase();
      final type = _typeLabel(conv.type).toLowerCase();
      return name.contains(q) || type.contains(q);
    }).toList();
  }

  String _typeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'MATCHING': return 'Match';
      case 'SITTING':  return 'Sitting';
      case 'LOST_PET': return 'Lost Pet';
      case 'FOUND_PET': return 'Found Pet';
      default: return 'Chat';
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
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              bottomNavigationBar: const PetopiaBottomNav(activeIndex: 1),
              body: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final focused  = _searchFocus.hasFocus;
    final hasText  = _searchController.text.isNotEmpty;
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: _darkText, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text('messages',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _darkText)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // ── Search bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 44,
                decoration: BoxDecoration(
                  color: focused ? const Color(0xFFFFF5F5) : const Color(0xFFF6F6F6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: focused ? _coral : Colors.transparent,
                    width: focused ? 1.5 : 1.0,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: _darkText,
                      fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'Search by name or type...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: const Color(0xFFB0B0B0)),
                    prefixIcon: Icon(Icons.search_rounded,
                        size: 18,
                        color: focused ? _coral : const Color(0xFFB0B0B0)),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 40, minHeight: 0),
                    suffixIcon: hasText
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(Icons.close_rounded,
                                size: 16, color: Color(0xFFB0B0B0)),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
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
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: _pink,
                    borderRadius: BorderRadius.circular(24)),
                child: const Icon(Icons.wifi_off_rounded,
                    color: _coral, size: 40),
              ),
              const SizedBox(height: 20),
              Text('Connection error',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _darkText)),
              const SizedBox(height: 8),
              Text(_error!,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13, color: _greyText),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _load,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                      color: _coral,
                      borderRadius: BorderRadius.circular(16)),
                  child: Text('Try again',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    color: _pink,
                    borderRadius: BorderRadius.circular(30)),
                child: const Icon(Icons.forum_outlined,
                    color: _coral, size: 52),
              ),
              const SizedBox(height: 24),
              Text(
                _searchQuery.isEmpty ? 'No chats yet' : 'No results found',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _darkText),
              ),
              const SizedBox(height: 10),
              Text(
                _searchQuery.isEmpty
                    ? 'Tap "Message" on any pet profile\nto start chatting.'
                    : 'Try a different name or type.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: _greyText, height: 1.55),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _coral,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildTile(items[i]),
      ),
    );
  }

  Widget _buildTile(Conversation conv) {
    final myId    = _myUserId ?? '';
    final name    = conv.otherParticipantName(myId);
    final avatar  = conv.otherParticipantAvatar(myId);
    final snippet = conv.lastMessage?.content ?? '';
    final timeStr = conv.lastMessage != null
        ? _formatTime(conv.lastMessage!.createdAt)
        : '';
    final label   = _typeLabel(conv.type);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conv.id,
            recipientName: name,
            recipientImage: avatar,
            recipientId: conv.otherParticipantId(_myUserId ?? ''),
          ),
        ),
      ).then((_) => _load()),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(50),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Avatar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 94,
                  height: 94,
                  color: const Color(0xFFFFB5B5),
                  child: avatar != null && avatar.isNotEmpty
                      ? Image.network(
                          avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            // ── Info ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (timeStr.isNotEmpty)
                          Text(
                            timeStr,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11, color: _greyText),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _pill(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: snippet.isEmpty ? 'No messages yet' : snippet,
                    ),
                    const SizedBox(height: 4),
                    _pill(
                      icon: Icons.label_outline_rounded,
                      label: label,
                      color: _coral,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right_rounded,
                  color: Color(0xFFDDDDDD), size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill({required IconData icon, required String label, Color? color}) {
    final c = color ?? _greyText;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: c),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: c,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime t) {
    final now  = DateTime.now();
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
