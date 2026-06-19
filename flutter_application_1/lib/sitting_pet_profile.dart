import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sitting_data.dart';
import 'chat_screen.dart';
import 'services/chat_service.dart';
import 'services/auth_storage.dart';

class SittingPetProfile extends StatelessWidget {
  final SittingPet pet;

  const SittingPetProfile({super.key, required this.pet});

  static const _pink  = Color(0xFFFFC7C8);
  static const _coral = Color(0xFFFF7578);
  static const _grey  = Color(0xFF8D8D8D);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
          ),
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: _buildMessageBar(context),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Back + price row ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 35, height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Icon(Icons.arrow_back,
                                size: 18, color: _grey),
                          ),
                        ),
                        if (pet.pricePerDay != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _pink,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.payments_outlined,
                                    size: 14, color: _coral),
                                const SizedBox(width: 4),
                                Text(
                                  pet.pricePerDay!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _coral,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox(width: 35),
                      ],
                    ),
                  ),
                  // ── Rounded image card ────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 310,
                    decoration: BoxDecoration(
                      color: _pink,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                          color: const Color(0xFFFFE0E0), width: 8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _buildImage(),
                    ),
                  ),

                  // ── Info section ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 22),

                        // Name
                        Text(
                          pet.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        // Location + duration row
                        Row(
                          children: [
                            if (pet.city.isNotEmpty) ...[
                              const Icon(Icons.location_on_outlined,
                                  size: 18, color: _grey),
                              const SizedBox(width: 4),
                              Text(
                                pet.city,
                                style: GoogleFonts.plusJakartaSans(
                                    color: _grey, fontSize: 14),
                              ),
                              const SizedBox(width: 12),
                            ],
                            const Icon(Icons.access_time_rounded,
                                size: 16, color: _grey),
                            const SizedBox(width: 4),
                            Text(
                              pet.duration,
                              style: GoogleFonts.plusJakartaSans(
                                  color: _grey, fontSize: 14),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // ── Stat cards: Age / Gender / Breed ────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statCard(
                              pet.age != null ? '${pet.age} yr' : '—',
                              'Age',
                            ),
                            _statCard(pet.gender, 'Gender'),
                            _statCard(
                              (pet.breed != null && pet.breed!.isNotEmpty)
                                  ? pet.breed!
                                  : '—',
                              'Breed',
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // ── About / Special Notes ────────────────────────
                        Text(
                          'About',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          pet.fullNotes != null && pet.fullNotes!.isNotEmpty
                              ? pet.fullNotes!
                              : 'No additional notes.',
                          style: GoogleFonts.plusJakartaSans(
                            color: _grey,
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ── Owner row ─────────────────────────────────────
                        if (pet.ownerName.isNotEmpty)
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: _pink,
                                child: Text(
                                  pet.ownerName[0].toUpperCase(),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _coral,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                pet.ownerName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBar(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _openChat(context),
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: _coral,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.forum_outlined,
                    color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: GestureDetector(
                onTap: () => _openChat(context),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: _coral,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Message Owner',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  void _openChat(BuildContext context) async {
    if (pet.ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open chat: owner ID not available')),
      );
      return;
    }
    try {
      final conv = await ChatService.initiateConversation(
        targetUserId: pet.ownerId,
        context: 'SITTING',
      );
      final myId = ChatService.currentUserId ?? await AuthStorage.getUserId() ?? '';
      final recipientAvatar = conv.otherParticipantAvatar(myId);
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conv.id,
            recipientName:  pet.ownerName,
            recipientImage: recipientAvatar,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open chat: $e'),
            backgroundColor: Colors.red[700]),
      );
    }
  }

  Widget _buildImage() {
    if (pet.photoBytes != null) {
      return Image.memory(pet.photoBytes!, fit: BoxFit.cover,
          width: double.infinity, height: double.infinity);
    }
    if (pet.imageUrl != null) {
      return Image.network(
        pet.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity, height: double.infinity,
        errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.pets_rounded, color: _coral, size: 80)),
      );
    }
    return const Center(
        child: Icon(Icons.pets_rounded, color: _coral, size: 80));
  }

  Widget _statCard(String value, String label) => Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: _pink,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: const Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF777777),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
}
