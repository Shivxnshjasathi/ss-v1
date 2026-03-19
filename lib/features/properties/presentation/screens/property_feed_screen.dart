import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/shared/widgets/app_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PropertyFeedScreen extends StatefulWidget {
  const PropertyFeedScreen({super.key});

  @override
  State<PropertyFeedScreen> createState() => _PropertyFeedScreenState();
}

class _PropertyFeedScreenState extends State<PropertyFeedScreen> {
  bool _isMapView = false;
  
  // Filter State
  String _selectedBhk = 'All';
  bool _isOwnerOnly = false;

  final List<Map<String, dynamic>> _allProperties = [
    {'bhk': '1 RK', 'type': 'PG', 'owner': true, 'price': '₹ 10,000', 'title': '1 RK Studio in BTM', 'area': '350 sqft', 'image': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=80'},
    {'bhk': '2 BHK', 'type': 'Apartment', 'owner': false, 'price': '₹ 18,000', 'title': '2 BHK Flat In HSR Layout', 'area': '1000 sqft', 'image': 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=80'},
    {'bhk': '3 BHK', 'type': 'Apartment', 'owner': true, 'price': '₹ 25,000', 'title': '3 BHK Premium Showcase', 'area': '1500 sqft', 'image': 'https://images.unsplash.com/photo-1600607687931-57d1eb14cbfc?w=800&q=80'},
    {'bhk': '1 BHK', 'type': 'Independent', 'owner': true, 'price': '₹ 12,000', 'title': '1 BHK Independent House', 'area': '600 sqft', 'image': 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80'},
    {'bhk': '2 BHK', 'type': 'Villa', 'owner': false, 'price': '₹ 35,000', 'title': '2 BHK Luxury Villa', 'area': '2000 sqft', 'image': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=80'},
  ];

  List<Map<String, dynamic>> get _filteredProperties {
    return _allProperties.where((p) {
      if (_selectedBhk != 'All' && p['bhk'] != _selectedBhk) return false;
      if (_isOwnerOnly && p['owner'] != true) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final properties = _filteredProperties;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.view_list : Icons.map),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          ),
        ],
      ),
      body: _isMapView
          ? _buildMapView()
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        _buildFilterChip(context, 'City: Bangalore', Icons.location_city, () {}),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, _selectedBhk == 'All' ? 'BHK' : _selectedBhk, Icons.bed, () => _showAdvancedFilters(context)),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, _isOwnerOnly ? 'Owner Only' : 'Owner/Broker', Icons.person, () => _showAdvancedFilters(context)),
                      ],
                    ),
                  ),
                ),
                if (properties.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: const Text('No properties match your filters.', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _PropertyListItem(
                            property: properties[index],
                            index: index,
                          );
                        },
                        childCount: properties.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildMapView() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Map Integration Loading...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      side: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
    );
  }

  void _showAdvancedFilters(BuildContext context) {
    String tempBhk = _selectedBhk;
    bool tempOwner = _isOwnerOnly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Advanced Filters', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Text('BHK Types', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['All', '1 RK', '1 BHK', '2 BHK', '3 BHK', '4+ BHK']
                        .map((e) => FilterChip(
                              label: Text(e),
                              selected: tempBhk == e,
                              onSelected: (_) {
                                setModalState(() {
                                  tempBhk = e;
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Show Owner Listings Only', style: Theme.of(context).textTheme.titleMedium),
                      Switch(
                        value: tempOwner,
                        onChanged: (val) {
                          setModalState(() {
                            tempOwner = val;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedBhk = tempBhk;
                        _isOwnerOnly = tempOwner;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PropertyListItem extends StatelessWidget {
  final Map<String, dynamic> property;
  final int index;

  const _PropertyListItem({required this.property, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push('/properties/detail/$index'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                   CachedNetworkImage(
                     imageUrl: property['image'],
                     fit: BoxFit.cover,
                     placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                     errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                   ),
                   if (property['owner'])
                     Positioned(
                       top: 16,
                       right: 16,
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           color: Colors.black.withValues(alpha: 0.7),
                           borderRadius: BorderRadius.circular(12),
                         ),
                         child: const Text(
                           'NO BROKERAGE',
                           style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                         ),
                       ),
                     ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        property['price'],
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {},
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property['title'],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.square_foot, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(property['area'], style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(width: 16),
                      const Icon(Icons.chair, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Semi-Furnished', style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Contact Owner'),
                        ),
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
}
