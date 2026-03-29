import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  final List<Map<String, String>> _docs = const [
    {'name': 'Aadhar Card', 'type': 'Identity', 'date': 'Oct 12, 2025'},
    {'name': 'Property registry', 'type': 'Property', 'date': 'Jan 05, 2026'},
    {'name': 'Electricity Bill', 'type': 'Address Proof', 'date': 'Mar 20, 2026'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text('My Documents', style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900)),
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: _docs.length,
        itemBuilder: (context, index) {
          final doc = _docs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.description, color: AppTheme.primaryBlue, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc['name']!, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: context.primaryTextColor)),
                      const SizedBox(height: 4),
                      Text('${doc['type']} • ${doc['date']}', style: TextStyle(color: context.secondaryTextColor, fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download_rounded, color: AppTheme.primaryBlue, size: 20),
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('UPLOAD DOCUMENT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5)),
      ),
    );
  }
}
