import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';

class SavedPropertiesScreen extends ConsumerWidget {
  const SavedPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    LoggerService.trackScreen('SavedPropertiesScreen');
    final userAsync = ref.watch(currentUserDataProvider);
    
    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Saved Properties')),
            body: const Center(child: Text('Please log in to see saved properties.')),
          );
        }

        final savedAsync = ref.watch(savedPropertiesProvider(user.uid));

        return Scaffold(
          backgroundColor: context.scaffoldColor,
          appBar: AppBar(
            backgroundColor: context.scaffoldColor,
            elevation: 0,
            title: Text(
              'Saved Properties',
              style: TextStyle(fontWeight: FontWeight.w900, color: context.primaryTextColor, fontSize: 24),
            ),
          ),
          body: savedAsync.when(
            data: (properties) {
              if (properties.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: context.secondaryTextColor),
                      const SizedBox(height: 16),
                      Text('You have no saved properties yet.', style: TextStyle(color: context.secondaryTextColor)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final prop = properties[index];
                  return _buildSavedCard(context, prop);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) {
              LoggerService.e('Error loading saved properties', error: e, stack: st);
              return Center(child: Text('Error: $e'));
            },
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildSavedCard(BuildContext context, PropertyModel property) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/${property.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            // Image
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    property.imageUrls.isNotEmpty 
                        ? property.imageUrls.first 
                        : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=300&q=80',
                  ),
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
                  Text(
                    property.title,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                       Icon(Icons.location_on, size: 12, color: context.secondaryTextColor),
                      const SizedBox(width: 4),
                      Text(
                        property.city,
                        style: TextStyle(color: context.secondaryTextColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${property.price.toInt()}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildSpecSmall(context, Icons.king_bed_outlined, '${property.bedrooms}'),
                      const SizedBox(width: 12),
                      _buildSpecSmall(context, Icons.bathtub_outlined, '${property.bathrooms}'),
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

  Widget _buildSpecSmall(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.secondaryTextColor),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.secondaryTextColor)),
      ],
    );
  }
}
