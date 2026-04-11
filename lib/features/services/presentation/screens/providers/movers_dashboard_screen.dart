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
import 'package:sampatti_bazar/core/utils/responsive.dart';

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
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.w)),
        ),
        padding: EdgeInsets.all(24.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w, 
                  height: 4.h, 
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3), 
                    borderRadius: BorderRadius.circular(2.w)
                  )
                )
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Movers Request Details', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24.sp)),
                         SizedBox(height: 8.h),
                         Text('Review transit route and update final pricing quote.', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  if (lead.userContact.isNotEmpty)
                    IconButton.filled(
                      onPressed: () => launchUrl(Uri.parse('tel:${lead.userContact}')),
                      icon: Icon(Icons.phone, size: 20.w),
                      style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                    ),
                ],
              ),
              SizedBox(height: 32.h),
              
              _buildReadOnlyForm(context, 'CLIENT NAME', lead.userName),
              SizedBox(height: 20.h),
              _buildReadOnlyForm(context, 'CONTACT NUMBER', lead.userContact),
              SizedBox(height: 20.h),
              
              _buildReadOnlyForm(context, 'PICKUP & DROP', '${lead.details['pickupLocation']} ➔ ${lead.details['dropLocation']}'),
              SizedBox(height: 20.h),
              
              Row(
                children: [
                  Expanded(child: _buildReadOnlyForm(context, 'PROPERTY SIZE', lead.details['propertySize'] ?? 'N/A')),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildReadOnlyForm(context, 'PACKING', lead.details['includePacking'] == true ? 'Included' : 'None')),
                ],
              ),
              SizedBox(height: 20.h),

              Row(
                children: [
                  Expanded(child: _buildReadOnlyForm(context, 'DISTANCE', '${lead.details['distance']} km')),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildReadOnlyForm(context, 'EST. QUOTE', '₹${lead.details['estimatedQuote'] ?? '0'}')),
                ],
              ),
              SizedBox(height: 20.h),
              
              if (lead.details['finalQuote'] != null)
                _buildReadOnlyForm(context, 'CURRENT FINAL QUOTE', '₹${lead.details['finalQuote']}', isHighlight: true),
                
              SizedBox(height: 20.h),
              _buildStatusPicker(context, lead),
              SizedBox(height: 32.h),
              
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w)),
                    elevation: 0,
                  ),
                  child: Text('DONE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5, fontSize: 14.sp)),
                ),
              ),
              SizedBox(height: 24.h),
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
        Text('UPDATE STATUS & QUOTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp, color: Colors.grey, letterSpacing: 0.5)),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3), width: 1.5.w),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: statuses.contains(lead.status) ? lead.status : 'Pending',
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryBlue),
              items: statuses.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp, color: AppTheme.primaryBlue)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.w)),
        title: const Text('Set Final Quote', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter the final agreed price for this transit.', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            SizedBox(height: 16.h),
            TextField(
              controller: quoteController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                prefixText: '₹ ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w)),
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
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp, color: isHighlight ? AppTheme.primaryBlue : Colors.grey, letterSpacing: 0.5)),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isHighlight ? AppTheme.primaryBlue.withValues(alpha: 0.1) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(color: isHighlight ? AppTheme.primaryBlue : Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: isHighlight ? AppTheme.primaryBlue : Theme.of(context).textTheme.bodyLarge?.color)),
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
        title: Text(l10n.moversDashboard, style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900, fontSize: 18.sp)),
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
            padding: EdgeInsets.all(24.w),
            itemCount: leads.length,
            itemBuilder: (context, index) {
              final lead = leads[index];
              final statusColor = _getStatusColor(lead.status);
              
              return Container(
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(24.w),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                  border: Border.all(color: context.borderColor.withValues(alpha: 0.5)),
                ),
                child: InkWell(
                  onTap: () => _showLeadDetailsBottomSheet(lead),
                  borderRadius: BorderRadius.circular(24.w),
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.w),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 6.w, height: 6.h, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                                  SizedBox(width: 8.w),
                                  Text(lead.status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 10.sp, letterSpacing: 0.5)),
                                ],
                              ),
                            ),
                            Text(timeago.format(lead.createdAt), style: TextStyle(color: context.secondaryTextColor, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Text('${lead.details['pickupLocation']} ➔ ${lead.details['dropLocation']}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: context.primaryTextColor, letterSpacing: -0.5), maxLines: 2, overflow: TextOverflow.ellipsis),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: 14.w, color: AppTheme.primaryBlue),
                            SizedBox(width: 6.w),
                            Text(lead.userName, style: TextStyle(color: context.primaryTextColor, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                            SizedBox(width: 12.w),
                            Icon(Icons.social_distance_outlined, size: 14.w, color: Colors.green),
                            SizedBox(width: 4.w),
                            Text('${lead.details['distance']} km', style: TextStyle(color: Colors.green, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(child: Text('Size: ${lead.details['propertySize']}', style: TextStyle(color: context.secondaryTextColor, fontSize: 12.sp, height: 1.5.h))),
                            Text(
                              lead.details['finalQuote'] != null ? 'Quote: ₹${lead.details['finalQuote']}' : 'Est: ₹${lead.details['estimatedQuote']}', 
                              style: TextStyle(color: lead.details['finalQuote'] != null ? AppTheme.primaryBlue : Colors.grey, fontSize: 12.sp, fontWeight: FontWeight.w900)
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
