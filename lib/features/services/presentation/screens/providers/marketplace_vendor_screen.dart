import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/services/data/marketplace_repository.dart';
import 'package:sampatti_bazar/features/services/domain/marketplace_item_model.dart';
import 'package:uuid/uuid.dart';

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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('List New Item', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.primaryTextColor)),
              const SizedBox(height: 24),
              _buildTextField('ITEM NAME', 'e.g. Ambuja Cement', controller: _nameController),
              const SizedBox(height: 16),
              _buildTextField('CATEGORY', 'e.g. Cement, Steel, Sand', controller: _categoryController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('PRICE (₹)', '0.00', keyboardType: TextInputType.number, controller: _priceController)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('UNIT', 'e.g. per bag, ton', controller: _unitController)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _publishItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Publish Item', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 16),
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
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ),
      body: inventoryAsync.when(
        data: (items) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Listed Products', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text('Items visible to consumers in the Marketplace.', style: TextStyle(color: context.secondaryTextColor, fontSize: 13)),
              const SizedBox(height: 24),
              Expanded(
                child: items.isEmpty 
                  ? Center(child: Text('No items listed yet.', style: TextStyle(color: context.secondaryTextColor)))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: item.status == 'In Stock'
                                        ? Colors.green.withValues(alpha: 0.1) 
                                        : Colors.red.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.status.toUpperCase(), 
                                      style: TextStyle(
                                        color: item.status == 'In Stock' ? Colors.green : Colors.red, 
                                        fontWeight: FontWeight.w900, 
                                        fontSize: 10
                                      )
                                    ),
                                  ),
                                  Text(item.category, style: TextStyle(color: context.secondaryTextColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('₹${item.price}', style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 18, fontWeight: FontWeight.w900)),
                                  const SizedBox(width: 4),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3.0),
                                    child: Text(item.unit, style: TextStyle(color: context.secondaryTextColor, fontSize: 11, fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Divider(color: context.borderColor),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 20), 
                                        onPressed: () {}, 
                                        color: Colors.grey
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20), 
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
