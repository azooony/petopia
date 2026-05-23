import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lost_found_data.dart';
import 'add_lost_pet_screen.dart';
import 'chat_screen.dart';
import 'services/chat_service.dart';
import 'services/auth_storage.dart';
import 'services/lost_found_service.dart';
import 'petopia_bottom_nav.dart';

class LostPetListScreen extends StatefulWidget {
  final String? typeFilter;
  const LostPetListScreen({super.key, this.typeFilter});

  @override
  State<LostPetListScreen> createState() => _LostPetListScreenState();
}

class _LostPetListScreenState extends State<LostPetListScreen> {
  static const _coral = Color(0xFFFF7578);

  List<LostPet> _pets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });
    try {
      final pets = await LostFoundService.getLostPets();
      if (!mounted) return;
      setState(() {
        _pets = pets;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('ApiException', '').replaceAll(RegExp(r'^\(?\d+\)?:?\s*'), '');
        _isLoading = false;
      });
    }
  }

  List<LostPet> get _filtered {
    if (widget.typeFilter == null) return _pets;
    final f = widget.typeFilter!.toUpperCase();
    return _pets.where((p) => (p.petType ?? '').toUpperCase() == f).toList();
  }

  Future<void> _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddLostPetScreen()),
    );
    if (mounted) _load();
  }

  Future<void> _messageOwner(LostPet pet) async {
    try {
      final conv = await ChatService.initiateConversation(
        targetUserId: pet.ownerId,
        context: 'MATCHING',
      );
      final myId = ChatService.currentUserId ?? await AuthStorage.getUserId() ?? '';
      final recipientAvatar = conv.otherParticipantAvatar(myId);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conv.id,
            recipientName: pet.ownerName,
            recipientImage: recipientAvatar,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not open chat.', style: GoogleFonts.plusJakartaSans()),
        backgroundColor: _coral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
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
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            bottomNavigationBar: const PetopiaBottomNav(activeIndex: 2),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 80,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.typeFilter != null
                    ? '${widget.typeFilter![0].toUpperCase()}${widget.typeFilter!.substring(1).toLowerCase()} lost pets'
                    : 'lost pets',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: _coral,
                      size: 28,
                    ),
                    onPressed: _openAdd,
                  ),
                ),
              ],
            ),
            body: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: _coral, strokeWidth: 2.5));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFFFB5B5)),
            const SizedBox(height: 12),
            Text(_error!,
                style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFB0B0B0), fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _load,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                    color: _coral,
                    borderRadius: BorderRadius.circular(14)),
                child: Text('Try again',
                    style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      );
    }
    final items = _filtered;
    if (items.isEmpty) {
      return _emptyState(widget.typeFilter != null
          ? 'No lost ${widget.typeFilter!.toLowerCase()}s reported yet.'
          : 'No lost pets reported yet.');
    }
    return RefreshIndicator(
      color: _coral,
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildCard(items[i]),
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.search_off_rounded, size: 48, color: Colors.grey[300]),
        const SizedBox(height: 12),
        Text(
          msg,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFB0B0B0),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }

  Widget _buildCard(LostPet pet) {
    return Opacity(
      opacity: pet.isOwn ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: pet.isOwn ? const Color(0xFFF5F5F5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: pet.isOwn
              ? []
              : [
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
            Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 94,
                      height: 94,
                      color: const Color(0xFFFFB5B5),
                      child: _petImage(pet),
                    ),
                  ),
                  if (pet.isOwn)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _coral,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Yours',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.petName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (pet.breed != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        pet.breed!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    _pill(
                      icon: Icons.location_on_outlined,
                      label: 'Last seen: ${pet.lastSeenLocation}',
                    ),
                    const SizedBox(height: 4),
                    _pill(
                      icon: Icons.calendar_today_outlined,
                      label: _formatDate(pet.lastSeenDate),
                    ),
                    if (!pet.isOwn) ...[
                      const SizedBox(height: 4),
                      _pill(
                        icon: Icons.person_outline_rounded,
                        label: pet.ownerName,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (!pet.isOwn)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => _messageOwner(pet),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5E5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: _coral,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _petImage(LostPet pet) {
    if (pet.photoBytes != null) {
      return Image.memory(pet.photoBytes!, fit: BoxFit.cover);
    }
    if (pet.imageUrl != null) {
      return Image.network(
        pet.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.pets_rounded, color: Colors.white, size: 36),
      );
    }
    return const Icon(Icons.pets_rounded, color: Colors.white, size: 36);
  }

  Widget _pill({required IconData icon, required String label, Color? color}) {
    final c = color ?? const Color(0xFF9E9E9E);
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

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}
