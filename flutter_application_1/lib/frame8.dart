import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'banner_rotation.dart';
import 'banner_content.dart';
import 'main.dart' show appRouteObserver;
import 'vetappointmnets.dart';
import 'user_profile.dart';
import 'petmatching.dart';
import 'pet_sitting_selection.dart';
import 'search_screen.dart';
import 'frame6.dart';
import 'services/auth_storage.dart';
import 'services/chat_service.dart';
import 'chat_list_screen.dart';
import 'lost_found_selection.dart';
import 'widgets/floating_chat_bubble.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Frame8 – Home screen  (Figma design: Plus Jakarta Sans, coral #FF7578 palette)
// ─────────────────────────────────────────────────────────────────────────────

class Frame8 extends StatefulWidget {
  const Frame8({super.key});

  @override
  State<Frame8> createState() => _Frame8State();
}

class _Frame8State extends State<Frame8> with RouteAware {
  // Which category chip is active (null = no filter)
  String? _selectedCategory;
  // Which bottom-nav item is active
  int _currentIndex = 0;
  // Currently displayed banner image path
  String _currentBannerImage = '';
  // True while case-8 async sitter-status check is in flight
  bool _bannerLoading = false;

  @override
  void initState() {
    super.initState();
    BannerRotation.advanceBannerIndex();
    _currentBannerImage = BannerRotation.advance(null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        precacheImage(AssetImage(BannerRotation.peek(null)), context);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) appRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  // Called when user navigates back to this screen from a pushed route.
  @override
  void didPopNext() {
    if (!mounted) return;
    BannerRotation.advanceBannerIndex();
    final next = BannerRotation.advance(_selectedCategory);
    precacheImage(AssetImage(BannerRotation.peek(_selectedCategory)), context);
    setState(() => _currentBannerImage = next);
  }

  // ── Colours (straight from Figma) ──────────────────────────────────────────
  static const _pink = Color(0xFFFFC7C8); // banner / card background
  static const _coral = Color(0xFFFF7578); // active chip, button, home dot
  static const _bgPage = Color(0xFFF6F6F6); // page background
  static const _textDark = Color(0xFF333333); // section labels
  static const _textGrey = Color(0xFF777777); // secondary / card labels

  // ── Navigation helper ──────────────────────────────────────────────────────
  void _handleSearchResult(Map<String, dynamic> result) {
    if (!mounted) return;
    if (result['type'] == 'vet') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VetAppointments()),
      );
    } else if (result['type'] == 'category') {
      final newCat = result['name'] as String;
      final next = BannerRotation.advance(newCat);
      precacheImage(AssetImage(BannerRotation.peek(newCat)), context);
      setState(() {
        _selectedCategory = newCat;
        _currentBannerImage = next;
      });
    }
  }

  void _onNavTapped(int index) {
    if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
      return;
    }
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LostFoundSelection(
            typeFilter: _selectedCategory == 'Dogs'
                ? 'DOG'
                : _selectedCategory == 'Cats'
                    ? 'CAT'
                    : null,
          ),
        ),
      );
      return;
    }
    setState(() => _currentIndex = index);
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log out?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17)),
        content: Text('Are you sure you want to log out?',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF6B6B6B))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF9E9E9E))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Log out',
                style: GoogleFonts.plusJakartaSans(
                    color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    ChatService.disconnect();
    await AuthStorage.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Frame6()),
      (_) => false,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C2632), // dark outer frame
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 402, maxHeight: 874),
          decoration: BoxDecoration(
            color: _bgPage,
            borderRadius: BorderRadius.circular(35),
          ),
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildSearchBar(),
                        const SizedBox(height: 25),
                        _buildBanner(),
                        const SizedBox(height: 25),
                        _sectionLabel('categories'),
                        const SizedBox(height: 15),
                        _buildCategoryRow(),
                        const SizedBox(height: 5),
                        _sectionLabel('services'),
                        const SizedBox(height: 15),
                        _buildServicesRow(),
                        const SizedBox(height: 150), // Space for bottom nav
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 20,
                  right: 20,
                  child: _buildBottomNav(),
                ),
                const Positioned.fill(
                  child: FloatingChatBubble(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Row(
        children: [
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfile()),
                ),
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/profile_icon_.png',
                  color: const Color(0xFF8D8D8D),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const Spacer(),
          // Modern Menu Icon (Three dashes)
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF8D8D8D), size: 30),
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) { if (value == 'logout') _logout(); },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 10),
                    Text('Logout', style: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Search bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        ).then((result) {
          if (result != null) _handleSearchResult(result);
        });
      },
      child: AbsorbPointer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search here....',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  // ── Pet-needs banner ──────────────────────────────────────────────────────
  Widget _buildBanner() {
    final banner = BannerContent.items[BannerRotation.bannerIndex];

    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: _pink,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          // Text + button column — right:155 reserves space for the pet image
          // and prevents text from overflowing into the image zone.
          Positioned(
            left: 25,
            right: 155,
            top: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.text,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF5A5A5A),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _bannerLoading
                      ? null
                      : () async {
                          setState(() => _bannerLoading = true);
                          try {
                            await banner.onTap(context, _selectedCategory);
                          } finally {
                            if (mounted) {
                              setState(() => _bannerLoading = false);
                            }
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: _bannerLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _coral,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              banner.buttonLabel,
                              style: const TextStyle(
                                color: _coral,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          // Oval + pet image centred together
          Positioned(
            right: 4,
            bottom: 0,
            width: 160,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Container(
                    width: 155,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFADADD),
                      borderRadius:
                          BorderRadius.all(Radius.elliptical(155, 48)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Image.asset(
                    _currentBannerImage,
                    width: 130,
                    height: 150,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label helper ──────────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Padding(
      padding: EdgeInsets.zero,
      child: Text(
        text,
        style: const TextStyle(
          color: _textDark,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Category chips row ──────────────────────────────────────────────────
  Widget _buildCategoryRow() {
    final cats = [
      {'label': 'Dogs', 'image': 'assets/images/dogo.png'},
      {'label': 'Cats', 'image': 'assets/images/catto.png'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < cats.length; i++) ...[
          if (i > 0) const SizedBox(width: 15),
          _buildCategoryChip(cats[i]['label']!, cats[i]['image']!),
        ],
      ],
    );
  }

  Widget _buildCategoryChip(String label, String imagePath) {
    final bool active = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        final newCat = active ? null : label;
        final next = BannerRotation.advance(newCat);
        precacheImage(AssetImage(BannerRotation.peek(newCat)), context);
        setState(() {
          _selectedCategory = newCat;
          _currentBannerImage = next;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? _coral : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow:
              active
                  ? null
                  : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Small category image
            Container(
              width: 28,
              height: 28,
              padding:
                  label == 'Cats' ? EdgeInsets.zero : const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color:
                    label == 'Dogs'
                        ? Colors.grey.withValues(alpha: 0.1)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : _textGrey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  // ── Services row ──────────────────────────────────────────────────────────
  Widget _buildServicesRow() {
    return SizedBox(
      height: 260,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildServiceCard(
            'pet matching',
            'assets/images/cat.png',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PetMatching(
                  typeFilter: _selectedCategory == 'Dogs'
                      ? 'DOG'
                      : _selectedCategory == 'Cats'
                          ? 'CAT'
                          : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          _buildServiceCard(
            'vet appointments',
            'assets/images/dr.png',
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VetAppointments()),
                ),
          ),
          const SizedBox(width: 14),
          _buildServiceCard(
            'pet sitting',
            'assets/images/dog.png',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PetSittingSelection(
                  typeFilter: _selectedCategory == 'Dogs'
                      ? 'DOG'
                      : _selectedCategory == 'Cats'
                          ? 'CAT'
                          : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    String title,
    String imagePath, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 190,
        height: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(
                  left: 6,
                  top: 6,
                  right: 6,
                  bottom: 15,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _pink,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Image.asset(imagePath, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 10, right: 10),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _textGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom navigation bar ──────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(
            0,
            _buildIconWithCircle(0, Icons.home_rounded, Icons.home_outlined),
          ),
          _navItem(
            1,
            _buildImageIconWithCircle(1, 'assets/images/chat_grey.png'),
          ),
          _navItem(
            2,
            _buildImageIconWithCircle(2, 'assets/images/pet_walking.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildIconWithCircle(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
  ) {
    bool isActive = _currentIndex == index;
    if (isActive) {
      return Container(
        width: 68,
        height: 68,
        decoration: const BoxDecoration(color: _coral, shape: BoxShape.circle),
        child: Icon(activeIcon, color: Colors.white, size: 38),
      );
    }
    return Icon(inactiveIcon, color: Colors.grey[400], size: 42);
  }

  Widget _buildImageIconWithCircle(int index, String imagePath) {
    bool isActive = _currentIndex == index;
    if (isActive) {
      return Container(
        width: 68,
        height: 68,
        decoration: const BoxDecoration(color: _coral, shape: BoxShape.circle),
        child: Center(
          child: Image.asset(
            imagePath,
            width: 38,
            height: 38,
            color: Colors.white,
          ),
        ),
      );
    }
    return Image.asset(
      imagePath,
      width: 42,
      height: 42,
      color: Colors.grey[400],
    );
  }

  Widget _navItem(int index, Widget child) {
    return GestureDetector(
      onTap: () => _onNavTapped(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(width: 70, height: 75, child: Center(child: child)),
    );
  }
}
