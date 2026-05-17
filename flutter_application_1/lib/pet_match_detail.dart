import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/pet_match_models.dart';
import 'chat_screen.dart';
import 'services/chat_service.dart';

class PetMatchDetail extends StatelessWidget {
  final MatchPet match;
  final String?  myPetId;

  const PetMatchDetail({super.key, required this.match, this.myPetId});

  static const _coral = Color(0xFFFF7578);
  static const _pink  = Color(0xFFFFC7C8);

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
                    borderRadius: BorderRadius.circular(18)),
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
                      borderRadius: BorderRadius.circular(18)),
                  alignment: Alignment.center,
                  child: Text('Message Owner',
                      style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      );

  void _openChat(BuildContext context) async {
    try {
      final conv = await ChatService.initiateConversation(
        targetUserId: match.ownerId,
        context: 'MATCHING',
      );
      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conv.id,
            recipientName:  match.ownerName,
            recipientImage: match.imageUrl,
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

  @override
  Widget build(BuildContext context) {
    final m = match;

    return Container(
      color: const Color(0xFF1C2632),
      child: Center(
        child: Container(
          constraints:
              const BoxConstraints(maxWidth: 375, maxHeight: 812),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35)),
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: _buildMessageBar(context),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Back button row ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
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
                              size: 18, color: Color(0xFF8D8D8D)),
                        ),
                      ),
                    ),
                  ),
                  // ── Rounded image card ──────────────────────────────────
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
                      child: m.imageUrl != null
                          ? Image.network(
                              m.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.pets,
                                    size: 80, color: _coral),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.pets,
                                  size: 80, color: _coral),
                            ),
                    ),
                  ),
                  // ── Content ─────────────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 22),

                        Text(m.petName,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),

                        if (m.address != null && m.address!.isNotEmpty)
                          Row(children: [
                            const Icon(Icons.location_on_outlined,
                                size: 18, color: Color(0xFF8D8D8D)),
                            const SizedBox(width: 4),
                            Text(m.address!,
                                style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFF8D8D8D),
                                    fontSize: 14)),
                          ]),

                        const SizedBox(height: 25),

                        // Stat cards: Age / Gender / Breed
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            _statCard('${m.petAge} yr', 'Age'),
                            _statCard(
                                m.petGender == 'MALE' ? 'Male' : 'Female',
                                'Gender'),
                            _statCard(m.petBreed ?? '—', 'Breed'),
                          ],
                        ),

                        const SizedBox(height: 25),

                        if (m.description != null &&
                            m.description!.isNotEmpty) ...[
                          Text('About',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          const SizedBox(height: 10),
                          Text(m.description!,
                              style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF8D8D8D),
                                  fontSize: 14,
                                  height: 1.6)),
                          const SizedBox(height: 35),
                        ] else
                          const SizedBox(height: 35),

                        const SizedBox(height: 10),
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

  Widget _statCard(String value, String label) => Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
            color: _pink, borderRadius: BorderRadius.circular(18)),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: const Color(0xFF333333))),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF777777), fontSize: 12)),
        ]),
      );
}
