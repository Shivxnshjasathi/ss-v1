import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sampatti_bazar/features/services/domain/cart_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final CartService cart = CartService();
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _allProducts = [
    {
      'id': '1',
      'category': 'Cement',
      'title': 'Ultra-Tough Portland Cement',
      'price': 480.0,
      'unit': 'Bag',
      'image': 'https://images.unsplash.com/photo-1590494056253-ab4fc64fbe3d?w=400&q=80',
    },
    {
      'id': '2',
      'category': 'Steel',
      'title': 'TMT Steel Ribbed Rods (12mm)',
      'price': 62500.0,
      'unit': 'Ton',
      'image': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&q=80',
    },
    {
      'id': '3',
      'category': 'Bricks',
      'title': 'Premium Red Clay Bricks',
      'price': 12.0,
      'unit': 'Piece',
      'image': 'https://images.unsplash.com/photo-1517409419131-ab85ef67d8cd?w=400&q=80',
    },
    {
      'id': '4',
      'category': 'Paint',
      'title': 'Weather-Shield Exterior Paint',
      'price': 3200.0,
      'unit': '20L',
      'image': 'https://images.unsplash.com/photo-1563806967664-cd2deac68d0e?w=400&q=80',
    },
    {
      'id': '5',
      'category': 'Bricks',
      'title': 'Reinforced Concrete Blocks',
      'price': 45.0,
      'unit': 'Piece',
      'image': 'https://images.unsplash.com/photo-1515255452399-55e149c47cbe?w=400&q=80',
    },
    {
      'id': '6',
      'category': 'Basics',
      'title': 'Fine Grade River Sand',
      'price': 4500.0,
      'unit': 'Truck',
      'image': 'https://images.unsplash.com/photo-1565134638781-f2f281e8eaf6?w=400&q=80',
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'All') return _allProducts;
    return _allProducts.where((p) => p['category'] == _selectedCategory).toList();
  }

  String _formatCurrency(double amount) {
    String text = amount.toStringAsFixed(0);
    text = text.replaceAllMapped(RegExp(r'(\d)(?=(\d\d)+\d$)'), (Match m) => '${m[1]},');
    return '₹$text';
  }

  void _addToCart(String id, String category, String title, double price, String unit, String image) {
    cart.addItem(CartItem(
      id: id,
      category: category,
      title: title,
      price: price,
      unit: unit,
      image: image,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title added to cart!'),
        backgroundColor: const Color(0xFF1E60FF),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () => context.push('/services/marketplace/cart'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 16),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text('Marketplace', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 18)),
        actions: [
          ListenableBuilder(
            listenable: cart,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
                    onPressed: () => context.push('/services/marketplace/cart'),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.filter_list, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  _buildCategoryChip('All'),
                  _buildCategoryChip('Cement'),
                  _buildCategoryChip('Steel'),
                  _buildCategoryChip('Bricks'),
                  _buildCategoryChip('Paint'),
                  _buildCategoryChip('Basics'),
                ],
              ),
            ),
            
            // Bulk Orders Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBFC),
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('BULK ORDERS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                        SizedBox(height: 4),
                        Text('Flat 15% off on construction steel', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.arrow_forward, size: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Grid
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('No products found for this category.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return _buildProductCard(
                    item['id'],
                    item['category'].toString().toUpperCase(),
                    item['title'],
                    item['price'],
                    item['unit'],
                    item['image'],
                  );
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E60FF) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? const Color(0xFF1E60FF) : Colors.grey.shade300),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(String id, String category, String title, double price, String unit, String image) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(_formatCurrency(price), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(width: 4),
                      Flexible(child: Text('/ $unit', style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(id, category, title, price, unit, image),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E60FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
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
}
