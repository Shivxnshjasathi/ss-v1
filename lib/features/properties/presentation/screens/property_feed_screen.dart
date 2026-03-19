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
      'title': 'The Glass Pavilion',
      'location': 'Downtown Heights',
      'price': '\$3,450,000',
      'beds': '4',
      'baths': '3.5',
      'sqft': '4,200',
      'isVerified': true,
      'isExclusive': true,
      'listedBy': 'ELENA R.',
      'image': 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=80',
      'avatar': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&q=80'
    },
    {
      'title': 'Silverleaf Estate',
      'location': 'Oakwood Valley',
      'price': '\$2,800,000',
      'beds': '5',
      'baths': '4',
      'sqft': '4,500',
      'isVerified': true,
      'isExclusive': false,
      'listedBy': 'SARAH J.',
      'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
      'avatar': 'https://i.pravatar.cc/150?u=sarah'
    },
    {
      'title': 'Vanguard Modern',
      'location': 'Neo District',
      'price': '\$1,900,000',
      'beds': '3',
      'baths': '2',
      'sqft': '2,100',
      'isVerified': false,
      'isExclusive': false,
      'listedBy': 'MARCUS V.',
      'image': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=80',
      'avatar': 'https://i.pravatar.cc/150?u=marcus'
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'PROPERTIES', 
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 16, letterSpacing: 1.2)
        ),
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
                      border: Border.all(color: Colors.grey[300]!),
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
                        GestureDetector(
                          onTap: () => _showFilterSheet(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.tune, color: Colors.white, size: 18),
                          ),
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
                 const Text('Featured Collections', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All', style: TextStyle(color: Color(0xFF00E5FF), fontWeight: FontWeight.w900, fontSize: 14)),
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
                return _buildPropertyCard(context, _properties[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter Properties', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Expanded(
                    child: ListView(
                      controller: controller,
                      children: [
                        const Text('PROPERTY TYPE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildSelectableChip('Apartment', true),
                            _buildSelectableChip('Villa', false),
                            _buildSelectableChip('Penthouse', false),
                            _buildSelectableChip('Studio', false),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        const Text('PRICE RANGE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        RangeSlider(
                          values: const RangeValues(1, 5),
                          min: 0,
                          max: 10,
                          activeColor: const Color(0xFF00E5FF),
                          inactiveColor: Colors.grey[200],
                          onChanged: (values) {},
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$1M', style: TextStyle(fontWeight: FontWeight.w900)),
                            Text('\$5M+', style: TextStyle(fontWeight: FontWeight.w900)),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        const Text('BEDROOMS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildCircleButton('Any', false),
                            _buildCircleButton('1+', false),
                            _buildCircleButton('2+', false),
                            _buildCircleButton('3+', true),
                            _buildCircleButton('4+', false),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom Button
                  SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => context.pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'APPLY FILTERS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectableChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
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

  Widget _buildCircleButton(String label, bool isSelected) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF00E5FF) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isSelected ? const Color(0xFF00E5FF) : Colors.grey.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isSelected ? Colors.black : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, Map<String, dynamic> property) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/123'),
      child: Container(
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
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                // Top Tags
                Positioned(
                  top: 16,
                  left: 16,
                  child: Row(
                    children: [
                      if (property['isExclusive'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'EXCLUSIVE',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      if (property['isExclusive'] == true && property['isVerified'] == true)
                        const SizedBox(width: 8),
                      if (property['isVerified'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white),
                          ),
                          child: const Text(
                            'VERIFIED',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Title and Prices
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property['title'],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Color(0xFF00E5FF), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            property['location'],
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ASKING PRICE', style: TextStyle(color: Color(0xFF00E5FF), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            const SizedBox(height: 4),
                            Text(property['price'], style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)),
                          ],
                        ),
                      ),
                      _buildAmenity(Icons.king_bed_outlined, property['beds']),
                      const SizedBox(width: 16),
                      _buildAmenity(Icons.bathtub_outlined, property['baths']),
                      const SizedBox(width: 16),
                      _buildAmenity(Icons.aspect_ratio_outlined, '${property['sqft']}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: CachedNetworkImageProvider(property['avatar']),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LISTED BY ${property['listedBy']}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => context.push('/properties/detail/123'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          minimumSize: const Size(60, 36),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('VIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenity(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
      ],
    );
  }
}
