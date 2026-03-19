import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PropertyFeedScreen extends StatefulWidget {
  const PropertyFeedScreen({super.key});

  @override
  State<PropertyFeedScreen> createState() => _PropertyFeedScreenState();
}

class _PropertyFeedScreenState extends State<PropertyFeedScreen> {
  final List<Map<String, dynamic>> _properties = [
    {
      'title': 'The Onyx Penthouse',
      'location': 'Downtown Heights',
      'price': '\$4.2M',
      'beds': '4',
      'baths': '3',
      'sqft': '3,200',
      'isVerified': true,
      'listedBy': 'MARCUS V.',
      'image': 'https://images.unsplash.com/photo-1600607687931-57d1eb14cbfc?w=800&q=80',
      'avatar': 'https://i.pravatar.cc/150?u=marcus'
    },
    {
      'title': 'Silverleaf Estate',
      'location': 'Oakwood Valley',
      'price': '\$2.8M',
      'beds': '5',
      'baths': '4',
      'sqft': '4,500',
      'isVerified': true,
      'listedBy': 'SARAH J.',
      'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
      'avatar': 'https://i.pravatar.cc/150?u=sarah'
    },
    {
      'title': 'Vanguard Modern',
      'location': 'Neo District',
      'price': '\$1.9M',
      'beds': '3',
      'baths': '2',
      'sqft': '2,100',
      'isVerified': true,
      'listedBy': 'ELENA R.',
      'image': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=80',
      'avatar': 'https://i.pravatar.cc/150?u=elena'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 32),
          onPressed: () => context.pop(),
        ),
        title: const Text('PROPERTIES', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 16, letterSpacing: 1.2)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.black54),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search by area or developer',
                              hintStyle: TextStyle(color: Colors.black26, fontSize: 14, fontWeight: FontWeight.normal),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.tune, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                _buildFilterChip('Rent', true),
                const SizedBox(width: 12),
                _buildFilterChip('Buy', false),
                const SizedBox(width: 12),
                _buildFilterChip('Commercial', false),
              ],
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Featured Collections', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All', style: TextStyle(color: Color(0xFF00D1FF), fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ],
            ),
          ),
          
          // Property Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _properties.length,
              itemBuilder: (context, index) {
                return _buildPropertyCard(_properties[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00D1FF) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isSelected ? const Color(0xFF00D1FF) : Colors.grey.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: property['image'],
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[100]),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                    ),
                  ),
                ),
              ),
              // Price Badge
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    property['price'],
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
              // Verified Badge
              if (property['isVerified'])
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D1FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.verified, color: Colors.white, size: 10),
                        SizedBox(width: 4),
                        Text('VERIFIED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ),
              // Title and Location
              Positioned(
                bottom: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property['title'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                    Text(
                      property['location'],
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Amenities
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAmenity(Icons.king_bed_outlined, property['beds']),
                    _buildAmenity(Icons.bathtub_outlined, property['baths']),
                    _buildAmenity(Icons.square_foot_outlined, '${property['sqft']} sqft'),
                    const Icon(Icons.chevron_right, color: Colors.black54),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundImage: CachedNetworkImageProvider(property['avatar']),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'LISTED BY ${property['listedBy']}',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'VIEW DETAILS',
                        style: TextStyle(color: Color(0xFF00D1FF), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenity(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    );
  }
}
