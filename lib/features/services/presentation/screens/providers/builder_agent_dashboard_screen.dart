import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/chat/data/chat_repository.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

class BuilderAgentDashboardScreen extends ConsumerStatefulWidget {
  const BuilderAgentDashboardScreen({super.key});

  @override
  ConsumerState<BuilderAgentDashboardScreen> createState() => _BuilderAgentDashboardScreenState();
}

class _BuilderAgentDashboardScreenState extends ConsumerState<BuilderAgentDashboardScreen> {
  int _currentIndex = 0;
  PropertyModel? _editingProperty;

  void _onEdit(PropertyModel property) {
    setState(() {
      _editingProperty = property;
      _currentIndex = 0; // Switch to Add Listing tab
    });
  }

  void _onDoneEditing() {
    setState(() {
      _editingProperty = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text('Agent Portal', style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900, fontSize: 18.sp)),
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
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _ListingFormView(
            propertyToEdit: _editingProperty,
            onCancelEdit: _onDoneEditing,
            onSuccess: _onDoneEditing,
          ),
          _MyListingsView(onEdit: _onEdit),
          const _VisitorRequestsView(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark 
                 ? Colors.black.withValues(alpha: 0.3) 
                 : Colors.black.withValues(alpha: 0.05), 
              blurRadius: 10, 
              offset: const Offset(0, -5))
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != 0) _onDoneEditing();
            setState(() => _currentIndex = index);
          },
          backgroundColor: context.scaffoldColor,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: Colors.grey,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.add_business_outlined), activeIcon: Icon(Icons.add_business), label: 'Add Listing'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'My Listings'),
            BottomNavigationBarItem(icon: Icon(Icons.visibility_outlined), activeIcon: Icon(Icons.visibility), label: 'Visitor Requests'),
          ],
        ),
      ),
    );
  }
}

class _ListingFormView extends ConsumerStatefulWidget {
  final PropertyModel? propertyToEdit;
  final VoidCallback? onCancelEdit;
  final VoidCallback? onSuccess;

  const _ListingFormView({this.propertyToEdit, this.onCancelEdit, this.onSuccess});

  @override
  ConsumerState<_ListingFormView> createState() => _ListingFormViewState();
}

class _ListingFormViewState extends ConsumerState<_ListingFormView> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillData();
  }

  @override
  void didUpdateWidget(_ListingFormView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.propertyToEdit != oldWidget.propertyToEdit) {
      _prefillData();
    }
  }

  void _prefillData() {
    if (widget.propertyToEdit != null) {
      _nameController.text = widget.propertyToEdit!.title;
      _cityController.text = widget.propertyToEdit!.city;
      _addressController.text = widget.propertyToEdit!.location;
      _priceController.text = widget.propertyToEdit!.price.toString();
      _areaController.text = widget.propertyToEdit!.areaSqFt.toString();
      _descriptionController.text = widget.propertyToEdit!.description;
    } else {
      _nameController.clear();
      _cityController.clear();
      _addressController.clear();
      _priceController.clear();
      _areaController.clear();
      _descriptionController.clear();
    }
  }

  Future<void> _submitListing() async {
    final user = ref.read(currentUserDataProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final property = PropertyModel(
        id: widget.propertyToEdit?.id ?? const Uuid().v4(),
        ownerId: user.uid,
        title: _nameController.text,
        description: _descriptionController.text,
        type: widget.propertyToEdit?.type ?? 'Sale',
        propertyType: widget.propertyToEdit?.propertyType ?? 'Apartment',
        price: double.tryParse(_priceController.text) ?? 0.0,
        location: _addressController.text,
        city: _cityController.text,
        bedrooms: widget.propertyToEdit?.bedrooms ?? 2,
        bathrooms: widget.propertyToEdit?.bathrooms ?? 2,
        areaSqFt: double.tryParse(_areaController.text) ?? 0.0,
        imageUrls: widget.propertyToEdit?.imageUrls ?? [],
        createdAt: widget.propertyToEdit?.createdAt ?? DateTime.now(),
      );

      if (widget.propertyToEdit != null) {
        await ref.read(propertyRepositoryProvider).updateProperty(property);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing Updated Successfully!')));
      } else {
        await ref.read(propertyRepositoryProvider).addProperty(property, []);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing Published Successfully!')));
      }
      
      if (mounted) {
        widget.onSuccess?.call();
        _prefillData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.propertyToEdit != null ? 'Edit Property' : 'Publish Property', 
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24.sp)
              ),
              if (widget.propertyToEdit != null)
                TextButton.icon(
                  onPressed: widget.onCancelEdit,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('CANCEL'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text('List new properties directly to the Sampatti feed.', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13.sp)),
          SizedBox(height: 32.h),
          
          _buildFormSection(context, 'PROPERTY NAME', 'e.g. Skyline Apartments', controller: _nameController),
          SizedBox(height: 16.h),
          _buildFormSection(context, 'CITY', 'e.g. Indore', controller: _cityController),
          SizedBox(height: 16.h),
          _buildFormSection(context, 'DETAILED ADDRESS', 'e.g. Plot 43, Scheme 78', controller: _addressController),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildFormSection(context, 'PRICE (₹)', '0.00', controller: _priceController, keyboardType: TextInputType.number)),
              SizedBox(width: 16.w),
              Expanded(child: _buildFormSection(context, 'AREA (SQ.FT)', '0', controller: _areaController, keyboardType: TextInputType.number)),
            ],
          ),
          SizedBox(height: 16.h),
          _buildFormSection(context, 'DESCRIPTION', 'Write a compelling description...', controller: _descriptionController, maxLines: 4),
          SizedBox(height: 32.h),
          
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Column(
              children: [
                Container(padding: EdgeInsets.all(12.sp), decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle, border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))), child: Icon(Icons.add_a_photo_outlined, color: AppTheme.primaryBlue, size: 24.sp)),
                SizedBox(height: 16.h),
                Text('Upload Photos', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp)),
              ],
            ),
          ),
          
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitListing,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(widget.propertyToEdit != null ? 'UPDATE LISTING' : 'PUBLISH LISTING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp, color: Colors.white, letterSpacing: 1)),
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, String label, String hint, {required TextEditingController controller, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp, color: Colors.grey, letterSpacing: 0.5)),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.sp),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.sp), borderSide: BorderSide.none),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _VisitorRequestsView extends ConsumerStatefulWidget {
  const _VisitorRequestsView();

  @override
  ConsumerState<_VisitorRequestsView> createState() => _VisitorRequestsViewState();
}

