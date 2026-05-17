import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/pet_match_models.dart';
import 'services/pet_matching_service.dart';
import 'pet_match_detail.dart';

class PetMatchDiscover extends StatefulWidget {
  final String? typeFilter;
  const PetMatchDiscover({super.key, this.typeFilter});

  @override
  State<PetMatchDiscover> createState() => _PetMatchDiscoverState();
}

class _PetMatchDiscoverState extends State<PetMatchDiscover> {
  static const _coral = Color(0xFFFF7578);

  bool    _isLoading = true;
  String? _error;
  String? _myPetId;
  List<MatchPet> _matches = [];

  String? _genderFilter;
  final _cityController = TextEditingController();
  final _cityFocus      = FocusNode();
  String _citySearch    = '';

  @override
  void initState() {
    super.initState();
    _cityFocus.addListener(() => setState(() {}));
    _load();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _cityFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      // Try to get the user's own pet ID so we can exclude it from results.
      // If they have no pet yet, we still show all available pets.
      try {
        final data = await PetMatchingService.getMyPetForMatching();
        _myPetId = data.pet.id;
      } on PetMatchingException {
        _myPetId = null;
      }

      final matches = await PetMatchingService.getAllAvailableMatches(petType: widget.typeFilter);

      if (mounted) {
        setState(() {
          _matches   = matches;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() { _error = 'Failed to load matches.'; _isLoading = false; });
      }
    }
  }

  List<MatchPet> get _filtered => _matches.where((p) {
        if (_genderFilter != null) {
          final expected = _genderFilter == 'Male' ? 'MALE' : 'FEMALE';
          if (p.petGender != expected) return false;
        }
        if (_citySearch.isNotEmpty) {
          final addr = (p.address ?? '').toLowerCase();
          if (!addr.contains(_citySearch.toLowerCase())) return false;
        }
        return true;
      }).toList();

