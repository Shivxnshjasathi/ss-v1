import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';

class MoversScreen extends ConsumerStatefulWidget {
  const MoversScreen({super.key});

  @override
  ConsumerState<MoversScreen> createState() => _MoversScreenState();
}

class _MoversScreenState extends ConsumerState<MoversScreen> {
  final TextEditingController _pickupController = TextEditingController(text: 'Prestige Falcon City, Bangalore');
  final TextEditingController _dropController = TextEditingController();
  
  String _selectedSize = '2 BHK';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  
  bool _includePacking = false;
  double _distanceKm = 10.0;
  
  int _calculateBasePrice() {
    switch (_selectedSize) {
      case '1 BHK': return 2500;
      case '2 BHK': return 4250;
      case '3 BHK': return 6500;
      case '4+ BHK': return 9000;
      default: return 4250;
    }
  }

  int _calculateTotalQuote() {
    int base = _calculateBasePrice();
    // 50 INR per km
    int distanceCost = (_distanceKm * 50).round();
    int total = base + distanceCost;
    if (_includePacking) total += 999;
    return total;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _confirmBooking() async {
    if (_dropController.text.trim().isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterDropLocation), backgroundColor: Colors.red),
      );
      return;
    }

    final user = ref.read(currentUserDataProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to continue'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
    );

    try {
      final String requestId = 'MOV-${const Uuid().v4().substring(0, 8).toUpperCase()}';
      final request = ServiceRequestModel(
        id: requestId,
        userId: user.uid,
        userName: user.name ?? 'User',
        userContact: user.phoneNumber,
        category: 'Movers',
        status: 'Pending',
        createdAt: DateTime.now(),
        location: _pickupController.text.split(',').last.trim(), // simple city extraction
        details: {
          'pickupLocation': _pickupController.text,
          'dropLocation': _dropController.text,
          'propertySize': _selectedSize,
          'includePacking': _includePacking,
          'pickupDate': _selectedDate.toIso8601String(),
          'pickupTime': '${_selectedTime.hour}:${_selectedTime.minute}',
          'distance': _distanceKm.round(),
          'estimatedQuote': _calculateTotalQuote(),
        },
      );

      await ref.read(serviceRequestRepositoryProvider).addRequest(request);

      if (!mounted) return;
      context.pop(); // dismiss loading

      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                Text(l10n.moversBookedSuccess, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  l10n.moversArrivalMsg(
                    _pickupController.text,
                    DateFormat('MMM d, yyyy').format(_selectedDate),
                    _selectedTime.format(context),
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/services/tracking'); // Redirect to tracking map
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Track Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
              onPressed: () => context.pop(),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: Text(
          l10n.packersAndMovers,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: context.primaryTextColor,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 1, color: context.borderColor),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel(l10n.transitRoute),
                  const SizedBox(height: 16),
                  _buildTransitRouteCard(l10n),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionLabel(l10n.propertySize),
                  const SizedBox(height: 16),
                  _buildPropertySizeRow(),
                  
                  const SizedBox(height: 32),

                  _buildSectionLabel(l10n.approxDistance),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('${_distanceKm.round()} km', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                      Expanded(
                        child: Slider(
                          value: _distanceKm,
                          min: 1,
                          max: 500,
                          divisions: 499,
                          activeColor: AppTheme.primaryBlue,
                          onChanged: (val) {
                            setState(() {
                              _distanceKm = val;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  
                  _buildSectionLabel(l10n.schedulePickup),
                  const SizedBox(height: 16),
                  _buildScheduleRow(context),
                  
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(l10n.shiftingTimeDisclaimer, style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildBookingSummaryCard(l10n),
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      icon: Icon(_includePacking ? Icons.check_box : Icons.check_box_outline_blank, color: _includePacking ? AppTheme.primaryBlue : Colors.grey),
                      onPressed: () {
                        setState(() {
                          _includePacking = !_includePacking;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _includePacking ? AppTheme.primaryBlue : Colors.grey.shade300, width: 2),
                        backgroundColor: _includePacking ? AppTheme.primaryBlue.withValues(alpha: 0.05) : Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      label: Row(
                        children: [
                          Text(' ${l10n.professionalPacking}', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13)),
                          const Spacer(),
                          Text('+₹999', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey.shade600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _confirmBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(l10n.confirmBooking, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5, color: context.primaryTextColor),
    );
  }

  Widget _buildTransitRouteCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 11,
            top: 24,
            bottom: 24,
            child: Container(
              width: 2,
              color: Colors.grey.shade300,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryBlue, width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.pickupLocation, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        TextField(
                          controller: _pickupController,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    child: const Icon(Icons.location_on_rounded, color: Colors.black87, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.dropLocation, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        TextField(
                          controller: _dropController,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: l10n.searchDestination,
                            hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade500),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 4),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertySizeRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSizeChip('1 BHK'),
          const SizedBox(width: 12),
          _buildSizeChip('2 BHK'),
          const SizedBox(width: 12),
          _buildSizeChip('3 BHK'),
          const SizedBox(width: 12),
          _buildSizeChip('4+ BHK'),
        ],
      ),
    );
  }

  Widget _buildSizeChip(String label) {
    bool isSelected = _selectedSize == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSize = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : context.cardColor,
          border: isSelected ? null : Border.all(color: context.borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            color: isSelected ? Colors.white : context.primaryTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: context.cardColor,
                border: Border.all(color: context.borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18, color: context.primaryTextColor),
                  const SizedBox(width: 12),
                  Text(DateFormat('MMM d, yyyy').format(_selectedDate), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: context.primaryTextColor)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => _selectTime(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 18, color: context.primaryTextColor),
                  const SizedBox(width: 8),
                  Text(_selectedTime.format(context), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: context.primaryTextColor)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSummaryCard(AppLocalizations l10n) {
    String formatCurrency(int amount) {
      String text = amount.toString();
      text = text.replaceAllMapped(RegExp(r'(\d)(?=(\d\d)+\d$)'), (Match m) => '${m[1]},');
      return '₹$text';
    }

    int totalQuote = _calculateTotalQuote();

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.bookingSummary, style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cyanAccent.withValues(alpha: 0.1),
                    border: Border.all(color: AppTheme.cyanAccent.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(l10n.premiumCare, style: GoogleFonts.inter(color: AppTheme.cyanAccent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildSummaryItem(l10n.inventory.toUpperCase(), _selectedSize)),
                    Expanded(child: _buildSummaryItem(l10n.packing.toUpperCase(), _includePacking ? l10n.included : l10n.none)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildSummaryItem(l10n.distance.toUpperCase(), '${_distanceKm.round()} km')),
                    Expanded(child: _buildSummaryItem(l10n.insurance.toUpperCase(), l10n.standardInsurance)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              border: Border(top: BorderSide(color: context.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_outlined, color: AppTheme.primaryBlue, size: 18),
                    const SizedBox(width: 8),
                    Text(l10n.estQuote, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Text(formatCurrency(totalQuote), style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 24, color: AppTheme.primaryBlue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black54, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.primaryTextColor)),
      ],
    );
  }
}
