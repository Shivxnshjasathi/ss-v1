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

  @override
  Widget build(BuildContext context) {
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
                        _buildFilterChip(context, 'City: Bangalore', Icons.location_city),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, 'Rent', Icons.home),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, '2 BHK', Icons.bed),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, 'Budget: Under 20k', Icons.attach_money),
                        const SizedBox(width: 8),
                        _buildFilterChip(context, 'Owner Only', Icons.person),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _PropertyListItem(index: index);
                      },
                      childCount: 10,
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

  Widget _buildFilterChip(BuildContext context, String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () {
        _showAdvancedFilters(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
    );
  }

  void _showAdvancedFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
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
                children: ['1 RK', '1 BHK', '2 BHK', '3 BHK', '4+ BHK']
                    .map((e) => FilterChip(label: Text(e), onSelected: (_) {}))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text('Property Type', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Apartment', 'Independent House', 'Villa', 'PG']
                    .map((e) => FilterChip(label: Text(e), onSelected: (_) {}))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Show Owner Listings Only', style: Theme.of(context).textTheme.titleMedium),
                  Switch(value: true, onChanged: (_) {}),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
  }
}

class _PropertyListItem extends StatelessWidget {
  final int index;
  const _PropertyListItem({required this.index});

  @override
  Widget build(BuildContext context) {
    final images = [
      'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&q=80',
      'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=80',
      'https://images.unsplash.com/photo-1600607687931-57d1eb14cbfc?w=800&q=80',
      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800&q=80',
    ];
    final imageUrl = images[index % images.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push('/properties/detail/1'),
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
                     imageUrl: imageUrl,
                     fit: BoxFit.cover,
                     placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                     errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                   ),
                     Positioned(
                       top: 16,
                       right: 16,
                       child: Container(
                         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: BoxDecoration(
                           color: Colors.black.withOpacity(0.7),
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
                        '₹ 18,000',
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
                    '2 BHK Flat In HSR Layout',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.square_foot, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('1000 sqft', style: TextStyle(color: Colors.grey[700])),
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