  @override
  Widget build(BuildContext context) {
    final pets = _filtered;

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
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('find a match',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: Color(0xFF9E9E9E)),
                  onPressed: _load,
                ),
              ],
            ),
            body: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: _coral))
                : _error != null
                    ? _buildErrorState()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 4, 16, 10),
                            child: Row(
                              children: [
                                _GenderDropdown(
                                  value: _genderFilter,
                                  onChanged: (v) =>
                                      setState(() => _genderFilter = v),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _CitySearchField(
                                    controller: _cityController,
                                    focusNode: _cityFocus,
                                    onChanged: (v) =>
                                        setState(() => _citySearch = v),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          Expanded(
                            child: pets.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.pets_rounded,
                                            size: 48,
                                            color: Colors.grey[300]),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No matches found in your area',
                                          style: GoogleFonts.plusJakartaSans(
                                              color:
                                                  const Color(0xFFB0B0B0),
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: pets.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (_, i) =>
                                        _buildCard(pets[i]),
                                  ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pets_rounded,
                size: 48, color: Color(0xFFDDDDDD)),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(MatchPet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete pet?',
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text(
          '${pet.petName} will be permanently deleted. You\'ll need to add your pet again if you want to find a match.',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: const Color(0xFF9E9E9E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF9E9E9E))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.plusJakartaSans(
                    color: _coral, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await PetMatchingService.deletePet(pet.petId);
      if (!mounted) return;
      Navigator.pop(context); // back to PetMatching selection screen
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete pet.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Widget _buildCard(MatchPet pet) {
    final isOwn = _myPetId != null && pet.petId == _myPetId;
    return Opacity(
      opacity: isOwn ? 0.55 : 1.0,
      child: GestureDetector(
      onTap: isOwn ? null : () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PetMatchDetail(match: pet, myPetId: _myPetId),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isOwn ? const Color(0xFFF5F5F5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isOwn ? [] : [
            BoxShadow(
                color: Colors.grey.withAlpha(50),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            // Photo block with optional "Yours" badge
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
                      child: pet.imageUrl != null
                          ? Image.network(
                              pet.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.pets_rounded,
                                  color: Colors.white,
                                  size: 36),
                            )
                          : const Icon(Icons.pets_rounded,
                              color: Colors.white, size: 36),
                    ),
                  ),
                  if (isOwn)
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
                        child: Text('Yours',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                ],
              ),
            ),

            // Details
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
                          child: Text(pet.petName,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                        ),
                        if (isOwn)
                          GestureDetector(
                            onTap: () => _confirmDelete(pet),
                            child: const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Icon(Icons.delete_outline_rounded,
                                  size: 20, color: Color(0xFFFF7578)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _pill(
                        icon: Icons.cake_outlined,
                        label:
                            '${pet.petAge} year${pet.petAge == 1 ? '' : 's'} old'),
                    const SizedBox(height: 6),
                    Row(children: [
                      _pill(
                        icon: pet.petGender == 'MALE'
                            ? Icons.male_rounded
                            : Icons.female_rounded,
                        label: pet.petGender == 'MALE' ? 'Male' : 'Female',
                        color: pet.petGender == 'MALE'
                            ? const Color(0xFF5B9EF7)
                            : _coral,
                      ),
                      if (pet.address != null && pet.address!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _pill(
                            icon: Icons.location_on_outlined,
                            label: pet.address!),
                      ],
                    ]),
                    if (pet.petBreed != null &&
                        pet.petBreed!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _pill(
                        icon: Icons.pets_rounded,
                        label: pet.petBreed!,
                        color: const Color(0xFF2ECC71),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _pill(
      {required IconData icon, required String label, Color? color}) {
    final c = color ?? const Color(0xFF9E9E9E);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: c),
      const SizedBox(width: 3),
      Text(label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 12, color: c, fontWeight: FontWeight.w500)),
    ]);
  }
}

// ── Shared filter widgets ─────────────────────────────────────────────────────

class _GenderDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  static const _coral = Color(0xFFFF7578);

  const _GenderDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final active = value != null;
    return PopupMenuButton<String?>(
      onSelected: onChanged,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: Colors.white,
      itemBuilder: (_) => [
        _item(null, 'All Genders', Icons.pets_rounded),
        _item('Male', 'Male', Icons.male_rounded),
        _item('Female', 'Female', Icons.female_rounded),
      ],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFF0F0) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? _coral : const Color(0xFFFFCCCD),
            width: active ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              value == 'Male'
                  ? Icons.male_rounded
                  : value == 'Female'
                      ? Icons.female_rounded
                      : Icons.wc_rounded,
              size: 16,
              color: active ? _coral : const Color(0xFF9E9E9E),
            ),
            const SizedBox(width: 6),
            Text(
              value ?? 'Gender',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? _coral : const Color(0xFF9E9E9E)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: active ? _coral : const Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String?> _item(String? val, String label, IconData icon) {
    final selected = value == val;
    return PopupMenuItem<String?>(
      value: val,
      child: Row(children: [
        Icon(icon,
            size: 16,
            color: selected ? _coral : const Color(0xFF9E9E9E)),
        const SizedBox(width: 10),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color:
                    selected ? _coral : const Color(0xFF1A1919))),
        if (selected) ...[
          const Spacer(),
          const Icon(Icons.check_rounded, size: 14, color: _coral),
        ],
      ]),
    );
  }
}

class _CitySearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  static const _coral = Color(0xFFFF7578);

  const _CitySearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final focused = focusNode.hasFocus;
    final hasText = controller.text.isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 44,
      decoration: BoxDecoration(
        color: focused ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused ? _coral : const Color(0xFFFFCCCD),
          width: focused ? 1.5 : 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF1A1919),
            fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search city...',
          hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: const Color(0xFFB0B0B0)),
          prefixIcon: const Icon(Icons.location_on_outlined,
              size: 16, color: _coral),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 38, minHeight: 0),
          suffixIcon: hasText
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: Color(0xFFB0B0B0)),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
