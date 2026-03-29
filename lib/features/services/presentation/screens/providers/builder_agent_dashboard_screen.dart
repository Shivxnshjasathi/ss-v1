import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text('Agent Portal', style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900)),
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.logout, color: context.iconColor), onPressed: () => context.go('/login')),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _ListingFormView(),
          _VisitorRequestsView(),
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
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: context.scaffoldColor,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: Colors.grey,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.add_business_outlined), activeIcon: Icon(Icons.add_business), label: 'Add Listing'),
            BottomNavigationBarItem(icon: Icon(Icons.visibility_outlined), activeIcon: Icon(Icons.visibility), label: 'Visitor Requests'),
          ],
        ),
      ),
    );
  }
}

class _ListingFormView extends ConsumerStatefulWidget {
  const _ListingFormView();

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

  Future<void> _submitListing() async {
    final user = ref.read(currentUserDataProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final property = PropertyModel(
        id: const Uuid().v4(),
        ownerId: user.uid,
        title: _nameController.text,
        description: _descriptionController.text,
        type: 'Sale', // Default
        propertyType: 'Apartment', // Default
        price: double.tryParse(_priceController.text) ?? 0.0,
        location: _addressController.text,
        city: _cityController.text,
        bedrooms: 2, // Mock defaults
        bathrooms: 2,
        areaSqFt: double.tryParse(_areaController.text) ?? 0.0,
        imageUrls: [],
        createdAt: DateTime.now(),
      );

      await ref.read(propertyRepositoryProvider).addProperty(property, []);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing Published Successfully!')));
        _nameController.clear();
        _cityController.clear();
        _addressController.clear();
        _priceController.clear();
        _areaController.clear();
        _descriptionController.clear();
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Publish Property', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          Text('List new properties directly to the Sampatti feed.', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
          const SizedBox(height: 32),
          
          _buildFormSection(context, 'PROPERTY NAME', 'e.g. Skyline Apartments', controller: _nameController),
          const SizedBox(height: 16),
          _buildFormSection(context, 'CITY', 'e.g. Indore', controller: _cityController),
          const SizedBox(height: 16),
          _buildFormSection(context, 'DETAILED ADDRESS', 'e.g. Plot 43, Scheme 78', controller: _addressController),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFormSection(context, 'PRICE (₹)', '0.00', controller: _priceController, keyboardType: TextInputType.number)),
              const SizedBox(width: 16),
              Expanded(child: _buildFormSection(context, 'AREA (SQ.FT)', '0', controller: _areaController, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormSection(context, 'DESCRIPTION', 'Write a compelling description...', controller: _descriptionController, maxLines: 4),
          const SizedBox(height: 32),
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle, border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))), child: const Icon(Icons.add_a_photo_outlined, color: AppTheme.primaryBlue)),
                const SizedBox(height: 16),
                const Text('Upload Photos', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitListing,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('PUBLISH LISTING', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, String label, String hint, {required TextEditingController controller, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(allSiteVisitsStreamProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_city, color: AppTheme.primaryBlue, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Visitor Requests', style: Theme.of(context).textTheme.displayMedium),
                    Text(_selectedCity == 'All' ? 'Showing All Cities' : 'Filtered: $_selectedCity', 
                         style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_sortByCity ? Icons.sort_by_alpha : Icons.access_time_filled_outlined, color: AppTheme.primaryBlue, size: 20),
                onPressed: () => setState(() => _sortByCity = !_sortByCity),
                tooltip: 'Toggle Sort Order',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterBar(context, ref),
          const SizedBox(height: 24),
          Expanded(
            child: requestsAsync.when(
              data: (requests) {
                // Apply Filter
                var filteredList = _selectedCity == 'All' 
                    ? List<ServiceRequestModel>.from(requests)
                    : requests.where((r) => (r.location?.toLowerCase() ?? '') == _selectedCity.toLowerCase()).toList();

                // Apply Sort
                if (_sortByCity) {
                  filteredList.sort((a, b) => (a.location ?? '').compareTo(b.location ?? ''));
                }

                if (filteredList.isEmpty) {
                  return Center(child: Text(_selectedCity == 'All' ? 'No visitor requests found.' : 'No requests in $_selectedCity.'));
                }

                return ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final req = filteredList[index];
                    final isPending = req.status == 'Pending';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isPending 
                                        ? Colors.orange.withValues(alpha: 0.1) 
                                        : Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      req.status.toUpperCase(), 
                                      style: TextStyle(
                                        color: isPending ? Colors.orange : Colors.green, 
                                        fontWeight: FontWeight.w900, 
                                        fontSize: 10
                                      )
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (req.location != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        req.location!.toUpperCase(),
                                        style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 10),
                                      ),
                                    ),
                                ],
                              ),
                              Text(timeago.format(req.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(req.details['propertyAddress'] ?? 'Property Visit', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: AppTheme.primaryBlue),
                              const SizedBox(width: 4),
                              Text(req.details['preferredTime'] ?? 'TBD', style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle),
                                child: const Icon(Icons.person, size: 16, color: Colors.grey),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(req.userName, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text(req.userContact, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                              const Spacer(),
                              if (isPending)
                                ElevatedButton(
                                  onPressed: () async {
                                    await ref.read(serviceRequestRepositoryProvider).updateRequestStatus(req.id, 'Approved');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryBlue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                                ),
                              IconButton(
                                icon: const Icon(Icons.message, color: AppTheme.primaryBlue), 
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
                                }
                              ),
                              if (!isPending)
                                IconButton(icon: const Icon(Icons.phone, color: AppTheme.primaryBlue), onPressed: () {}),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(allSiteVisitsStreamProvider);
    
    return requestsAsync.when(
      data: (requests) {
        final cities = ['All', ...requests.map((r) => r.location).whereType<String>().toSet().toList()];
        cities.sort();

        if (cities.length <= 1) return const SizedBox.shrink();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: cities.map((city) {
              final isSelected = _selectedCity == city;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(city),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCity = city);
                  },
                  selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                  backgroundColor: Theme.of(context).cardColor,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryBlue : Colors.grey,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isSelected ? AppTheme.primaryBlue : Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}
