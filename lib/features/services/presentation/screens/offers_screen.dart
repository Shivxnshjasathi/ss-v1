import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['All', 'Properties', 'Services', 'Bank Offers', 'Cashback'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  border: Border.all(color: context.borderColor),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Icon(
                  LucideIcons.arrowLeft,
                  color: context.iconColor,
                  size: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              "Offers Hub",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: context.primaryTextColor,
                fontSize: 18.sp,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.info, color: context.iconColor, size: 20.sp),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRewardsSection(),
            _buildHeroCarousel(),
            _buildCategoryTabs(),
            _buildSectionHeader('Flash Property Sales', 'Ending Soon'),
            _buildFlashSaleList(),
            _buildSectionHeader('Exclusive Coupons', 'Best Value'),
            _buildOffersListStatic(),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }


  Widget _buildRewardsSection() {
    return Container(
      margin: EdgeInsets.all(24.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
            child: Icon(LucideIcons.coins, color: Colors.white, size: 16.sp),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sampatti Coins', style: TextStyle(color: Colors.grey, fontSize: 10.sp, fontWeight: FontWeight.bold)),
              Text('1,250 Available', style: TextStyle(color: context.primaryTextColor, fontSize: 16.sp, fontWeight: FontWeight.w900)),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text('REDEEM NOW', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 10.sp, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCarousel() {
    return SizedBox(
      height: 180.h,
      child: PageView(
        children: [
          _buildHeroItem(
            'Mega Property Sale',
            'Up to ₹5 Lakh Off on select villas',
            'Expires in 2 days',
            const Color(0xFF1E60FF),
            LucideIcons.house,
          ),
          _buildHeroItem(
            'Construction Expo',
            '20% Flat Discount on Premium Tiles',
            'Valid for 1 week',
            const Color(0xFF00C853),
            LucideIcons.hammer,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroItem(String title, String subtitle, String expiry, Color color, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.w),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(icon, size: 120.sp, color: Colors.white.withValues(alpha: 0.1)),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6.w),
                  ),
                  child: Text(
                    'FEATURED',
                    style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.sp),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(LucideIcons.clock, color: Colors.white, size: 12.sp),
                    SizedBox(width: 4.w),
                    Text(expiry, style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(vertical: 16.h),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorColor: AppTheme.primaryBlue,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: AppTheme.primaryBlue,
        unselectedLabelColor: Colors.grey,
        labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp),
        tabs: _categories.map((cat) => Tab(text: cat)).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String tag) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: context.primaryTextColor),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.w),
            ),
            child: Text(
              tag.toUpperCase(),
              style: TextStyle(color: Colors.red, fontSize: 8.sp, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSaleList() {
    return SizedBox(
      height: 220.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          _buildFlashSaleCard(
            'Skyview Apartments',
            'Whitefield, Bangalore',
            '₹85 L',
            '₹79 L',
            '75% Booked',
            0.75,
          ),
          _buildFlashSaleCard(
            'Green Valley Villas',
            'Gachibowli, Hyderabad',
            '₹2.4 Cr',
            '₹2.1 Cr',
            '40% Booked',
            0.4,
          ),
        ],
      ),
    );
  }

  Widget _buildFlashSaleCard(String title, String loc, String oldPrice, String newPrice, String status, double progress) {
    return Container(
      width: 200.w,
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.w)),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=400'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                    child: Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp), maxLines: 1),
                Text(loc, style: TextStyle(color: Colors.grey, fontSize: 10.sp), maxLines: 1),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(newPrice, style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 14.sp)),
                    SizedBox(width: 4.w),
                    Text(oldPrice, style: TextStyle(color: Colors.grey, fontSize: 10.sp, decoration: TextDecoration.lineThrough)),
                  ],
                ),
                SizedBox(height: 8.h),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: 4.h),
                Text(status, style: TextStyle(fontSize: 8.sp, color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersListStatic() {
    final List<Map<String, dynamic>> coupons = [
      {
        'title': 'SBI Home Loan Offer',
        'desc': 'Flat 0.5% interest rate reduction for pre-approved users.',
        'code': 'SBISAVE',
        'type': 'Bank Offers',
        'icon': LucideIcons.landmark,
      },
      {
        'title': 'New Home Bonus',
        'desc': 'Free Modular Kitchen setup on bookings above ₹1 Cr.',
        'code': 'KITCHEN100',
        'type': 'Properties',
        'icon': LucideIcons.chefHat,
      },
      {
        'title': 'Movers Discount',
        'desc': 'Flat 20% Off on all intra-city packers & movers services.',
        'code': 'MOVE20',
        'type': 'Services',
        'icon': LucideIcons.truck,
      },
    ];

    return Column(
      children: coupons.map((coupon) => _buildCouponCard(coupon)).toList(),
    );
  }

  Widget _buildCouponCard(Map<String, dynamic> coupon) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: Icon(coupon['icon'], color: AppTheme.primaryBlue, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coupon['type'].toString().toUpperCase(),
                  style: TextStyle(color: AppTheme.primaryBlue, fontSize: 8.sp, fontWeight: FontWeight.w900),
                ),
                Text(
                  coupon['title'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
                Text(
                  coupon['desc'],
                  style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: coupon['code']));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copied to clipboard!')),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    border: Border.all(color: AppTheme.primaryBlue, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8.w),
                  ),
                  child: Text(
                    coupon['code'],
                    style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12.sp),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              Text('TAP TO COPY', style: TextStyle(fontSize: 7.sp, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
