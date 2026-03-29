import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/chat/data/chat_repository.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';

class ConstructionDashboardScreen extends ConsumerStatefulWidget {
  const ConstructionDashboardScreen({super.key});

  @override
  ConsumerState<ConstructionDashboardScreen> createState() => _ConstructionDashboardScreenState();
}

class _ConstructionDashboardScreenState extends ConsumerState<ConstructionDashboardScreen> {
  String _selectedCity = 'All';
  bool _sortByCity = false;

  @override
  Widget build(BuildContext context) {
    final leadsAsync = ref.watch(constructionLeadsProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text('Provider Dashboard', style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900)),
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.logout, color: context.iconColor), onPressed: () => context.go('/login')),
        ],
      ),
      body: leadsAsync.when(
        data: (leads) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Construction Leads', style: Theme.of(context).textTheme.displayMedium),
                      const SizedBox(height: 4),
                      Text(_selectedCity == 'All' ? 'Showing All Cities' : 'Filtered: $_selectedCity', 
                           style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  IconButton(
                    icon: Icon(_sortByCity ? Icons.sort_by_alpha : Icons.access_time_filled_outlined, color: AppTheme.primaryBlue, size: 20),
                    onPressed: () => setState(() => _sortByCity = !_sortByCity),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFilterBar(leads),
              const SizedBox(height: 24),
              Expanded(
                child: () {
                  // Apply Filter
                  var filteredList = _selectedCity == 'All' 
                      ? List<ServiceRequestModel>.from(leads)
                      : leads.where((l) => (l.location?.toLowerCase() ?? '') == _selectedCity.toLowerCase()).toList();

                  // Apply Sort
                  if (_sortByCity) {
                    filteredList.sort((a, b) => (a.location ?? '').compareTo(b.location ?? ''));
                  }

                  if (filteredList.isEmpty) {
                    return Center(child: Text('No leads found for chosen filters.', style: TextStyle(color: context.secondaryTextColor)));
                  }

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final lead = filteredList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.borderColor),
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
                                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(lead.id.substring(0, 8).toUpperCase(), style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 10)),
                                    ),
                                    if (lead.location != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(lead.location!.toUpperCase(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 10)),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(timeago.format(lead.createdAt), style: TextStyle(color: context.secondaryTextColor, fontSize: 10)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(lead.category, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                            const SizedBox(height: 8),
                            Text('Requested by: ${lead.userName}', style: TextStyle(color: context.primaryTextColor, fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(lead.details['notes'] ?? lead.category, style: TextStyle(color: context.secondaryTextColor, fontSize: 12, height: 1.5)),
                            const SizedBox(height: 16),
                            Divider(color: context.borderColor),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 16, color: context.secondaryTextColor),
                                const SizedBox(width: 8),
                                Text(lead.userContact, style: TextStyle(color: context.secondaryTextColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                const Spacer(),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {}, // TBD: Launch dialer
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                        foregroundColor: AppTheme.primaryBlue,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Call Back', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
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
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryBlue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Message', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }(),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildFilterBar(List<ServiceRequestModel> leads) {
    final cities = ['All', ...leads.map((l) => l.location).whereType<String>().toSet().toList()];
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
              backgroundColor: context.cardColor,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryBlue : context.secondaryTextColor,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? AppTheme.primaryBlue : context.borderColor),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
