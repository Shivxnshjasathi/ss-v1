import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/shared/widgets/app_card.dart';

class PropertyFeedScreen extends StatelessWidget {
  const PropertyFeedScreen({super.key});

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
            icon: const Icon(Icons.map),
            onPressed: () {
              // Toggle Map View
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildFilterChip('City: Bangalore'),
                const SizedBox(width: 8),
                _buildFilterChip('Rent'),
                const SizedBox(width: 8),
                _buildFilterChip('2 BHK'),
                const SizedBox(width: 8),
                _buildFilterChip('Budget: Under 20k'),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 5,
              itemBuilder: (context, index) {
                return const _PropertyListItem();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        // Show filter bottom sheet
      },
    );
  }
}

class _PropertyListItem extends StatelessWidget {
  const _PropertyListItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => context.push('/properties/detail/1'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[300],
              ),
              child: Stack(
                children: [
                   const Center(child: Icon(Icons.image, color: Colors.grey, size: 48)),
                   Positioned(
                     top: 12,
                     right: 12,
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                       decoration: BoxDecoration(
                         color: Colors.black.withOpacity(0.6),
                         borderRadius: BorderRadius.circular(4),
                       ),
                       child: const Text(
                         'NO BROKERAGE',
                         style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
