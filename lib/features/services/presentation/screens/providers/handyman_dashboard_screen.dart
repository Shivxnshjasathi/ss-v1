import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/chat/data/chat_repository.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sampatti_bazar/core/widgets/google_map_widget.dart';

class HandymanDashboardScreen extends ConsumerStatefulWidget {
  const HandymanDashboardScreen({super.key});

  @override
  ConsumerState<HandymanDashboardScreen> createState() => _HandymanDashboardScreenState();
}

class _HandymanDashboardScreenState extends ConsumerState<HandymanDashboardScreen> {
  String _selectedCity = 'All';
  bool _sortByCity = false;
  bool _isCityInitialized = false;

  String _formatLabel(String key) {
    final result = key.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}');
    return result.trim().toUpperCase();
  }

  void _showLeadDetailsBottomSheet(ServiceRequestModel lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 0.85.h * MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.sp)),
        ),
        padding: EdgeInsets.all(24.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2.sp)))),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text('Lead Details', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24.sp)),
                         SizedBox(height: 8.h),
                         Text('Full information submitted by the client.', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  if (lead.userContact.isNotEmpty)
                    IconButton.filled(
                      onPressed: () => launchUrl(Uri.parse('tel:${lead.userContact}')),
                      icon: Icon(Icons.phone, size: 20.sp),
                      style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                    ),
                ],
              ),
              SizedBox(height: 32.h),
              
              _buildReadOnlyForm(context, 'CLIENT NAME', lead.userName),
              SizedBox(height: 20.h),
              _buildReadOnlyForm(context, 'CONTACT NUMBER', lead.userContact),
              SizedBox(height: 20.h),
              
              // Dynamic fields from details map
              ...lead.details.entries.where((e) => e.value != null && e.value.toString().isNotEmpty).map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: _buildReadOnlyForm(context, _formatLabel(entry.key), entry.value.toString()),
                );
              }),
              
              if (lead.location != null && lead.location!.isNotEmpty) ...[
                _buildReadOnlyForm(context, 'LOCATION', lead.location!),
                SizedBox(height: 16.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.sp),
                  child: GoogleMapWidget(
                    latitude: lead.latitude,
                    longitude: lead.longitude,
                    address: lead.location!,
                  ),
                ),
              ],
                
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
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
        Text('UPDATE STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp, color: Colors.grey, letterSpacing: 0.5)),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.sp),
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
                  await ref.read(serviceRequestRepositoryProvider).updateRequestStatus(lead.id, newValue);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyForm(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp, color: Colors.grey, letterSpacing: 0.5)),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCityInitialized) {
      final user = ref.watch(currentUserDataProvider).value;
      if (user != null && user.location != null && user.location!.isNotEmpty) {
        _selectedCity = user.location!;
        _isCityInitialized = true;
      }
    }
    final leadsAsync = ref.watch(handymanLeadsProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text('Provider Dashboard', style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900, fontSize: 18.sp)),
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
          // Apply Filter
          var filteredList = _selectedCity == 'All' 
              ? List<ServiceRequestModel>.from(leads)
              : leads.where((l) => (l.location?.toLowerCase() ?? '') == _selectedCity.toLowerCase()).toList();

          // Apply Sort
          if (_sortByCity) {
            filteredList.sort((a, b) => (a.location ?? '').compareTo(b.location ?? ''));
          }

          return Padding(
            padding: EdgeInsets.all(24.0.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Handyman Leads', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24.sp)),
                        SizedBox(height: 4.h),
                        Text(_selectedCity == 'All' ? 'Showing All Cities' : 'Filtered: $_selectedCity', 
                             style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                      ],
                    ),
                    IconButton(
                      icon: Icon(_sortByCity ? Icons.sort_by_alpha : Icons.access_time_filled_outlined, color: AppTheme.primaryBlue, size: 20.sp),
                      onPressed: () => setState(() => _sortByCity = !_sortByCity),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildFilterBar(leads),
                SizedBox(height: 24.h),
                Expanded(
                  child: filteredList.isEmpty 
                    ? Center(child: Text('No leads found for chosen filters.', style: TextStyle(color: context.secondaryTextColor)))
                    : ListView.builder(
                        padding: EdgeInsets.only(bottom: 100.h),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final lead = filteredList[index];
                          final statusColor = _getStatusColor(lead.status);
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: 20.h),
                            decoration: BoxDecoration(
                              color: context.cardColor,
                              borderRadius: BorderRadius.circular(24.sp),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8)),
                              ],
                              border: Border.all(color: context.borderColor.withValues(alpha: 0.5)),
                            ),
                            child: InkWell(
                              onTap: () => _showLeadDetailsBottomSheet(lead),
                              borderRadius: BorderRadius.circular(24.sp),
                              child: Padding(
                                padding: EdgeInsets.all(20.sp),
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
                                            borderRadius: BorderRadius.circular(12.sp),
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
                                    Text(lead.category, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp, color: context.primaryTextColor, letterSpacing: -0.5)),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline, size: 14.sp, color: AppTheme.primaryBlue),
                                        SizedBox(width: 6.w),
                                        Text(lead.userName, style: TextStyle(color: context.primaryTextColor, fontSize: 13.sp, fontWeight: FontWeight.w600)),
                                        SizedBox(width: 12.w),
                                        if (lead.location != null) ...[
                                          Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.green),
                                          SizedBox(width: 4.w),
                                          Text(lead.location!, style: TextStyle(color: Colors.green, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                        ],
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(lead.details['notes'] ?? lead.category, style: TextStyle(color: context.secondaryTextColor, fontSize: 12.sp, height: 1.5.h), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    SizedBox(height: 20.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => launchUrl(Uri.parse('tel:${lead.userContact}')),
                                            icon: Icon(Icons.phone, size: 16.sp),
                                            label: Text('CALL CLIENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.sp, letterSpacing: 0.5)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                              foregroundColor: AppTheme.primaryBlue,
                                              elevation: 0,
                                              padding: EdgeInsets.symmetric(vertical: 12.h),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () async {
                                              final userProfile = ref.read(currentUserDataProvider).value;
                                              if (userProfile == null) return;
                                              
                                              final chatId = await ref.read(chatRepositoryProvider).startOrGetChat(
                                                userProfile.uid, 
                                                lead.userId,
                                                metadata: {'type': 'service', 'category': lead.category},
                                              );
                                              if (context.mounted) {
                                                context.push('/chats/$chatId');
                                              }
                                            },
                                            icon: Icon(Icons.message_outlined, size: 16.sp),
                                            label: Text('MESSAGE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.sp, letterSpacing: 0.5)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.primaryBlue,
                                              foregroundColor: Colors.white,
                                              elevation: 4,
                                              padding: EdgeInsets.symmetric(vertical: 12.h),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ],
            ),
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

  Widget _buildFilterBar(List<ServiceRequestModel> leads) {
    final cities = ['All', ...leads.map((l) => l.location).whereType<String>().toSet()];
    cities.sort();

    if (cities.length <= 1) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: cities.map((city) {
          final isSelected = _selectedCity == city;
          return Padding(
            padding: EdgeInsets.only(right: 8.0.w),
            child: ChoiceChip(
              label: Text(city),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCity = city);
              },
              selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
              backgroundColor: context.cardColor,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : context.secondaryTextColor,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                fontSize: 12.sp,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.w),
                side: BorderSide(color: isSelected ? AppTheme.primaryBlue : context.borderColor),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
