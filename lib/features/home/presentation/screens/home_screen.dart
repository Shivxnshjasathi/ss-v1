import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back,',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 16
              ),
            ),
            Text(
              'Shivansh',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 16
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => context.push('/profile'),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider('https://i.pravatar.cc/150?u=a042581f4e29026704d'),
                    radius: 20,
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                readOnly: true,
                onTap: () => context.push('/properties'),
                decoration: InputDecoration(
                  hintText: 'Search for properties...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: const Icon(Icons.tune, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  filled: true,
                  fillColor: context.surfaceColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Categories Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryItem(context, 'BUY', Icons.home_outlined, () => context.push('/properties')),
                  _buildCategoryItem(context, 'RENT', Icons.domain, () => context.push('/properties')),
                  _buildCategoryItem(context, 'LIST', Icons.add_home_work_outlined, () => context.push('/add-property')),
                  _buildCategoryItem(context, 'SERVICES', Icons.work_outline, () => context.push('/services')),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Access Services Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryItem(context, 'LOAN', Icons.account_balance_outlined, () => context.push('/services/loan')),
                  _buildCategoryItem(context, 'CONSTRUCT', Icons.architecture_outlined, () => context.push('/services/construction')),
                  _buildCategoryItem(context, 'LEGAL', Icons.gavel_outlined, () => context.push('/services/legal')),
                  _buildCategoryItem(context, 'MOVERS', Icons.local_shipping_outlined, () => context.push('/services/movers')),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Featured Zero-Brokerage Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'FEATURED ZERO-BROKERAGE',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/properties'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SEE ALL',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16, color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 320,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildFeaturedCard(context, 'Silver Oak Residency', '₹45,000', 'VIJAY NAGAR, JABALPUR', 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&q=80'),
                  const SizedBox(width: 16),
                  _buildFeaturedCard(context, 'The Grand Horizon', '₹32,000', 'CIVIL LINES, JABALPUR', 'https://images.unsplash.com/photo-1600607687931-57d1eb14cbfc?w=600&q=80'),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Newly Added Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'NEWLY ADDED',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                   _buildNewlyAddedItem(
                    context: context,
                    title: 'Cozy 2BHK Apartment',
                    price: '₹18,500',
                    type: 'Rent',
                    image: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=300&q=80',
                  ),
                  const SizedBox(height: 12),
                  _buildNewlyAddedItem(
                    context: context,
                    title: 'Luxury PG for Students',
                    price: '₹8,000',
                    type: 'PG',
                    image: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=300&q=80',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // padding for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           context.push('/chatbot');
        },
        backgroundColor: const Color(0xFF1E60FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.borderColor, width: 1.0),
            ),
            child: Icon(icon, color: context.iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: context.primaryTextColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, String title, String price, String location, String imageUrl) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/123'),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: CachedNetworkImageProvider(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
            // Zero Brokerage Badge
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E60FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Zero Brokerage',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            // Info Section
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '/ month',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
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

  Widget _buildNewlyAddedItem({required BuildContext context, required String title, required String price, required String type, required String image}) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/123'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            // Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 2,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: context.borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: context.isDarkMode ? Colors.white54 : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.flash_on, color: Color(0xFF1E60FF), size: 12),
                      const SizedBox(width: 4),
                      const Text(
                        'DIRECT OWNER',
                        style: TextStyle(color: Color(0xFF1E60FF), fontSize: 10, fontWeight: FontWeight.w900),
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
