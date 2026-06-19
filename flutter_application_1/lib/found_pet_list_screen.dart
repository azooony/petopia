import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'lost_found_data.dart';
import 'add_found_pet_screen.dart';
import 'chat_screen.dart';
import 'services/chat_service.dart';
import 'services/auth_storage.dart';
import 'services/lost_found_service.dart';
import 'petopia_bottom_nav.dart';

class FoundPetListScreen extends StatefulWidget {
  final String? typeFilter;
  const FoundPetListScreen({super.key, this.typeFilter});

  @override
  State<FoundPetListScreen> createState() => _FoundPetListScreenState();
}

class _FoundPetListScreenState extends State<FoundPetListScreen> {
  static const _coral = Color(0xFFFF7578);

  List<FoundPet> _pets = [];
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
      final pets = await LostFoundService.getFoundPets();
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

  List<FoundPet> get _filtered {
    if (widget.typeFilter == null) return _pets;
    final f = widget.typeFilter!.toUpperCase();
    return _pets.where((p) => (p.petType ?? '').toUpperCase() == f).toList();
  }

  Future<void> _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddFoundPetScreen()),
    );
    if (mounted) _load();
  }

  Future<void> _deleteReport(FoundPet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete report?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently remove your found pet report.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF9E9E9E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: Colors.black54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: GoogleFonts.plusJakartaSans(color: _coral, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await LostFoundService.deleteFoundPet(pet.id);
      if (mounted) _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not delete report.', style: GoogleFonts.plusJakartaSans()),
        backgroundColor: _coral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  Future<void> _messageReporter(FoundPet pet) async {
    try {
      final conv = await ChatService.initiateConversation(
        targetUserId: pet.reporterId,
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
            recipientName: pet.reporterName,
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
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints.expand(),
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
                    ? '${widget.typeFilter![0].toUpperCase()}${widget.typeFilter!.substring(1).toLowerCase()} found pets'
                    : 'found pets',
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
                    color: _coral, borderRadius: BorderRadius.circular(14)),
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
          ? 'No found ${widget.typeFilter!.toLowerCase()}s reported yet.'
          : 'No found pets reported yet.');
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

  Widget _buildCard(FoundPet pet) {
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
                      pet.description.length > 55
                          ? '${pet.description.substring(0, 55)}...'
                          : pet.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (pet.petType != null)
                      _pill(
                        icon: pet.petType == 'CAT'
                            ? Icons.catching_pokemon_rounded
                            : Icons.pets_rounded,
                        label: pet.petType == 'CAT' ? 'Cat' : 'Dog',
                        color: const Color(0xFFFF7578),
                      ),
                    if (pet.petType != null) const SizedBox(height: 4),
                    if (pet.breed != null) ...[
                      _pill(
                        icon: Icons.auto_awesome_outlined,
                        label: pet.breed!,
                        color: const Color(0xFF9B59B6),
                      ),
                      const SizedBox(height: 4),
                    ],
                    _pill(
                      icon: Icons.location_on_outlined,
                      label: pet.foundLocation,
                    ),
                    const SizedBox(height: 4),
                    _pill(
                      icon: pet.isPetKept
                          ? Icons.home_outlined
                          : Icons.store_outlined,
                      label: pet.isPetKept ? 'With finder' : 'No',
                      color: pet.isPetKept
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFF5B9EF7),
                    ),
                    if (!pet.isOwn) ...[
                      const SizedBox(height: 4),
                      _pill(
                        icon: Icons.person_outline_rounded,
                        label: pet.reporterName,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: pet.isOwn
                    ? () => _deleteReport(pet)
                    : () => _messageReporter(pet),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: pet.isOwn
                        ? const Color(0xFFFFE5E5)
                        : const Color(0xFFFFE5E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    pet.isOwn
                        ? Icons.delete_outline_rounded
                        : Icons.chat_bubble_outline_rounded,
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

  Widget _petImage(FoundPet pet) {
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
}
