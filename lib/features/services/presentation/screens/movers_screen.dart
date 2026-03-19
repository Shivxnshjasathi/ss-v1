import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';

class MoversScreen extends StatefulWidget {
  const MoversScreen({super.key});

  @override
  State<MoversScreen> createState() => _MoversScreenState();
}

class _MoversScreenState extends State<MoversScreen> {
  final TextEditingController _pickupController = TextEditingController(text: 'Prestige Falcon City, Bangalore');
  final TextEditingController _dropController = TextEditingController();
  
  String _selectedSize = '2 BHK';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  
  bool _includePacking = false;
  
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
    if (_includePacking) base += 999;
    return base;
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

  void _confirmBooking() {
    if (_dropController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a drop location.'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.pop(); // dismiss loading
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text('Movers Booked Successfully!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Our team will arrive at ${_pickupController.text} on ${DateFormat('MMM d, yyyy').format(_selectedDate)} at ${_selectedTime.format(context)}.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back to Home', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          'Packers & Movers',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            color: Colors.black,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 1, color: Colors.grey[100]),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('TRANSIT ROUTE'),
                  const SizedBox(height: 16),
                  _buildTransitRouteCard(),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionLabel('PROPERTY SIZE'),
                  const SizedBox(height: 16),
                  _buildPropertySizeRow(),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionLabel('SCHEDULE PICKUP'),
                  const SizedBox(height: 16),
                  _buildScheduleRow(context),
                  
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text('Shifting time depends on distance and inventory volume.', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildBookingSummaryCard(),
                  
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
                          const Text(' Professional Packing Service', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 13)),
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
                      child: const Text('Confirm & Book Movers', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
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
      style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5, color: Colors.black),
    );
  }

  Widget _buildTransitRouteCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
                        const Text('PICKUP LOCATION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
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
                        const Text('DROP LOCATION', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
                        const SizedBox(height: 2),
                        TextField(
                          controller: _dropController,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search destination...',
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
          color: isSelected ? AppTheme.primaryBlue : const Color(0xFFF8F9FB),
          border: isSelected ? null : Border.all(color: Colors.grey.shade100, width: 1.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black87,
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
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black87),
                  const SizedBox(width: 12),
                  Text(DateFormat('MMM d, yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black87)),
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
                  const Icon(Icons.schedule, size: 18, color: Colors.black87),
                  const SizedBox(width: 8),
                  Text(_selectedTime.format(context), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.black87)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSummaryCard() {
    String formatCurrency(int amount) {
      String text = amount.toString();
      text = text.replaceAllMapped(RegExp(r'(\d)(?=(\d\d)+\d$)'), (Match m) => '${m[1]},');
      return '₹$text';
    }

    int totalQuote = _calculateTotalQuote();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Booking Summary', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cyanAccent.withValues(alpha: 0.1),
                    border: Border.all(color: AppTheme.cyanAccent.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('PREMIUM CARE', style: GoogleFonts.inter(color: AppTheme.cyanAccent, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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
                    Expanded(child: _buildSummaryItem('INVENTORY', _selectedSize)),
                    Expanded(child: _buildSummaryItem('PACKING', _includePacking ? 'Included' : 'None')),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildSummaryItem('DISTANCE', 'Calculated at pickup')),
                    Expanded(child: _buildSummaryItem('INSURANCE', 'Standard (+0)')),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              border: Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.verified_outlined, color: AppTheme.primaryBlue, size: 18),
                    SizedBox(width: 8),
                    Text('Est. Quote', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey)),
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
      ],
    );
  }
}
