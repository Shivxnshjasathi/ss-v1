import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final offers = [
      {
        'title': 'Home Loan Cashback',
        'description': 'Get flat ₹5,000 cashback on processing fees for your first home loan.',
        'code': 'HOME5000',
        'color': AppTheme.primaryBlue,
        'icon': LucideIcons.landmark,
      },
      {
        'title': 'Construction Discount',
        'description': 'Special 15% discount on construction materials when you hire our verified contractors.',
        'code': 'BUILD15',
        'color': AppTheme.primaryBlue,
        'icon': LucideIcons.pencilRuler,
      },
      {
        'title': 'Legal Consultation',
        'description': 'First 30 minutes of legal consultation absolutely free for property verification.',
        'code': 'LEGALFREE',
        'color': AppTheme.primaryBlue,
        'icon': LucideIcons.gavel,
      },
      {
        'title': 'Movers Special',
        'description': 'Zero insurance cost on intra-city relocations this month.',
        'code': 'MOVESAFE',
        'color': AppTheme.primaryBlue,
        'icon': LucideIcons.truck,
      },
    ];

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
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  border: Border.all(color: context.borderColor),
                  borderRadius: BorderRadius.circular(14.sp),
                ),
                child: Icon(
                  LucideIcons.arrowLeft,
                  color: context.iconColor,
                  size: 16.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              "Exclusive Offers",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: context.primaryTextColor,
                fontSize: 24.sp,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          return _buildOfferCard(context, offer);
        },
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, Map<String, dynamic> offer) {
    final color = offer['color'] as Color;
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(24.sp),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.sp),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Icon(
                offer['icon'] as IconData,
                size: 140.sp,
                color: context.primaryTextColor.withValues(alpha: 0.03),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.sp),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16.sp),
                        ),
                        child: Icon(
                          offer['icon'] as IconData,
                          color: context.primaryTextColor,
                          size: 24.sp,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.sp),
                        ),
                        child: Text(
                          "LIMITED OFFER",
                          style: TextStyle(
                            color: color,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    offer['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22.sp,
                      color: context.primaryTextColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    offer['description'] as String,
                    style: TextStyle(
                      color: context.secondaryTextColor,
                      fontSize: 14.sp,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "USE CODE",
                              style: TextStyle(
                                color: context.secondaryTextColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              offer['code'] as String,
                              style: TextStyle(
                                color: context.primaryTextColor,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.sp),
                          ),
                        ),
                        child: Text(
                          "CLAIM NOW",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12.sp,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
