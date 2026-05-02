import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/services/domain/cart_service.dart';
import 'package:sampatti_bazar/features/services/domain/marketplace_data.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final CartService cart = CartService();
  String _selectedCategoryId = 'all';
  String _selectedSubcategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Advanced Filter State
  String _sortBy = 'Default';
  RangeValues _priceRange = const RangeValues(0, 100000);
  final List<String> _selectedBrands = [];

  List<MarketplaceProduct> get _filteredProducts {
    // Universal Search: if search is active, look across all products
    // Otherwise, respect the category selection
    var products = _searchQuery.isNotEmpty 
      ? MarketplaceData.products 
      : (_selectedCategoryId == 'all' 
          ? MarketplaceData.products 
          : MarketplaceData.products.where((p) => p.categoryId == _selectedCategoryId).toList());

    // Apply Subcategory filter only if search is NOT active or if we are in a specific category
    if (_searchQuery.isEmpty && _selectedSubcategory != 'All' && _selectedCategoryId != 'all') {
      products = products.where((p) => p.subcategory == _selectedSubcategory).toList();
    }
    
    // Apply Universal Search Query
    if (_searchQuery.isNotEmpty) {
      products = products.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
        (p.brand?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
        p.subcategory.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply Price Filter
    products = products.where((p) => p.price >= _priceRange.start && p.price <= _priceRange.end).toList();

    // Apply Brand Filter
    if (_selectedBrands.isNotEmpty) {
      products = products.where((p) => _selectedBrands.contains(p.brand)).toList();
    }

    // Apply Sorting
    if (_sortBy == 'Price: Low to High') {
      products.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'Price: High to Low') {
      products.sort((a, b) => b.price.compareTo(a.price));
    }
    
    return products;
  }

  String _formatCurrency(double amount) {
    String text = amount.toStringAsFixed(0);
    text = text.replaceAllMapped(RegExp(r'(\d)(?=(\d\d)+\d$)'), (Match m) => '${m[1]},');
    return '₹$text';
  }

  void _addToCart(MarketplaceProduct product) {
    cart.addItem(CartItem(
      id: product.id,
      category: product.categoryId,
      title: product.name,
      price: product.price,
      unit: product.unit,
      image: product.image,
    ));
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.addedToCart(product.name)),
        backgroundColor: AppTheme.primaryBlue,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: l10n.viewCartLabel,
          textColor: Colors.white,
          onPressed: () => context.push('/services/marketplace/cart'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: _buildNormalAppBar(l10n),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(l10n),
            _buildCategorySection(l10n),
            if (_selectedCategoryId != 'all' && _searchQuery.isEmpty) _buildSubcategorySection(l10n),
            _buildProductHeader(l10n, filtered.length),
            if (filtered.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 100.h),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64.w, color: Colors.grey.withValues(alpha: 0.3)),
                      SizedBox(height: 16.h),
                      Text(l10n.noProductsFound, style: const TextStyle(color: Colors.grey)),
                      if (_searchQuery.isNotEmpty)
                        TextButton(
                          onPressed: () => setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          }),
                          child: const Text("Clear Search", style: TextStyle(color: AppTheme.primaryBlue)),
                        ),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.52,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return _buildProductCard(product, l10n);
                  },
                ),
              ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: context.scaffoldColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: context.cardColor,
                border: Border.all(color: context.borderColor),
                borderRadius: BorderRadius.circular(14.sp),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: context.iconColor,
                size: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            l10n.marketplace,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: context.primaryTextColor,
              fontSize: 20.sp,
            ),
          ),
        ],
      ),
      actions: [
        ListenableBuilder(
          listenable: cart,
          builder: (context, _) {
            return GestureDetector(
              onTap: () => context.push('/services/marketplace/cart'),
              child: Container(
                margin: EdgeInsets.only(right: 16.w, top: 8.h, bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  border: Border.all(color: context.borderColor),
                  borderRadius: BorderRadius.circular(14.sp),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, color: context.iconColor, size: 18.sp),
                    if (cart.itemCount > 0) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20.sp),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: "Search materials, brands...",
            hintStyle: TextStyle(color: context.secondaryTextColor.withValues(alpha: 0.5), fontSize: 14.sp, fontFamily: 'Poppins'),
            prefixIcon: Icon(Icons.search, color: context.primaryTextColor, size: 20.sp),
            suffixIcon: _searchQuery.isNotEmpty 
              ? IconButton(
                  icon: Icon(Icons.clear, size: 18.w),
                  onPressed: () => setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  }),
                )
              : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 16.h),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text("Browse Categories", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp, letterSpacing: 0.5)),
        ),
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            itemCount: MarketplaceData.categories.length + 1,
            itemBuilder: (context, index) {
              bool isAll = index == 0;
              MarketplaceCategory? cat = isAll ? null : MarketplaceData.categories[index - 1];
              String id = isAll ? 'all' : cat!.id;
              String name = isAll ? l10n.all : _getLocalizedCategory(id, l10n);
              IconData icon = isAll ? Icons.grid_view_rounded : cat!.icon;
              bool isSelected = _selectedCategoryId == id;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedCategoryId = id;
                    _selectedSubcategory = 'All';
                  }),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isSelected ? context.surfaceColor : context.cardColor,
                          borderRadius: BorderRadius.circular(20.sp),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryBlue : context.borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Icon(icon, color: isSelected ? context.primaryTextColor : context.iconColor, size: 26.w),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: isSelected ? AppTheme.primaryBlue : context.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubcategorySection(AppLocalizations l10n) {
    final cat = MarketplaceData.categories.firstWhere((c) => c.id == _selectedCategoryId);
    final subs = ['All', ...cat.subcategories];

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: subs.length,
        itemBuilder: (context, index) {
          final sub = subs[index];
          bool isSelected = _selectedSubcategory == sub;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: GestureDetector(
              onTap: () => setState(() => _selectedSubcategory = sub),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? context.surfaceColor : context.cardColor,
                  borderRadius: BorderRadius.circular(20.w),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryBlue : context.borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  _getLocalizedSubcategory(sub, l10n),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: isSelected ? AppTheme.primaryBlue : context.primaryTextColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductHeader(AppLocalizations l10n, int count) {
    return Padding(
      padding: EdgeInsets.all(16.0.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Showing $count products", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: context.secondaryTextColor, fontFamily: 'Poppins')),
          GestureDetector(
            onTap: () => _showFilterSheet(l10n),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, size: 16.w, color: context.iconColor),
                  SizedBox(width: 4.w),
                  Text("Filter", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: context.iconColor, fontFamily: 'Poppins')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        sortBy: _sortBy,
        priceRange: _priceRange,
        selectedBrands: _selectedBrands,
        allBrands: MarketplaceData.products.map((p) => p.brand).whereType<String>().toSet().toList(),
        onApply: (sort, range, brands) {
          setState(() {
            _sortBy = sort;
            _priceRange = range;
            _selectedBrands.clear();
            _selectedBrands.addAll(brands);
          });
        },
      ),
    );
  }

  Widget _buildProductCard(MarketplaceProduct product, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(22.sp),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: context.surfaceColor,
                      child: Center(
                        child: Icon(Icons.image_not_supported_outlined, size: 32.w, color: context.secondaryTextColor.withValues(alpha: 0.3)),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: context.surfaceColor,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryBlue,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8.w,
                  right: 8.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20.w),
                    ),
                    child: Text(
                      product.subcategory.toUpperCase(),
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryBlue,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.brand != null)
                  Text(
                    product.brand!.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                SizedBox(height: 2.h),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: context.primaryTextColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _formatCurrency(product.price),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16.sp,
                        color: context.primaryTextColor,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Flexible(
                      child: Text(
                        '/ ${product.unit}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: context.secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(product),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: FittedBox(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          l10n.addToCart,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedCategory(String id, AppLocalizations l10n) {
    switch (id) {
      case 'masonry': return l10n.masonryStructure;
      case 'steel': return l10n.steel;
      case 'openings': return l10n.openingsWoodwork;
      case 'finishing': return l10n.finishingAesthetics;
      case 'utilities': return l10n.utilitiesInstallations;
      default: return id;
    }
  }

  String _getLocalizedSubcategory(String sub, AppLocalizations l10n) {
    switch (sub) {
      case 'All': return l10n.all;
      case 'Bricks': return l10n.bricks;
      case 'Cement': return l10n.cement;
      case 'Sand': return l10n.sand;
      case 'Gitti': return l10n.gitti;
      case 'Murrum': return l10n.murrum;
      case 'Dust': return l10n.dust;
      case 'TMT Rebar': return l10n.tmtRebar;
      case 'Iron': return l10n.iron;
      case 'Frames (Choukhaat)': return l10n.frames;
      case 'Windows (Khidki)': return l10n.windows;
      case 'Grills': return l10n.grills;
      case 'Tiles & Stone': return l10n.tilesStone;
      case 'Paint & Prep': return l10n.paint;
      case 'Ceiling': return l10n.ceiling;
      case 'Plumbing': return l10n.plumbing;
      case 'Sanitary': return l10n.sanitary;
      case 'Electrical': return l10n.electrical;
      case 'Kitchen Essentials': return l10n.kitchenEssentials;
      case 'Solar Panels': return l10n.solarPanels;
      case 'Epoxy': return l10n.epoxy;
      case 'Wallpapers': return l10n.wallpapers;
      default: return sub;
    }
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String sortBy;
  final RangeValues priceRange;
  final List<String> selectedBrands;
  final List<String> allBrands;
  final Function(String, RangeValues, List<String>) onApply;

  const _FilterBottomSheet({
    required this.sortBy,
    required this.priceRange,
    required this.selectedBrands,
    required this.allBrands,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _tempSortBy;
  late RangeValues _tempPriceRange;
  late List<String> _tempSelectedBrands;

  @override
  void initState() {
    super.initState();
    _tempSortBy = widget.sortBy;
    _tempPriceRange = widget.priceRange;
    _tempSelectedBrands = List.from(widget.selectedBrands);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: context.scaffoldColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
      ),
      padding: EdgeInsets.only(
        top: 24.h,
        left: 24.w,
        right: 24.w,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.sortBy, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: context.primaryTextColor)),
              TextButton(
                onPressed: () {
                  setState(() {
                    _tempSortBy = 'Default';
                    _tempPriceRange = const RangeValues(0, 100000);
                    _tempSelectedBrands.clear();
                  });
                },
                child: Text(l10n.clearAll, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          _buildSortOption(l10n.all, 'Default'),
          _buildSortOption(l10n.priceLowToHigh, 'Price: Low to High'),
          _buildSortOption(l10n.priceHighToLow, 'Price: High to Low'),
          
          SizedBox(height: 32.h),
          Text(l10n.priceRangeLabel, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: context.primaryTextColor)),
          SizedBox(height: 8.h),
          RangeSlider(
            values: _tempPriceRange,
            min: 0,
            max: 100000,
            divisions: 100,
            activeColor: AppTheme.primaryBlue,
            inactiveColor: context.borderColor,
            labels: RangeLabels(
              '₹${_tempPriceRange.start.round()}',
              '₹${_tempPriceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _tempPriceRange = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹${_tempPriceRange.start.round()}', style: TextStyle(color: context.secondaryTextColor, fontWeight: FontWeight.bold, fontSize: 12.sp)),
              Text('₹${_tempPriceRange.end.round()}+', style: TextStyle(color: context.secondaryTextColor, fontWeight: FontWeight.bold, fontSize: 12.sp)),
            ],
          ),

          SizedBox(height: 32.h),
          Text(l10n.brands, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: context.primaryTextColor)),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.h,
            runSpacing: 8,
            children: widget.allBrands.map((brand) {
              final isSelected = _tempSelectedBrands.contains(brand);
              return FilterChip(
                label: Text(brand, style: TextStyle(fontSize: 12.sp, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500)),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _tempSelectedBrands.add(brand);
                    } else {
                      _tempSelectedBrands.remove(brand);
                    }
                  });
                },
                selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryBlue,
                labelStyle: TextStyle(color: isSelected ? AppTheme.primaryBlue : context.primaryTextColor),
                backgroundColor: context.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                side: BorderSide(color: isSelected ? AppTheme.primaryBlue : context.borderColor),
              );
            }).toList(),
          ),

          SizedBox(height: 48.h),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_tempSortBy, _tempPriceRange, _tempSelectedBrands);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w)),
                elevation: 0,
              ),
              child: Text(l10n.applyFilters, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    bool isSelected = _tempSortBy == value;
    final context = this.context;
    return InkWell(
      onTap: () => setState(() => _tempSortBy = value),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500, color: isSelected ? AppTheme.primaryBlue : context.primaryTextColor)),
            if (isSelected) Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 20.w),
          ],
        ),
      ),
    );
  }
}
