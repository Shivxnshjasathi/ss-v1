import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
import 'package:sampatti_bazar/core/services/location_provider.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserDataProvider);
    final propertiesAsync = ref.watch(propertiesStreamProvider);
    final locationAsync = ref.watch(userLocationProvider);
    final l10n = AppLocalizations.of(context)!;
    
    final fullName = userAsync.value?.name ?? 'User';
    final firstName = fullName.split(' ')[0];
    final currentLocation = locationAsync.when(
      data: (city) => city,
      loading: () => 'Fetching...',
      error: (_, __) => 'Location Error',
    );

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
              l10n.welcome,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  '$firstName!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: context.primaryTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.location_on, size: 14, color: Color(0xFF1E60FF)),
                const SizedBox(width: 2),
                Text(
                  currentLocation,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
                  hintText: l10n.searchProperties,
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

            // Categories Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildAdaptiveCategoryGrid(
                context,
                [
                  _CategoryData(l10n.buy, Icons.home_outlined, () {
                    LoggerService.i('Home: Buy tapped');
                    context.push('/properties');
                  }),
                  _CategoryData(l10n.rent, Icons.domain, () {
                    LoggerService.i('Home: Rent tapped');
                    context.push('/properties');
                  }),
                  _CategoryData(l10n.list, Icons.add_home_work_outlined, () {
                    LoggerService.i('Home: List property tapped');
                    context.push('/add-property');
                  }),
                  _CategoryData(l10n.services, Icons.work_outline, () {
                    LoggerService.i('Home: Services tapped');
                    context.push('/services');
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick Access Services Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildAdaptiveCategoryGrid(
                context,
                [
                  _CategoryData(l10n.loan, Icons.account_balance_outlined, () => context.push('/services/loan')),
                  _CategoryData(l10n.construct, Icons.architecture_outlined, () => context.push('/services/construction')),
                  _CategoryData(l10n.legal, Icons.gavel_outlined, () => context.push('/services/legal')),
                  _CategoryData(l10n.movers, Icons.local_shipping_outlined, () => context.push('/services/movers')),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Dynamic Properties Section
            propertiesAsync.when(
              data: (properties) {
                if (properties.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(l10n.noPropertiesYet, style: const TextStyle(color: Colors.grey)),
                    ),
                  );
                }
                
                final zeroBrokerage = properties.where((p) => p.isZeroBrokerage).toList();
                final featured = zeroBrokerage.isNotEmpty ? zeroBrokerage : properties.take(5).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Zero-Brokerage Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.featuredZeroBrokerage,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, height: 1.1),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/properties'),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.seeAll,
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
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: featured.length,
                        itemBuilder: (context, index) {
                          final prop = featured[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: _buildFeaturedCard(context, prop.title, '₹${prop.price.toInt()}', prop.city, prop.imageUrls.isNotEmpty ? prop.imageUrls.first : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=600&q=80', prop.id),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Newly Added Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        l10n.newlyAdded,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: properties.take(5).map((prop) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildNewlyAddedItem(
                              context: context,
                              title: prop.title,
                              price: '₹${prop.price.toInt()}',
                              type: prop.type,
                              image: prop.imageUrls.isNotEmpty ? prop.imageUrls.first : 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=300&q=80',
                              propertyId: prop.id,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
              error: (err, stack) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('Error: $err'))),
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

  Widget _buildAdaptiveCategoryGrid(BuildContext context, List<_CategoryData> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (items.length - 1) * 12) / items.length;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.map((item) => _buildCategoryItem(context, item.title, item.icon, item.onTap, itemWidth)).toList(),
        );
      },
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, IconData icon, VoidCallback onTap, double width) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width.clamp(50.0, 70.0),
            height: width.clamp(50.0, 70.0),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor, width: 1.0),
            ),
            child: Icon(icon, color: context.iconColor, size: width.clamp(20.0, 28.0)),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: width,
            child: Text(
              title,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildFeaturedCard(BuildContext context, String title, String price, String location, String imageUrl, String propertyId) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/$propertyId'),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: ResizeImage(
              CachedNetworkImageProvider(imageUrl),
              width: 500,
            ),
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

  Widget _buildNewlyAddedItem({required BuildContext context, required String title, required String price, required String type, required String image, required String propertyId}) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/$propertyId'),
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

class _CategoryData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  _CategoryData(this.title, this.icon, this.onTap);
}
