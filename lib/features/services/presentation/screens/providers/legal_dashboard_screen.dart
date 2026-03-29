import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/chat/data/chat_repository.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';

class LegalDashboardScreen extends ConsumerStatefulWidget {
  const LegalDashboardScreen({super.key});

  @override
  ConsumerState<LegalDashboardScreen> createState() => _LegalDashboardScreenState();
}

class _LegalDashboardScreenState extends ConsumerState<LegalDashboardScreen> {
  String _selectedCity = 'All';
  bool _sortByCity = false;

  @override
  Widget build(BuildContext context) {
    final queriesAsync = ref.watch(legalLeadsProvider);

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text('Legal Advisor Dashboard', style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900)),
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.logout, color: context.iconColor), onPressed: () => context.go('/login')),
        ],
      ),
      body: queriesAsync.when(
        data: (queries) => Padding(
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
                      Text('Client Queries', style: Theme.of(context).textTheme.displayMedium),
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
              _buildFilterBar(queries),
              const SizedBox(height: 24),
              Expanded(
                child: () {
                  // Apply Filter
                  var filteredList = _selectedCity == 'All' 
                      ? List<ServiceRequestModel>.from(queries)
                      : queries.where((q) => (q.location?.toLowerCase() ?? '') == _selectedCity.toLowerCase()).toList();

                  // Apply Sort
                  if (_sortByCity) {
                    filteredList.sort((a, b) => (a.location ?? '').compareTo(b.location ?? ''));
                  }

                  if (filteredList.isEmpty) {
                    return Center(child: Text('No queries found for chosen filters.', style: TextStyle(color: context.secondaryTextColor)));
                  }

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final query = filteredList[index];
                      final isPending = query.status == 'Pending';
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
                                        color: isPending 
                                          ? Colors.orange.withValues(alpha: 0.1) 
                                          : Colors.green.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        query.status.toUpperCase(), 
                                        style: TextStyle(
                                          color: isPending ? Colors.orange : Colors.green, 
                                          fontWeight: FontWeight.w900, 
                                          fontSize: 10
                                        )
                                      ),
                                    ),
                                    if (query.location != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(query.location!.toUpperCase(), style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 10)),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(timeago.format(query.createdAt), style: TextStyle(color: context.secondaryTextColor, fontSize: 10)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(query.category, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                            const SizedBox(height: 8),
                            Text('Client: ${query.userName}', style: TextStyle(color: context.primaryTextColor, fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            if (query.details['propertyId'] != null)
                              Text('Property ID: ${query.details['propertyId']}', style: TextStyle(color: context.secondaryTextColor, fontSize: 11, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Text(query.details['notes'] ?? query.category, style: TextStyle(color: context.secondaryTextColor, fontSize: 12, height: 1.5)),
                            const SizedBox(height: 16),
                            Divider(color: context.borderColor),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.phone, size: 16, color: context.secondaryTextColor),
                                const SizedBox(width: 8),
                                Text(query.userContact, style: TextStyle(color: context.secondaryTextColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                const Spacer(),
                                if (isPending)
                                  ElevatedButton(
                                    onPressed: () async {
                                      await ref.read(serviceRequestRepositoryProvider).updateRequestStatus(query.id, 'Accepted');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryBlue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: const Text('Accept Query', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                  ),
                                if (!isPending)
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final userProfile = ref.read(currentUserDataProvider).value;
                                      if (userProfile == null) return;
                                      
                                      final chatId = await ref.read(chatRepositoryProvider).startOrGetChat(
                                        userProfile.uid, 
                                        query.userId,
                                        metadata: {'type': 'service', 'category': query.category},
                                      );
                                      if (context.mounted) {
                                        context.push('/chats/$chatId');
                                      }
                                    },
                                    icon: const Icon(Icons.message, size: 16),
                                    label: const Text('Message', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryBlue,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      side: const BorderSide(color: AppTheme.primaryBlue),
                                    ),
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

  Widget _buildFilterBar(List<ServiceRequestModel> queries) {
    final cities = ['All', ...queries.map((q) => q.location).whereType<String>().toSet().toList()];
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
