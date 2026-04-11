import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/services/data/marketplace_repository.dart';
import 'package:sampatti_bazar/features/services/domain/marketplace_item_model.dart';
import 'package:uuid/uuid.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class MarketplaceVendorScreen extends ConsumerStatefulWidget {
  const MarketplaceVendorScreen({super.key});

  @override
  ConsumerState<MarketplaceVendorScreen> createState() => _MarketplaceVendorScreenState();
}

class _MarketplaceVendorScreenState extends ConsumerState<MarketplaceVendorScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _showAddItemModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: context.scaffoldColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('List New Item', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: context.primaryTextColor)),
              SizedBox(height: 24.h),
              _buildTextField('ITEM NAME', 'e.g. Ambuja Cement', controller: _nameController),
              SizedBox(height: 16.h),
              _buildTextField('CATEGORY', 'e.g. Cement, Steel, Sand', controller: _categoryController),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(child: _buildTextField('PRICE (₹)', '0.00', keyboardType: TextInputType.number, controller: _priceController)),
                  SizedBox(width: 16.w),
                  Expanded(child: _buildTextField('UNIT', 'e.g. per bag, ton', controller: _unitController)),
                ],
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: _publishItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                  ),
                  child: Text('Publish Item', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp)),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _publishItem() async {
    final userAsync = ref.read(currentUserDataProvider);
    final user = userAsync.value;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all details')));
      return;
    }

    try {
      final item = MarketplaceItemModel(
        id: const Uuid().v4(),
        vendorId: user.uid,
        name: _nameController.text,
        category: _categoryController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        unit: _unitController.text,
        status: 'In Stock',
        sales: 0,
        image: 'https://images.unsplash.com/photo-1590494056253-ab4fc64fbe3d?w=400&q=80', // Default image
        createdAt: DateTime.now(),
      );

      await ref.read(marketplaceRepositoryProvider).addItem(item);
      
      if (!mounted) return;
      context.pop();
      _nameController.clear();
      _categoryController.clear();
      _priceController.clear();
      _unitController.clear();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item listed successfully!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _buildTextField(String label, String hint, {TextInputType keyboardType = TextInputType.text, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp, color: Colors.grey, letterSpacing: 0.5)),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);
    final user = userAsync.value;
    
    // We'll watch the actual inventory from Firestore
    final inventoryAsync = user != null 
        ? ref.watch(vendorMarketplaceItemsProvider(user.uid))
        : const AsyncValue<List<MarketplaceItemModel>>.data([]);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text('Vendor Inventory', style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900)),
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: context.iconColor), 
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
              await ref.read(userRepositoryProvider).clearCache();
              if (context.mounted) context.go('/login');
            }
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemModal,
        backgroundColor: AppTheme.primaryBlue,
        icon: Icon(Icons.add, color: Colors.white),
        label: const Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ),
      body: inventoryAsync.when(
        data: (items) => Padding(
          padding: EdgeInsets.all(24.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Listed Products', style: Theme.of(context).textTheme.displayMedium),
              SizedBox(height: 8.h),
              Text('Items visible to consumers in the Marketplace.', style: TextStyle(color: context.secondaryTextColor, fontSize: 13.sp)),
              SizedBox(height: 24.h),
              Expanded(
                child: items.isEmpty 
                  ? Center(child: Text('No items listed yet.', style: TextStyle(color: context.secondaryTextColor)))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(16.w),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: item.status == 'In Stock'
                                        ? Colors.green.withValues(alpha: 0.1) 
                                        : Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8.w),
                                    ),
                                    child: Text(
                                      item.status.toUpperCase(), 
                                      style: TextStyle(
                                        color: item.status == 'In Stock' ? Colors.green : Colors.red, 
                                        fontWeight: FontWeight.w900, 
                                        fontSize: 10.sp
                                      )
                                    ),
                                  ),
                                  Text(item.category, style: TextStyle(color: context.secondaryTextColor, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Text(item.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp)),
                              SizedBox(height: 4.h),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹${item.price}', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 18.sp, fontWeight: FontWeight.w900)),
                                  SizedBox(width: 4.w),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 3.0.h),
                                    child: Text(item.unit, style: TextStyle(color: context.secondaryTextColor, fontSize: 11.sp, fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Divider(color: context.borderColor),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined, size: 20.w), 
                                        onPressed: () {}, 
                                        color: Colors.grey
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline, size: 20.w), 
                                        onPressed: () async {
                                          await ref.read(marketplaceRepositoryProvider).deleteItem(item.id);
                                        }, 
                                        color: Colors.red.shade300
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
