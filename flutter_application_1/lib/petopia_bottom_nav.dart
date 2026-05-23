import 'package:flutter/material.dart';
import 'chat_list_screen.dart';
import 'lost_found_selection.dart';
import 'frame8.dart';

class PetopiaBottomNav extends StatelessWidget {
  final int activeIndex;
  const PetopiaBottomNav({super.key, required this.activeIndex});

  static const _coral = Color(0xFFFF7578);

  void _onTap(BuildContext context, int index) {
    if (index == activeIndex) return;
    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Frame8()),
        (route) => false,
      );
      return;
    }
    if (index == 1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ChatListScreen()));
      return;
    }
    if (index == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LostFoundSelection()));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
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
            _navItem(context, 0),
            _navItem(context, 1),
            _navItem(context, 2),
          ],
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _onTap(context, index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        height: 75,
        child: Center(child: _buildIcon(index)),
      ),
    );
  }

  Widget _buildIcon(int index) {
    final isActive = activeIndex == index;

    if (index == 0) {
      if (isActive) {
        return Container(
          width: 68,
          height: 68,
          decoration: const BoxDecoration(color: _coral, shape: BoxShape.circle),
          child: const Icon(Icons.home_rounded, color: Colors.white, size: 38),
        );
      }
      return Icon(Icons.home_outlined, color: Colors.grey[400], size: 42);
    }

    final imagePath = index == 1
        ? 'assets/images/chat_grey.png'
        : 'assets/images/pet_walking.png';

    if (isActive) {
      return Container(
        width: 68,
        height: 68,
        decoration: const BoxDecoration(color: _coral, shape: BoxShape.circle),
        child: Center(
          child: Image.asset(imagePath,
              width: 38, height: 38, color: Colors.white),
        ),
      );
    }
    return Image.asset(imagePath,
        width: 42, height: 42, color: Colors.grey[400]);
  }
}
