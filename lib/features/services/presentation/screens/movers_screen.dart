import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoversScreen extends StatelessWidget {
  const MoversScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E60FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.swap_calls, color: Colors.white, size: 20),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text('Book Movers', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('TRANSIT ROUTE'),
            const SizedBox(height: 8),
            _buildTransitRouteCard(),
            const SizedBox(height: 24),
            _buildSectionLabel('PROPERTY SIZE'),
            const SizedBox(height: 8),
            _buildPropertySizeRow(),
            const SizedBox(height: 24),
            _buildSectionLabel('SCHEDULE PICKUP'),
            const SizedBox(height: 8),
            _buildScheduleRow(),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text('Shifting time depends on distance and inventory volume.', style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 24),
            _buildBookingSummaryCard(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E60FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Confirm & Book Movers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black87),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Check Packing Service (+₹999)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5, color: Colors.black87),
    );
  }

  Widget _buildTransitRouteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 7,
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
                children: [
                  const Icon(Icons.radio_button_checked, color: Color(0xFF1E60FF), size: 16),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('PICKUP LOCATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        SizedBox(height: 2),
                        Text('Prestige Falcon City, Bangalore', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.radio_button_unchecked, color: Colors.black54, size: 16),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DROP LOCATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 2),
                        Text('Search destination...', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.grey.shade400)),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildSizeChip('1 BHK', false)),
        const SizedBox(width: 8),
        Expanded(child: _buildSizeChip('2 BHK', true)),
        const SizedBox(width: 8),
        Expanded(child: _buildSizeChip('3 BHK', false)),
        const SizedBox(width: 8),
        Expanded(child: _buildSizeChip('4+ BHK', false)),
      ],
    );
  }

  Widget _buildSizeChip(String label, bool isSelected) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E60FF) : Colors.white,
        border: Border.all(color: isSelected ? const Color(0xFF1E60FF) : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildScheduleRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                SizedBox(width: 8),
                Text('Oct 24, 2023', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.schedule, size: 16, color: Colors.black54),
                SizedBox(width: 8),
                Text('10:00 AM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Booking Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('PREMIUM CARE', style: TextStyle(color: Color(0xFF1E60FF), fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildSummaryItem('INVENTORY', '2 BHK')),
                    Expanded(child: _buildSummaryItem('LABOUR', '3 Persons')),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildSummaryItem('DISTANCE', '~12.4 km')),
                    Expanded(child: _buildSummaryItem('PACKAGING', 'Included')),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    Icon(Icons.sell_outlined, color: Color(0xFF1E60FF), size: 18),
                    SizedBox(width: 8),
                    Text('Total Estimate', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 12)),
                  ],
                ),
                Text('₹4,250', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
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
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
