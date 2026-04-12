import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(l10n),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(l10n),
                _buildCategorySection(l10n),
                if (_selectedCategoryId != 'all' && _searchQuery.isEmpty) _buildSubcategorySection(l10n),
                _buildProductHeader(l10n, filtered.length),
              ],
            ),
          ),
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
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
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = filtered[index];
                    return _buildProductCard(product, l10n);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 32.h)),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 100,
      backgroundColor: context.scaffoldColor,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppTheme.cyanAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.w),
          ),
          child: Icon(Icons.arrow_back_ios_new, color: context.iconColor, size: 16.w),
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 56.w, bottom: 16.h),
        title: Text(l10n.marketplace, style: TextStyle(fontWeight: FontWeight.w900, color: context.primaryTextColor, fontSize: 18.sp)),
      ),
      actions: [
        ListenableBuilder(
          listenable: cart,
          builder: (context, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_bag_outlined, color: context.iconColor),
                  onPressed: () => context.push('/services/marketplace/cart'),
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 6.w,
                    top: 6.h,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.all(16.0.w),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: "Search materials, brands...",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
            prefixIcon: Icon(Icons.search, color: AppTheme.primaryBlue),
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
                          color: isSelected ? AppTheme.primaryBlue : context.cardColor,
                          borderRadius: BorderRadius.circular(20.w),
                          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : [],
                          border: Border.all(color: isSelected ? Colors.transparent : context.borderColor),
                        ),
                        child: Icon(icon, color: isSelected ? Colors.white : context.iconColor, size: 24.w),
                      ),
                      SizedBox(height: 8.h),
                      Text(name, style: TextStyle(fontSize: 10.sp, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500, color: isSelected ? AppTheme.primaryBlue : context.primaryTextColor)),
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
            child: ChoiceChip(
              label: Text(_getLocalizedSubcategory(sub, l10n), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold)),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedSubcategory = sub),
              selectedColor: AppTheme.primaryBlue,
              labelStyle: TextStyle(color: isSelected ? Colors.white : context.primaryTextColor),
              backgroundColor: context.cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.w)),
              side: BorderSide(color: isSelected ? Colors.transparent : context.borderColor),
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
          Text("Showing $count products", style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.grey)),
          GestureDetector(
            onTap: () => _showFilterSheet(l10n),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(8.w),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, size: 16.w, color: context.iconColor),
                  SizedBox(width: 4.w),
                  Text("Filter", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: context.iconColor)),
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
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 10,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(product.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (product.brand != null)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                      child: Text(product.brand!, style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 11,
            child: Padding(
              padding: EdgeInsets.all(12.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.subcategory.toUpperCase(), style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue, letterSpacing: 0.5)),
                      SizedBox(height: 4.h),
                      Text(product.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp, height: 1.2.h, color: context.primaryTextColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(_formatCurrency(product.price), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: context.primaryTextColor)),
                      SizedBox(width: 4.w),
                      Flexible(child: Text('/ ${product.unit}', style: TextStyle(fontSize: 10.sp, color: context.secondaryTextColor), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 38.h,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(product),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                        elevation: 0,
                      ),
                      child: Text(l10n.addToCart, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp, color: Colors.white)),
                    ),
                  ),
                ],
              ),
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
