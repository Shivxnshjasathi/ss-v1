import 'package:flutter/material.dart';
import 'package:sampatti_bazar/shared/widgets/app_card.dart';
import 'package:sampatti_bazar/shared/widgets/primary_button.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text('Construction Materials')),
       body: CustomScrollView(
         slivers: [
           SliverToBoxAdapter(
             child: Padding(
               padding: const EdgeInsets.all(16.0),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(
                      'Wholesale Materials & Furniture',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get bulk quotes for cement, TMT bars, bricks, and imported furniture directly from suppliers.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                 ],
               ),
             ),
           ),
           SliverPadding(
             padding: const EdgeInsets.symmetric(horizontal: 16.0),
             sliver: SliverGrid(
               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                 crossAxisCount: 2,
                 mainAxisSpacing: 16,
                 crossAxisSpacing: 16,
                 childAspectRatio: 0.65,
               ),
               delegate: SliverChildListDelegate([
                 _buildMaterialCard(context, 'Premium Cement', 'Starting ₹350/bag', 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&q=80'),
                 _buildMaterialCard(context, 'TMT Steel Bars', 'Starting ₹65/kg', 'https://images.unsplash.com/photo-1541888081628-912fcf45ee39?w=500&q=80'),
                 _buildMaterialCard(context, 'Red Bricks', 'Starting ₹7/piece', 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=500&q=80'),
                 _buildMaterialCard(context, 'Italian Marble', 'Starting ₹250/sqft', 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=500&q=80'),
                 _buildMaterialCard(context, 'Wall Paints', 'Starting ₹150/L', 'https://images.unsplash.com/photo-1562184552-997c461abbe6?w=500&q=80'),
                 _buildMaterialCard(context, 'Living Furniture', 'Wholesale Catalog', 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500&q=80'),
               ]),
             ),
           ),
           const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
         ],
       ),
     );
  }

  Widget _buildMaterialCard(BuildContext context, String title, String price, String imageUrl) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(price, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 8),
          PrimaryButton(
            text: 'Get Quote',
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Quote requested for $title')),
               );
            },
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
