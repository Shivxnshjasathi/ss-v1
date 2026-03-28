import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';

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

  String _selectedCategory = 'Rent';
  final List<String> _categories = ['Rent', 'Buy', 'Commercial'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.iconColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Properties', 
          style: TextStyle(fontWeight: FontWeight.bold, color: context.primaryTextColor, fontSize: 18)
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
                      color: context.surfaceColor,
                      border: Border.all(color: context.borderColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search by area or developer...',
                              hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showFilterSheet(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.tune, color: Theme.of(context).colorScheme.primary, size: 18),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = category),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : context.primaryTextColor,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    backgroundColor: context.cardColor,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? Theme.of(context).colorScheme.primary : context.borderColor,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 const Text('Featured Collections', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'See All', 
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 14)
                  ),
                ),
              ],
            ),
          ),
          
          // Property Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    String selectedType = 'Apartment';
    String selectedBedrooms = '3+';
    RangeValues priceRange = const RangeValues(1, 5);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.scaffoldColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                          const Text('Filter Properties', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
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
                            const Text('PROPERTY TYPE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: ['Apartment', 'Villa', 'Penthouse', 'Studio'].map((type) {
                                final isSelected = selectedType == type;
                                return ChoiceChip(
                                  label: Text(type),
                                  selected: isSelected,
                                  onSelected: (_) => setModalState(() => selectedType = type),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : context.primaryTextColor,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                  backgroundColor: context.cardColor,
                                  selectedColor: Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected ? Theme.of(context).colorScheme.primary : context.borderColor,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            
                            const SizedBox(height: 32),
                            const Text('PRICE RANGE (MILLIONS)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                            const SizedBox(height: 12),
                            RangeSlider(
                              values: priceRange,
                              min: 0,
                              max: 10,
                              activeColor: Theme.of(context).colorScheme.primary,
                              inactiveColor: Colors.grey.shade200,
                              onChanged: (values) {
                                setModalState(() {
                                  priceRange = values;
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('\$${priceRange.start.toStringAsFixed(1)}M', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('\$${priceRange.end.toStringAsFixed(1)}M+', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            const Text('BEDROOMS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: ['Any', '1+', '2+', '3+', '4+'].map((beds) {
                                final isSelected = selectedBedrooms == beds;
                                return ChoiceChip(
                                  label: Text(beds),
                                  selected: isSelected,
                                  onSelected: (_) => setModalState(() => selectedBedrooms = beds),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                  backgroundColor: Colors.white,
                                  selectedColor: Theme.of(context).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                                    ),
                                  ),
                                );
                              }).toList(),
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
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Apply Filters',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
          }
        );
      },
    );
  }

  Widget _buildPropertyCard(BuildContext context, Map<String, dynamic> property) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/123'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
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
                // Gradient Overlay for text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'EXCLUSIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (property['isExclusive'] == true && property['isVerified'] == true)
                        const SizedBox(width: 8),
                      if (property['isVerified'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 12),
                              const SizedBox(width: 4),
                              const Text(
                                'VERIFIED',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
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
                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                       ),
                       const SizedBox(height: 4),
                       Row(
                         children: [
                           const Icon(Icons.location_on, color: Colors.white70, size: 16),
                           const SizedBox(width: 4),
                           Text(
                             property['location'],
                             style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
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
                            Text(
                              'ASKING PRICE',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)
                            ),
                            const SizedBox(height: 4),
                            Text(
                              property['price'],
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 22, fontWeight: FontWeight.w900)
                            ),
                          ],
                        ),
                      ),
                      _buildAmenity(Icons.king_bed_outlined, '${property['beds']} Bed'),
                      const SizedBox(width: 16),
                      _buildAmenity(Icons.bathtub_outlined, '${property['baths']} Bath'),
                      const SizedBox(width: 16),
                      _buildAmenity(Icons.square_foot_outlined, '${property['sqft']} sqft'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: CachedNetworkImageProvider(property['avatar']),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           const Text(
                            'LISTED BY',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                          ),
                          Text(
                            property['listedBy'],
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.primaryTextColor),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => context.push('/properties/detail/123'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          minimumSize: const Size(60, 36),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 22, color: Colors.grey.shade600),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.primaryTextColor)),
      ],
    );
  }
}
