import 'package:flutter/material.dart';
import 'package:sampatti_bazar/shared/widgets/app_card.dart';
import 'package:sampatti_bazar/shared/widgets/primary_button.dart';

class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text('Construction Materials')),
       body: SingleChildScrollView(
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
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildMaterialCard(context, 'Cement (ACC, UltraTech)', 'Starting ₹350/bag', Icons.category),
                  _buildMaterialCard(context, 'TMT Steel Bars', 'Starting ₹65/kg', Icons.horizontal_rule),
                  _buildMaterialCard(context, 'Red Bricks', 'Starting ₹7/piece', Icons.grid_on),
                  _buildMaterialCard(context, 'Italian Marble', 'Starting ₹250/sqft', Icons.layers),
                  _buildMaterialCard(context, 'Paints', 'Starting ₹150/L', Icons.format_paint),
                  _buildMaterialCard(context, 'Furniture Sets', 'Wholesale Catalog', Icons.weekend),
                ],
              ),
           ],
         ),
       ),
     );
  }

  Widget _buildMaterialCard(BuildContext context, String title, String price, IconData icon) {
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
              child: Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2),
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