class _VisitorRequestsViewState extends ConsumerState<_VisitorRequestsView> {
  String _selectedCity = 'All';
  bool _sortByCity = false;
  bool _isCityInitialized = false;

  String _formatLabel(String key) {
    // Convert camelCase to Space Separated Uppercase
    final result = key.replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}');
    return result.trim().toUpperCase();
  }

  Widget _buildStatusPicker(BuildContext context, ServiceRequestModel req) {
    final statuses = ['Pending', 'Approved', 'In Progress', 'Completed', 'Cancelled'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('UPDATE REQUEST STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.sp, color: Colors.grey, letterSpacing: 0.5)),
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
              value: statuses.contains(req.status) ? req.status : 'Pending',
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
                  await ref.read(serviceRequestRepositoryProvider).updateRequestStatus(req.id, newValue);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showRequestDetailsBottomSheet(ServiceRequestModel req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
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
                        Text('Request Details', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24.sp)),
                        SizedBox(height: 8.h),
                        Text('Full information submitted by the client.', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  if (req.userContact.isNotEmpty)
                    IconButton.filled(
                      onPressed: () => launchUrl(Uri.parse('tel:${req.userContact}')),
                      icon: Icon(Icons.phone, size: 20.sp),
                      style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                    ),
                ],
              ),
              SizedBox(height: 32.h),
              
              _buildReadOnlyForm(context, 'CLIENT NAME', req.userName),
              SizedBox(height: 20.h),
              _buildReadOnlyForm(context, 'CONTACT NUMBER', req.userContact),
              SizedBox(height: 20.h),
              
              // Dynamic fields from details map
              ...req.details.entries.where((e) => e.value != null && e.value.toString().isNotEmpty).map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: _buildReadOnlyForm(context, _formatLabel(entry.key), entry.value.toString()),
                );
              }),
              
              if (req.location != null && req.location!.isNotEmpty)
                _buildReadOnlyForm(context, 'LOCATION', req.location!),
                
              SizedBox(height: 20.h),
              _buildStatusPicker(context, req),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': case 'accepted': return Colors.blue;
      case 'in progress': return AppTheme.primaryBlue;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.orange;
    }
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
    final requestsAsync = ref.watch(allSiteVisitsStreamProvider);

    return requestsAsync.when(
      data: (requests) {
        // Apply Filter
        var filteredList = _selectedCity == 'All' 
            ? List<ServiceRequestModel>.from(requests)
            : requests.where((r) => (r.location?.toLowerCase() ?? '') == _selectedCity.toLowerCase()).toList();

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
                children: [
                  Icon(Icons.location_city, color: AppTheme.primaryBlue, size: 28.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Visitor Requests', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24.sp)),
                        Text(_selectedCity == 'All' ? 'Showing All Cities' : 'Filtered: $_selectedCity', 
                             style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(_sortByCity ? Icons.sort_by_alpha : Icons.access_time_filled_outlined, color: AppTheme.primaryBlue, size: 20.sp),
                    onPressed: () => setState(() => _sortByCity = !_sortByCity),
                    tooltip: 'Toggle Sort Order',
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildFilterBar(context, ref, requests),
              SizedBox(height: 24.h),
              Expanded(
                child: filteredList.isEmpty 
                  ? Center(child: Text(_selectedCity == 'All' ? 'No visitor requests found.' : 'No requests in $_selectedCity.', style: TextStyle(color: context.secondaryTextColor)))
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 100.h),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final req = filteredList[index];
                        final statusColor = _getStatusColor(req.status);
                        
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
                            onTap: () => _showRequestDetailsBottomSheet(req),
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
                                            Text(req.status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.w900, fontSize: 10.sp, letterSpacing: 0.5)),
                                          ],
                                        ),
                                      ),
                                      Text(timeago.format(req.createdAt), style: TextStyle(color: context.secondaryTextColor, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(req.details['propertyAddress'] ?? 'Property Visit', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp, color: context.primaryTextColor, letterSpacing: -0.5)),
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14.sp, color: AppTheme.primaryBlue),
                                      SizedBox(width: 4.w),
                                      Text(req.details['preferredTime'] ?? 'TBD', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13.sp)),
                                      SizedBox(width: 12.w),
                                      if (req.location != null) ...[
                                        Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.green),
                                        SizedBox(width: 4.w),
                                        Text(req.location!, style: TextStyle(color: Colors.green, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                      ],
                                    ],
                                  ),
                                  SizedBox(height: 20.h),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10.sp),
                                        decoration: BoxDecoration(color: context.scaffoldColor, shape: BoxShape.circle),
                                        child: Icon(Icons.person_outline, size: 16.sp, color: AppTheme.primaryBlue),
                                      ),
                                      SizedBox(width: 12.w),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(req.userName, style: TextStyle(color: context.primaryTextColor, fontSize: 13.sp, fontWeight: FontWeight.w700)),
                                          Text(req.userContact, style: TextStyle(color: context.secondaryTextColor, fontSize: 11.sp, fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                      const Spacer(),
                                      IconButton.filled(
                                        onPressed: () => launchUrl(Uri.parse('tel:${req.userContact}')),
                                        icon: Icon(Icons.phone, size: 16.sp),
                                        style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1), foregroundColor: AppTheme.primaryBlue),
                                      ),
                                      SizedBox(width: 8.w),
                                      IconButton.filled(
                                        onPressed: () async {
                                          final userProfile = ref.read(currentUserDataProvider).value;
                                          if (userProfile == null) return;
                                          
                                          final chatId = await ref.read(chatRepositoryProvider).startOrGetChat(
                                            userProfile.uid, 
                                            req.userId,
                                            metadata: {'type': 'service', 'category': req.category},
                                          );
                                          if (context.mounted) {
                                            context.push('/chats/$chatId');
                                          }
                                        },
                                        icon: Icon(Icons.message_outlined, size: 16.sp),
                                        style: IconButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
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
    );
  }

  Widget _buildFilterBar(BuildContext context, WidgetRef ref, List<ServiceRequestModel> requests) {
    final cities = ['All', ...requests.map((r) => r.location).whereType<String>().toSet()];
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
              backgroundColor: Theme.of(context).cardColor,
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

class _MyListingsView extends ConsumerWidget {
  final Function(PropertyModel) onEdit;
  const _MyListingsView({required this.onEdit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserDataProvider).value;
    if (user == null) return const Center(child: Text('User not found'));

    final propertiesAsync = ref.watch(propertiesByOwnerProvider(user.uid));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(24.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Listings', style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24.sp)),
              SizedBox(height: 8.h),
              Text('Manage and edit your active property listings.', style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
            ],
          ),
        ),
        Expanded(
          child: propertiesAsync.when(
            data: (properties) {
              if (properties.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48.sp, color: Colors.grey.withValues(alpha: 0.3)),
                      SizedBox(height: 16.h),
                      const Text('You haven\'t listed any properties yet.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final p = properties[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(16.sp),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            color: context.surfaceColor,
                            borderRadius: BorderRadius.circular(12.sp),
                            image: p.imageUrls.isNotEmpty 
                                ? DecorationImage(image: NetworkImage(p.imageUrls.first), fit: BoxFit.cover)
                                : null,
                          ),
                          child: p.imageUrls.isEmpty ? Icon(Icons.image_outlined, color: Colors.grey.withValues(alpha: 0.5)) : null,
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                              SizedBox(height: 4.h),
                              Text('${p.city}, ${p.location}', style: TextStyle(color: Colors.grey, fontSize: 11.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                              SizedBox(height: 8.h),
                              Text('₹${p.price.toStringAsFixed(0)}', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 13.sp)),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 20.sp),
                              onPressed: () => onEdit(p),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.red, size: 20.sp),
                              onPressed: () {
                                // Add delete logic if needed
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete functionality coming soon')));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}
