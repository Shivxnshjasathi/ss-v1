import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';

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
  RangeValues _priceRange = const RangeValues(0, 100); // 0 to 100 on slider
  
  final List<String> _propertyTypes = ['All', 'Apartment', 'Villa', 'Penthouse', 'Studio'];
  final List<String> _bedroomOptions = ['Any', '1+', '2+', '3+', '4+'];

  String _getLocalizedCategory(AppLocalizations l10n, String category) {
    switch (category) {
      case 'All': return l10n.all;
      case 'Sell': return l10n.sell;
      case 'Rent/Lease': return l10n.rentLease;
      default: return category;
    }
  }

  String _getLocalizedPropertyType(AppLocalizations l10n, String type) {
    switch (type) {
      case 'All': return l10n.all;
      case 'Apartment': return l10n.apartment;
      case 'Villa': return l10n.villa;
      case 'Penthouse': return l10n.penthouse;
      case 'Studio': return l10n.studio;
      case 'House/Villa': return l10n.houseVilla;
      case 'Plot': return l10n.plot;
      case 'PG': return l10n.pg;
      case 'Commercial': return l10n.commercial;
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesStreamProvider);
    final l10n = AppLocalizations.of(context)!;

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
          l10n.propertiesTitle, 
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
                        Icon(Icons.search, color: context.secondaryTextColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: l10n.searchPropertiesHint,
                              hintStyle: TextStyle(color: context.secondaryTextColor.withValues(alpha: 0.5), fontSize: 14),
                              border: InputBorder.none,
                            ),
                            style: TextStyle(color: context.primaryTextColor),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showFilterSheet(context, l10n),
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
                    label: Text(_getLocalizedCategory(l10n, category)),
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
                 Text(l10n.featuredCollections, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    l10n.seeAll, 
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
                  
                  // Price Filter logic
                  // 1 unit = 10 Lakhs = 1,000,000
                  final minPrice = _priceRange.start * 1000000;
                  final maxPrice = _priceRange.end * 1000000;
                  
                  if (p.price < minPrice) return false;
                  if (_priceRange.end < 100 && p.price > maxPrice) return false;

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                   return Center(child: Text(l10n.noPropertiesMatch, style: TextStyle(color: context.secondaryTextColor)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _buildPropertyCard(context, filtered[index], l10n);
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

  String _formatPrice(double value) {
    if (value >= 10) {
      return '₹${(value / 10).toStringAsFixed(1)} Cr';
    } else {
      return '₹${value.toInt() * 10} L';
    }
  }

  void _showFilterSheet(BuildContext context, AppLocalizations l10n) {
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
                      Text(l10n.filterProperties, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: context.primaryTextColor)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  Text(l10n.propertyType, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.secondaryTextColor, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _propertyTypes.map((type) {
                      final isSelected = tempType == type;
                      return _buildModalChoiceChip(
                        label: _getLocalizedPropertyType(l10n, type),
                        isSelected: isSelected,
                        onSelected: (val) {
                          if (val) setModalState(() => tempType = type);
                        },
                      );
                    }).toList(),
                  ),
                  
                  const SizedBox(height: 40),
                  Text(l10n.priceRangeLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.secondaryTextColor, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  RangeSlider(
                    values: tempPriceRange,
                    min: 0,
                    max: 100, // 0 to 10 Cr+
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
                      Text(_formatPrice(tempPriceRange.start), style: TextStyle(fontWeight: FontWeight.bold, color: context.primaryTextColor)),
                      Text(tempPriceRange.end >= 100 ? '${_formatPrice(tempPriceRange.end)}+' : _formatPrice(tempPriceRange.end), style: TextStyle(fontWeight: FontWeight.bold, color: context.primaryTextColor)),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  Text(l10n.bedroomsLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.secondaryTextColor, letterSpacing: 1)),
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
                      child: Text(
                        l10n.applyFilters,
                        style: const TextStyle(
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

  Widget _buildPropertyCard(BuildContext context, PropertyModel property, AppLocalizations l10n) {
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
                  memCacheHeight: 400, // Performance: Limit memory cache size
                  placeholder: (context, url) => Container(color: context.cardColor),
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
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                l10n.zeroBrokerageTag,
                                style: const TextStyle(
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
                            color: context.scaffoldColor.withValues(alpha: 0.95),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                l10n.verifiedTag,
                                style: TextStyle(
                                  color: context.primaryTextColor,
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
                              l10n.askingPrice,
                              style: TextStyle(color: context.secondaryTextColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${property.price.toInt()}',
                              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 22, fontWeight: FontWeight.w900)
                            ),
                          ],
                        ),
                      ),
                      _buildAmenity(Icons.king_bed_outlined, '${property.bedrooms} ${l10n.bed}'),
                      const SizedBox(width: 16),
                      _buildAmenity(Icons.bathtub_outlined, '${property.bathrooms} ${l10n.bath}'),
                      const SizedBox(width: 16),
                      _buildAmenity(Icons.square_foot_outlined, '${property.areaSqFt.toInt()} ${l10n.sqft}'),
                    ],
                  ),
                   const SizedBox(height: 20),
                  Divider(height: 1, color: context.borderColor),
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
                           Text(
                            l10n.listedBy,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: context.secondaryTextColor, letterSpacing: 0.5),
                          ),
                          Text(
                            property.ownerId.isNotEmpty ? 'Owner' : 'Unknown', // Owner/Unknown needs l10n?
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
                        child: Text(l10n.viewDetails, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
        Icon(icon, size: 22, color: context.secondaryTextColor),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.primaryTextColor)),
      ],
    );
  }
}
