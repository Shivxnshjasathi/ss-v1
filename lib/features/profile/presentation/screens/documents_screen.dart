import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';

import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myLegalDocumentsProvider = StreamProvider.autoDispose((ref) {
  final user = ref.watch(currentUserDataProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(serviceRequestRepositoryProvider).streamUserRequests(user.uid);
});

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  final List<Map<String, String>> _docs = const [
    {'name': 'Aadhar Card', 'type': 'Identity', 'date': 'Oct 12, 2025'},
    {'name': 'Property registry', 'type': 'Property', 'date': 'Jan 05, 2026'},
    {'name': 'Electricity Bill', 'type': 'Address Proof', 'date': 'Mar 20, 2026'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final legalDocsStream = ref.watch(myLegalDocumentsProvider);

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
      body: legalDocsStream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (requests) {
          final dynDocs = (requests as List<dynamic>).where((r) => r.category == 'RentAgreement' && (r.status.toLowerCase() == 'completed' || r.status.toLowerCase() == 'fully executed')).toList();
          final allItems = [
            ...dynDocs.map((r) => {
              'name': 'Legal Rent Agreement',
              'type': 'Contract',
              'date': 'ID: ${r.id}',
              'isDynamic': true,
            }),
            ..._docs.map((d) => {...d, 'isDynamic': false}),
          ];

          if (allItems.isEmpty) {
            return Center(child: Text('No documents uploaded.', style: TextStyle(color: context.secondaryTextColor)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              final doc = allItems[index] as Map<String, dynamic>;
              final isDyn = doc['isDynamic'] == true;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDyn ? AppTheme.primaryBlue.withValues(alpha: 0.3) : context.borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDyn ? Colors.red.withValues(alpha: 0.1) : AppTheme.primaryBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(isDyn ? Icons.picture_as_pdf : Icons.description, color: isDyn ? Colors.red : AppTheme.primaryBlue, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doc['name'], style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: context.primaryTextColor)),
                          const SizedBox(height: 4),
                          Text('${doc['type']} • ${doc['date']}', style: TextStyle(color: context.secondaryTextColor, fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.download_rounded, color: isDyn ? Colors.green : AppTheme.primaryBlue, size: 20),
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading ${doc['name']}...')));
                      },
                    ),
                  ],
                ),
              );
            },
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
