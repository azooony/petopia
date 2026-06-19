import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ai_chat_service.dart';

class FloatingChatBubble extends StatefulWidget {
  const FloatingChatBubble({super.key});

  @override
  State<FloatingChatBubble> createState() => _FloatingChatBubbleState();
}

class _FloatingChatBubbleState extends State<FloatingChatBubble>
    with SingleTickerProviderStateMixin {
  static const _coral = Color(0xFFFF7578);
  static const _coralLight = Color(0xFFFFF0F0);
  static const _bgPage = Color(0xFFF6F6F6);

  // Bubble position
  double _x = 0;
  double _y = 0;
  bool _positioned = false;

  // Chat state
  bool _isOpen = false;
  final List<AiChatMessage> _history = [];
  final List<_DisplayMessage> _messages = [];
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isLoading = false;

  late final AnimationController _animCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _initPosition(BoxConstraints constraints) {
    if (_positioned) return;
    _x = constraints.maxWidth - 78;
    _y = constraints.maxHeight - 170;
    _positioned = true;
  }

  void _toggleChat() {
    setState(() => _isOpen = !_isOpen);
    if (_isOpen) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;

    _inputCtrl.clear();
    setState(() {
      _messages.add(_DisplayMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final reply = await AiChatService.sendMessage(text, _history);
      _history.add(AiChatMessage(role: 'user', text: text));
      _history.add(AiChatMessage(role: 'model', text: reply));
      if (mounted) {
        setState(() {
          _messages.add(_DisplayMessage(text: reply, isUser: false));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_DisplayMessage(
            text: 'Sorry, something went wrong. Please try again.',
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _initPosition(constraints);
        return Stack(
          children: [
            // Chat window
            if (_isOpen)
              Positioned(
                right: 12,
                bottom: 90,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  alignment: Alignment.bottomRight,
                  child: _buildChatWindow(),
                ),
              ),

            // Draggable bubble
            Positioned(
              left: _x,
              top: _y,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _x += details.delta.dx;
                    _y += details.delta.dy;
                    // Clamp within screen bounds
                    _x = _x.clamp(0, constraints.maxWidth - 60);
                    _y = _y.clamp(0, constraints.maxHeight - 60);
                  });
                },
                onTap: _toggleChat,
                child: _buildBubble(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBubble() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: _coral,
<<<<<<< Updated upstream
        borderRadius: BorderRadius.circular(16),
=======
        borderRadius: BorderRadius.circular(18),
>>>>>>> Stashed changes
        boxShadow: [
          BoxShadow(
            color: _coral.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.pets, color: Colors.white, size: 28),
    );
  }

  Widget _buildChatWindow() {
    return Container(
      width: 310,
      height: 440,
      decoration: BoxDecoration(
        color: _bgPage,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: _coral,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.pets, color: _coral, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Petopia Assistant',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Ask me anything about pets!',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _toggleChat,
            child: const Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chat_bubble_outline, color: _coral, size: 40),
              const SizedBox(height: 12),
              Text(
                'Hi! I\'m your Petopia assistant.\nAsk me about pet care or how to use the app!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey[500],
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) return _buildTypingIndicator();
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(_DisplayMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        constraints: const BoxConstraints(maxWidth: 230),
        decoration: BoxDecoration(
          color: msg.isUser ? _coral : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: msg.isUser
            ? Text(
                msg.text,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.45,
                ),
              )
            : MarkdownBody(
                data: msg.text,
                styleSheet: MarkdownStyleSheet(
                  p: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF333333),
                    fontSize: 13,
                    height: 1.45,
                  ),
                  strong: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF333333),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  em: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF333333),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                  listBullet: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF333333),
                    fontSize: 13,
                  ),
                  blockquote: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF666666),
                    fontSize: 12,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => _Dot(delay: i * 200)),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _coralLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _inputCtrl,
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Ask about your pet...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                      color: Colors.grey[400], fontSize: 13),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: _coral,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisplayMessage {
  final String text;
  final bool isUser;
  const _DisplayMessage({required this.text, required this.isUser});
}

// Animated typing dot
class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            color: Color(0xFFFF7578),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
