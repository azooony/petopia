import 'dart:async';
import 'package:flutter/material.dart';
import 'petmatching.dart';
import 'vetappointmnets.dart';
import 'services/api_client.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  bool _loading = false;
  Timer? _debounce;

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) _searchResults = [];
    });
    if (query.isEmpty) return;
    _debounce = Timer(const Duration(milliseconds: 400), () => _fetch(query));
  }

  Future<void> _fetch(String query) async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient.get('/search?q=${Uri.encodeQueryComponent(query)}');
      final data = res['data'] as Map<String, dynamic>;

      final results = <Map<String, dynamic>>[];

      for (final p in (data['pets'] as List)) {
        final pet = p as Map<String, dynamic>;
        final breed = pet['breed'] as String?;
        final age = pet['age'] as int? ?? 0;
        results.add({
          'type': 'pet',
          'name': pet['name'] as String,
          'subtitle': [
            if (breed != null) breed,
            '$age yr${age == 1 ? '' : 's'}',
          ].join(' • '),
          'photo': pet['photo'] as String?,
          'address': pet['address'] as String?,
          'route': const PetMatching(),
        });
      }

      for (final v in (data['vets'] as List)) {
        final vet = v as Map<String, dynamic>;
        results.add({
          'type': 'doctor',
          'name': vet['name'] as String,
          'subtitle': [
            if ((vet['specialization'] as String?) != null) vet['specialization'] as String,
            vet['clinicAddress'] as String? ?? '',
          ].where((s) => s.isNotEmpty).join(' • '),
          'photo': vet['photo'] as String?,
          'price': (vet['appointmentPrice'] as num?)?.toDouble() ?? 0.0,
          'route': const VetAppointments(),
        });
      }

      if (mounted) setState(() => _searchResults = results);
    } catch (_) {
      if (mounted) setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildLeading(Map<String, dynamic> item) {
    final photo = item['photo'] as String?;
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB5B5).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: photo != null
            ? Image.network(photo, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallbackIcon(item['type'] as String))
            : _fallbackIcon(item['type'] as String),
      ),
    );
  }

  Widget _fallbackIcon(String type) => Icon(
        type == 'doctor' ? Icons.medical_services_rounded : Icons.pets_rounded,
        color: const Color(0xFFFF7578),
        size: 26,
      );

  Widget _buildTrailing(Map<String, dynamic> item) {
    if (item['type'] == 'doctor') {
      final price = item['price'] as double;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB5B5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          price > 0 ? '${price.toStringAsFixed(0)} EGP' : 'VET',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB5B5).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFFFB5B5), width: 0.5),
      ),
      child: Text(
        (item['type'] as String).toUpperCase(),
        style: const TextStyle(
            color: Color(0xFF333333), fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildResult(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildLeading(item),
        title: Text(item['name'] as String,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Color(0xFF333333))),
        subtitle: Text(item['subtitle'] as String,
            style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        trailing: _buildTrailing(item),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => item['route'] as Widget)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C2632),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(30)),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(90),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 8, right: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              hintText: 'Search pets, doctors, locations...',
                              hintStyle: TextStyle(
                                  color: Colors.grey[400], fontSize: 16),
                              border: InputBorder.none,
                              prefixIcon:
                                  Icon(Icons.search, color: Colors.grey[400]),
                              suffixIcon: _isSearching
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      color: Colors.grey[400],
                                      onPressed: () {
                                        _searchController.clear();
                                        _onChanged('');
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: _onChanged,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Builder(builder: (_) {
              if (_searchQuery.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 24),
                      Text('Search for pets, doctors\nor locations',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              height: 1.5)),
                    ],
                  ),
                );
              }
              if (_loading) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF7578)));
              }
              if (_searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 24),
                      Text('No results for "$_searchQuery"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 18,
                              height: 1.5)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (_, i) => _buildResult(_searchResults[i]),
              );
            }),
          ),
        ),
      ),
    );
  }
}
