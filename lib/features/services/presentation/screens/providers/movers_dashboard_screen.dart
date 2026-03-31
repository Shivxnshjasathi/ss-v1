import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class MoversDashboardScreen extends ConsumerStatefulWidget {
  const MoversDashboardScreen({super.key});

  @override
  ConsumerState<MoversDashboardScreen> createState() => _MoversDashboardScreenState();
}

class _MoversDashboardScreenState extends ConsumerState<MoversDashboardScreen> {
  
  void _showLeadDetailsBottomSheet(ServiceRequestModel lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, 
                  height: 4, 
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3), 
                    borderRadius: BorderRadius.circular(2)
                  )
                )
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Movers Request Details', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24)),
                         const SizedBox(height: 8),
                         const Text('Review transit route and update final pricing quote.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  if (lead.userContact.isNotEmpty)
                    IconButton.filled(
                      onPressed: () => launchUrl(Uri.parse('tel:${lead.userContact}')),
                      icon: const Icon(Icons.phone, size: 20),
                      style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              
              _buildReadOnlyForm(context, 'CLIENT NAME', lead.userName),
              const SizedBox(height: 20),
              _buildReadOnlyForm(context, 'CONTACT NUMBER', lead.userContact),
              const SizedBox(height: 20),
              
              _buildReadOnlyForm(context, 'PICKUP & DROP', '${lead.details['pickupLocation']} ➔ ${lead.details['dropLocation']}'),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(child: _buildReadOnlyForm(context, 'PROPERTY SIZE', lead.details['propertySize'] ?? 'N/A')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildReadOnlyForm(context, 'PACKING', lead.details['includePacking'] == true ? 'Included' : 'None')),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _buildReadOnlyForm(context, 'DISTANCE', '${lead.details['distance']} km')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildReadOnlyForm(context, 'EST. QUOTE', '₹${lead.details['estimatedQuote'] ?? '0'}')),
                ],
              ),
              const SizedBox(height: 20),
              
              if (lead.details['finalQuote'] != null)
                _buildReadOnlyForm(context, 'CURRENT FINAL QUOTE', '₹${lead.details['finalQuote']}', isHighlight: true),
                
              const SizedBox(height: 20),
              _buildStatusPicker(context, lead),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPicker(BuildContext context, ServiceRequestModel lead) {
    final statuses = ['Pending', 'Accepted', 'In Progress', 'Completed', 'Cancelled'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('UPDATE STATUS & QUOTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: statuses.contains(lead.status) ? lead.status : 'Pending',
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
              items: statuses.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primaryBlue)),
                );
              }).toList(),
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  if (newValue == 'Accepted' || newValue == 'In Progress') {
                    // Ask for Quote
                    _showQuoteDialog(context, lead, newValue);
                  } else {
                    await ref.read(serviceRequestRepositoryProvider).updateRequestStatus(lead.id, newValue);
                    if (context.mounted) Navigator.pop(context);
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showQuoteDialog(BuildContext context, ServiceRequestModel lead, String status) {
    final quoteController = TextEditingController(text: lead.details['finalQuote']?.toString() ?? lead.details['estimatedQuote']?.toString() ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Set Final Quote', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the final agreed price for this transit.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: quoteController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                prefixText: '₹ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              String finalQuote = quoteController.text;
              if (finalQuote.isNotEmpty) {
                final newDetails = Map<String, dynamic>.from(lead.details);
                newDetails['finalQuote'] = int.parse(finalQuote);
                await ref.read(serviceRequestRepositoryProvider).updateRequestDetails(lead.id, newDetails);
              }
              await ref.read(serviceRequestRepositoryProvider).updateRequestStatus(lead.id, status);
              if (ctx.mounted) Navigator.pop(ctx); // pop dialog
              if (context.mounted) Navigator.pop(context); // pop bottomsheet
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyForm(BuildContext context, String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isHighlight ? AppTheme.primaryBlue : Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isHighlight ? AppTheme.primaryBlue.withValues(alpha: 0.1) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isHighlight ? AppTheme.primaryBlue : Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isHighlight ? AppTheme.primaryBlue : Theme.of(context).textTheme.bodyLarge?.color)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final leadsAsync = ref.watch(moversLeadsProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.moversDashboard, style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900, fontSize: 18)),
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
      body: leadsAsync.when(
        data: (leads) {
          if (leads.isEmpty) {
            return const Center(child: Text('No moving requests yet.', style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: leads.length,
            itemBuilder: (context, index) {
              final lead = leads[index];
              final statusColor = _getStatusColor(lead.status);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                  border: Border.all(color: context.borderColor.withValues(alpha: 0.5)),
                ),
                child: InkWell(
                  onTap: () => _showLeadDetailsBottomSheet(lead),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  Text(lead.status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
                                ],
                              ),
                            ),
                            Text(timeago.format(lead.createdAt), style: TextStyle(color: context.secondaryTextColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('${lead.details['pickupLocation']} ➔ ${lead.details['dropLocation']}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: context.primaryTextColor, letterSpacing: -0.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: AppTheme.primaryBlue),
                            const SizedBox(width: 6),
                            Text(lead.userName, style: TextStyle(color: context.primaryTextColor, fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 12),
                            const Icon(Icons.social_distance_outlined, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text('${lead.details['distance']} km', style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: Text('Size: ${lead.details['propertySize']}', style: TextStyle(color: context.secondaryTextColor, fontSize: 12, height: 1.5))),
                            Text(
                              lead.details['finalQuote'] != null ? 'Quote: ₹${lead.details['finalQuote']}' : 'Est: ₹${lead.details['estimatedQuote']}', 
                              style: TextStyle(color: lead.details['finalQuote'] != null ? AppTheme.primaryBlue : Colors.grey, fontSize: 12, fontWeight: FontWeight.w900)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted': return Colors.blue;
      case 'in progress': return AppTheme.primaryBlue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
  }
}
