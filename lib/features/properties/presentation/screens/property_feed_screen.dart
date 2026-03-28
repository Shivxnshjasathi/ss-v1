import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';

class PropertyFeedScreen extends ConsumerStatefulWidget {
  const PropertyFeedScreen({super.key});

  @override
  ConsumerState<PropertyFeedScreen> createState() => _PropertyFeedScreenState();
}

class _PropertyFeedScreenState extends ConsumerState<PropertyFeedScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Sell', 'Rent/Lease'];
  
  // Advanced Filter State
  String _selectedPropertyType = 'All';
  String _selectedBedrooms = 'Any';
  RangeValues _priceRange = const RangeValues(0, 100); // 0 to 100M+
  
  final List<String> _propertyTypes = ['All', 'Apartment', 'Villa', 'Penthouse', 'Studio'];
  final List<String> _bedroomOptions = ['Any', '1+', '2+', '3+', '4+'];

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesStreamProvider);
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
          
          // Categories
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
            child: propertiesAsync.when(
              data: (properties) {
                final filtered = properties.where((p) {
                  // Category Filter (Sell/Rent)
                  if (_selectedCategory != 'All' && p.type != _selectedCategory) return false;
                  
                  // Property Type Filter
                  if (_selectedPropertyType != 'All' && p.propertyType != _selectedPropertyType) return false;
                  
                  // Bedrooms Filter
                  if (_selectedBedrooms != 'Any') {
                    final requiredBeds = int.tryParse(_selectedBedrooms.replaceAll('+', '')) ?? 0;
                    if (p.bedrooms < requiredBeds) return false;
                  }
                  
                  // Price Filter (assuming price is stored in currency units, convert to millions for check if needed)
                  // For now, mapping millions to flat numbers
                  final priceInMillions = p.price / 1000000;
                  if (priceInMillions < _priceRange.start || (_priceRange.end < 100 && priceInMillions > _priceRange.end)) {
                    return false;
                  }

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                   return const Center(child: Text('No properties found matches your filters.', style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildPropertyCard(context, filtered[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    // Local state for the modal until "Apply" is pressed
    String tempType = _selectedPropertyType;
    String tempBedrooms = _selectedBedrooms;
    RangeValues tempPriceRange = _priceRange;

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
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Filter Properties', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  const Text('PROPERTY TYPE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _propertyTypes.map((type) {
                      final isSelected = tempType == type;
                      return _buildModalChoiceChip(
                        label: type,
                        isSelected: isSelected,
                        onSelected: (val) {
                          if (val) setModalState(() => tempType = type);
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 40),
                  const Text('PRICE RANGE (MILLIONS)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  RangeSlider(
                    values: tempPriceRange,
                    min: 0,
                    max: 100, // Up to 100M+
                    activeColor: Theme.of(context).colorScheme.primary,
                    inactiveColor: context.borderColor,
                    onChanged: (values) {
                      setModalState(() {
                        tempPriceRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${tempPriceRange.start.toStringAsFixed(1)}M', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(tempPriceRange.end >= 100 ? '\$100M+' : '\$${tempPriceRange.end.toStringAsFixed(1)}M', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  const Text('BEDROOMS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _bedroomOptions.map((beds) {
                      final isSelected = tempBedrooms == beds;
                      return _buildModalChoiceChip(
                        label: beds,
                        isSelected: isSelected,
                        onSelected: (val) {
                          if (val) setModalState(() => tempBedrooms = beds);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedPropertyType = tempType;
                          _selectedBedrooms = tempBedrooms;
                          _priceRange = tempPriceRange;
                        });
                        Navigator.pop(context);
                      },
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
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildModalChoiceChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
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
    );
  }

  Widget _buildPropertyCard(BuildContext context, PropertyModel property) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/${property.id}'),
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
                  imageUrl: property.imageUrls.isNotEmpty ? property.imageUrls.first : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800&q=80',
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
                      if (property.isZeroBrokerage)
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
                                '0 BROKERAGE',
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
                      if (property.isZeroBrokerage && property.isVerified)
                        const SizedBox(width: 8),
                      if (property.isVerified)
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
                         property.title,
                         style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                       ),
                       const SizedBox(height: 4),
                       Row(
                         children: [
                           const Icon(Icons.location_on, color: Colors.white70, size: 16),
                           const SizedBox(width: 4),
                           Text(
                             property.city,
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
                              '₹${property.price.toInt()}',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 22, fontWeight: FontWeight.w900)
                            ),
                          ],
                        ),
                      ),
                      _buildAmenity(Icons.king_bed_outlined, '${property.bedrooms} Bed'),
                      const SizedBox(width: 16),
                      _buildAmenity(Icons.bathtub_outlined, '${property.bathrooms} Bath'),
                      const SizedBox(width: 16),
                      _buildAmenity(Icons.square_foot_outlined, '${property.areaSqFt.toInt()} sqft'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: CachedNetworkImageProvider('https://i.pravatar.cc/150?u=marcus'),
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
                            property.ownerId.isNotEmpty ? 'Owner' : 'Unknown',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.primaryTextColor),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => context.push('/properties/detail/${property.id}'),
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
