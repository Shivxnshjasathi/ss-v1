import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoversScreen extends StatelessWidget {
  const MoversScreen({super.key});

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
              color: const Color(0xFF1E60FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: const Icon(Icons.flash_on, color: Colors.white, size: 24),
              onPressed: () => context.pop(),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        title: const Text('Book Movers', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 18, letterSpacing: -0.5)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline, color: Colors.black), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 1, color: Colors.grey[200]),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('TRANSIT ROUTE'),
                  const SizedBox(height: 12),
                  _buildTransitRouteCard(),
                  
                  const SizedBox(height: 28),
                  
                  _buildSectionLabel('PROPERTY SIZE'),
                  const SizedBox(height: 12),
                  _buildPropertySizeRow(),
                  
                  const SizedBox(height: 28),
                  
                  _buildSectionLabel('SCHEDULE PICKUP'),
                  const SizedBox(height: 12),
                  _buildScheduleRow(),
                  
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.near_me_outlined, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text('Shifting time depends on distance and inventory volume.', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  
                  const SizedBox(height: 28),
                  
                  _buildBookingSummaryCard(),
                  
                  const SizedBox(height: 28),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text('Confirm & Book Movers', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black54),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text('Check Packing Service (+₹999)', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: BottomNavigationBar(
          currentIndex: 2, // 'Movers' is selected
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0066FF),
          unselectedItemColor: Colors.grey[600],
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.money_outlined, size: 24),
              label: 'Loans',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.handyman_outlined, size: 24),
              label: 'Build',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping, size: 24),
              label: 'Movers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined, size: 24),
              label: 'Market',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline, size: 24),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.5, color: Colors.black),
    );
  }

  Widget _buildTransitRouteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 11,
            top: 24,
            bottom: 24,
            child: Container(
              width: 1,
              color: Colors.grey.shade300,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0066FF), width: 2),
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0066FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('PICKUP LOCATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
                        SizedBox(height: 4),
                        Text('Prestige Falcon City, Bangalore', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 24,
                    height: 24,
                    child: const Icon(Icons.location_on_outlined, color: Colors.black, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DROP LOCATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text('Search destination...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey.shade400)),
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
        color: isSelected ? const Color(0xFF0066FF) : Colors.white,
        border: Border.all(color: isSelected ? const Color(0xFF0066FF) : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 10,
          color: isSelected ? Colors.white : Colors.black,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: const [
                Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black54),
                SizedBox(width: 12),
                Text('Oct 24, 2023', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: const [
                Icon(Icons.schedule, size: 16, color: Colors.black54),
                SizedBox(width: 8),
                Text('10:00 AM', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
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
        color: const Color(0xFFFAFAFA),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Booking Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F0FF),
                    border: Border.all(color: const Color(0xFF99C2FF)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text('PREMIUM CARE', style: TextStyle(color: Color(0xFF0066FF), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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
                  children: [
                    Expanded(child: _buildSummaryItem('INVENTORY', '2 BHK')),
                    Expanded(child: _buildSummaryItem('LABOUR', '3 Persons')),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildSummaryItem('DISTANCE', '~12.4 km')),
                    Expanded(child: _buildSummaryItem('INSURANCE', 'Included')),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.verified_outlined, color: Color(0xFF0066FF), size: 18),
                      SizedBox(width: 8),
                      Text('Est. Quote', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
                    ],
                  ),
                  Text('₹4,250', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
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
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black54)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
