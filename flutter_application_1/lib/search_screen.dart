import 'package:flutter/material.dart';
import 'petmatching.dart';
import 'pet_sitting.dart';
import 'vetappointmnets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  final List<Map<String, dynamic>> _allItems = [
    {
      'type': 'service',
      'name': 'Pet Matching',
      'subtitle': 'Find the perfect pet for you',
      'image': 'assets/images/cat.png',
      'route': const PetMatching(),
    },
    {
      'type': 'service',
      'name': 'Pet Sitting',
      'subtitle': 'Professional pet sitting services',
      'image': 'assets/images/dog.png',
      'route': const PetSitting(),
    },
    {
      'type': 'service',
      'name': 'Vet Appointment',
      'subtitle': 'Book appointments with veterinarians',
      'image': 'assets/images/dr.png',
      'route': const VetAppointments(),
    },
    {
      'type': 'doctor',
      'name': 'Dr. Kareem Ahmed',
      'subtitle': 'Senior Veterinarian',
      'image': 'assets/images/vet1.png',
      'route': const VetAppointments(),
      'rating': 4.9,
    },
    {
      'type': 'doctor',
      'name': 'Dr. Hamza Tariq',
      'subtitle': 'Pet Specialist',
      'image': 'assets/images/vet2.png',
      'route': const VetAppointments(),
      'rating': 4.8,
    },
    {
      'type': 'doctor',
      'name': 'Dr. Ali Uzair',
      'subtitle': 'Animal Surgeon',
      'image': 'assets/images/vet3.png',
      'route': const VetAppointments(),
      'rating': 4.7,
    },
    {
      'type': 'pet',
      'name': 'Maylo',
      'subtitle': 'Golden Retriever • 2 years',
      'image': 'assets/images/maylo.png',
      'route': const PetMatching(),
    },
    {
      'type': 'pet',
      'name': 'Luna',
      'subtitle': 'Persian Cat • 1 year',
      'image': 'assets/images/luna.png',
      'route': const PetMatching(),
    },
    {
      'type': 'pet',
      'name': 'Simba',
      'subtitle': 'Bengal Cat • 3 years',
      'image': 'assets/images/simba.png',
      'route': const PetMatching(),
    },
  ];

  List<Map<String, dynamic>> _searchResults = [];

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allItems.where((item) {
          return item['name'].toLowerCase().contains(query.toLowerCase()) ||
                 item['subtitle'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Widget _buildSearchResult(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFFB5B5).withValues(alpha: 26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item['image'],
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          item['name'],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          item['subtitle'],
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: _buildTrailingWidget(item),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item['route']),
          );
        },
      ),
    );
  }

  Widget _buildTrailingWidget(Map<String, dynamic> item) {
    if (item['type'] == 'doctor') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB5B5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              '${item['rating']}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB5B5).withValues(alpha: 26),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFFFB5B5),
          width: 0.5,
        ),
      ),
      child: Text(
        item['type'].toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF333333),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1C2632),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 375,
            maxHeight: 812,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(90),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 8.0, right: 8.0),
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
                        child: Container(
                          alignment: Alignment.center,
                          height: 48,
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                              hintText: 'Search for vets, services...',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                              suffixIcon: _isSearching
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      color: Colors.grey[400],
                                      onPressed: () {
                                        _searchController.clear();
                                        _performSearch('');
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: _performSearch,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: Center(
              child: Column(
                children: [
                  if (_searchQuery.isEmpty)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Search for vets, services,\nor pet categories',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_searchResults.isEmpty)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No results found for "$_searchQuery"',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 18,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return _buildSearchResult(_searchResults[index]);
                        },
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
} 