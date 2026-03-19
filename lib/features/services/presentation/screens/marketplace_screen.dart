import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E60FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text('Marketplace', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                  _buildCategoryChip('All', true),
                  _buildCategoryChip('Cement', false),
                  _buildCategoryChip('Steel', false),
                  _buildCategoryChip('Bricks', false),
                  _buildCategoryChip('Paint', false),
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.65,
              children: [
                _buildProductCard('CEMENT', 'Ultra-Tough Portland Cement', '₹480', 'Bag', 'https://images.unsplash.com/photo-1590494056253-ab4fc64fbe3d?w=400&q=80'),
                _buildProductCard('STEEL', 'TMT Steel Ribbed Rods (12mm)', '₹62,500', 'Ton', 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400&q=80'),
                _buildProductCard('BRICKS', 'Premium Red Clay Bricks', '₹12', 'Piece', 'https://images.unsplash.com/photo-1517409419131-ab85ef67d8cd?w=400&q=80'),
                _buildProductCard('PAINTS', 'Weather-Shield Exterior Paint', '₹3,200', '20L', 'https://images.unsplash.com/photo-1563806967664-cd2deac68d0e?w=400&q=80'),
                _buildProductCard('BRICKS', 'Reinforced Concrete Blocks', '₹45', 'Piece', 'https://images.unsplash.com/photo-1515255452399-55e149c47cbe?w=400&q=80'),
                _buildProductCard('BASICS', 'Fine Grade River Sand', '₹4,500', 'Truck', 'https://images.unsplash.com/photo-1565134638781-f2f281e8eaf6?w=400&q=80'),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
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
    );
  }

  Widget _buildProductCard(String category, String title, String price, String unit, String image) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                      Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(width: 4),
                      Text('/ $unit', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E60FF),
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: const Text('Get Quote', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
