import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sitting_data.dart';
import 'sitting_pet_profile.dart';
import 'services/sitting_service.dart';
import 'services/api_client.dart';

class PetSitting extends StatefulWidget {
  final String? typeFilter;
  const PetSitting({super.key, this.typeFilter});

  @override
  State<PetSitting> createState() => _PetSittingState();
}

class _PetSittingState extends State<PetSitting> {
  static const _coral = Color(0xFFFF7578);

  List<SittingPet> _pets = [];
  bool _isLoading = true;
  String? _error;

  String? _genderFilter;
  String? _typeFilter;
  final _cityController = TextEditingController();
  final _cityFocus      = FocusNode();
  String _citySearch    = '';

  @override
  void initState() {
    super.initState();
    _typeFilter = widget.typeFilter;
    _cityFocus.addListener(() => setState(() {}));
    _loadPets();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _cityFocus.dispose();
    super.dispose();
  }

  Future<void> _loadPets() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final pets = await SittingService.getAvailablePets();
      if (mounted) setState(() { _pets = pets; _isLoading = false; });
    } on ApiException catch (e) {
      if (mounted) setState(() { _error = e.message; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Failed to load pets. Check your connection.'; _isLoading = false; });
    }
  }

  List<SittingPet> get _filtered => _pets.where((p) {
        if (_typeFilter != null && p.petType != _typeFilter) return false;
        if (_genderFilter != null && p.gender != _genderFilter) return false;
        if (_citySearch.isNotEmpty &&
            !p.city.toLowerCase().contains(_citySearch.toLowerCase())) {
          return false;
        }
        return true;
      }).toList();

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
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('pet sitting',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF8D8D8D)),
                  onPressed: _isLoading ? null : _loadPets,
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: Row(
                    children: [
                      _GenderDropdown(
                        value: _genderFilter,
                        onChanged: (v) => setState(() => _genderFilter = v),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CitySearchField(
                          controller: _cityController,
                          focusNode: _cityFocus,
                          onChanged: (v) => setState(() => _citySearch = v),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _coral));
    }

    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_error!,
              style: GoogleFonts.plusJakartaSans(
                  color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPets,
            style: ElevatedButton.styleFrom(
              backgroundColor: _coral,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: Text('Retry',
                style: GoogleFonts.plusJakartaSans(color: Colors.white)),
          ),
        ]),
      );
    }

    final pets = _filtered;
    if (pets.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.pets_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            _pets.isEmpty
                ? 'No pets are available for sitting yet.'
                : 'No pets match your filters.',
            style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFB0B0B0), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildPetItem(pets[i]),
    );
  }

  Future<void> _deletePet(SittingPet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Remove ${pet.name}?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 17)),
        content: Text(
          '${pet.name} will be removed from the sitting list.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF6B6B6B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.plusJakartaSans(color: const Color(0xFF9E9E9E))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remove',
                style: GoogleFonts.plusJakartaSans(color: _coral, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await SittingService.unlistPet();
      if (mounted) setState(() => _pets.removeWhere((p) => p.id == pet.id));
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message, style: GoogleFonts.plusJakartaSans()),
          backgroundColor: _coral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  Widget _buildPetItem(SittingPet pet) {
    if (pet.isOwn) {
      return Stack(
        children: [
          _buildCard(pet),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => _deletePet(pet),
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 4)],
                ),
                child: const Icon(Icons.delete_outline_rounded, size: 16, color: _coral),
              ),
            ),
          ),
        ],
      );
    }
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SittingPetProfile(pet: pet)),
      ),
      child: _buildCard(pet),
    );
  }

  Widget _buildCard(SittingPet pet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withAlpha(50),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2)),
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
                    width: 94, height: 94,
                    color: const Color(0xFFFFB5B5),
                    child: _petImage(pet),
                  ),
                ),
                if (pet.isOwn)
                  Positioned(
                    top: 4, left: 4,
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pet.name,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 6),
                  _pill(icon: Icons.access_time_rounded, label: pet.duration),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _pill(
                        icon: pet.gender == 'Male'
                            ? Icons.male_rounded
                            : Icons.female_rounded,
                        label: pet.gender,
                        color: pet.gender == 'Male'
                            ? const Color(0xFF5B9EF7)
                            : _coral,
                      ),
                      const SizedBox(width: 8),
                      if (pet.city.isNotEmpty)
                        _pill(
                            icon: Icons.location_on_outlined,
                            label: pet.city),
                    ],
                  ),
                  if (pet.pricePerDay != null) ...[
                    const SizedBox(height: 6),
                    _pill(
                      icon: Icons.payments_outlined,
                      label: pet.pricePerDay!,
                      color: const Color(0xFF2ECC71),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _petImage(SittingPet pet) {
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
    if (pet.imagePath != null) {
      return Image.asset(pet.imagePath!, fit: BoxFit.contain);
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
          child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: c, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

// ── Filter widgets ─────────────────────────────────────────────────────────────

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: Colors.white,
      itemBuilder: (_) => [
        _item(null,     'All Genders', Icons.pets_rounded),
        _item('Male',   'Male',        Icons.male_rounded),
        _item('Female', 'Female',      Icons.female_rounded),
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
            Text(value ?? 'Gender',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? _coral : const Color(0xFF9E9E9E))),
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
      child: Row(
        children: [
          Icon(icon,
              size: 16,
              color: selected ? _coral : const Color(0xFF9E9E9E)),
          const SizedBox(width: 10),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? _coral : const Color(0xFF1A1919))),
          if (selected) ...[
            const Spacer(),
            const Icon(Icons.check_rounded, size: 14, color: _coral),
          ],
        ],
      ),
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
