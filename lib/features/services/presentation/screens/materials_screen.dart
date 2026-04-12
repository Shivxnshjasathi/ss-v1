import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';

class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  border: Border.all(color: context.borderColor),
                  borderRadius: BorderRadius.circular(14.sp),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: context.iconColor,
                  size: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              'Supplier Materials',
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
      body: CustomScrollView(
         slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wholesale Hub',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22.sp,
                        fontFamily: 'Poppins',
                        color: context.primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Get bulk quotes for premium materials and furniture directly from global suppliers.',
                      style: TextStyle(
                        color: context.secondaryTextColor,
                        fontSize: 13.sp,
                        height: 1.4,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.w,
                  crossAxisSpacing: 16.w,
                  childAspectRatio: 0.68,
                ),
               delegate: SliverChildListDelegate([
                 _buildMaterialCard(context, 'Premium Cement', 'Starting ₹350/bag', 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&q=80'),
                 _buildMaterialCard(context, 'TMT Steel Bars', 'Starting ₹65/kg', 'https://images.unsplash.com/photo-1541888081628-912fcf45ee39?w=500&q=80'),
                 _buildMaterialCard(context, 'Red Bricks', 'Starting ₹7/piece', 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=500&q=80'),
                 _buildMaterialCard(context, 'Italian Marble', 'Starting ₹250/sqft', 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=500&q=80'),
                 _buildMaterialCard(context, 'Wall Paints', 'Starting ₹150/L', 'https://images.unsplash.com/photo-1562184552-997c461abbe6?w=500&q=80'),
                 _buildMaterialCard(context, 'Living Furniture', 'Wholesale Catalog', 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500&q=80'),
               ]),
             ),
           ),
           SliverPadding(padding: EdgeInsets.only(bottom: 24.h)),
         ],
       ),
     );
  }

  Widget _buildMaterialCard(BuildContext context, String title, String price, String imageUrl) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20.sp),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14.sp),
              ),
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: context.surfaceColor),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13.sp,
              fontFamily: 'Poppins',
              color: context.primaryTextColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            price,
            style: TextStyle(
              color: AppTheme.primaryBlue,
              fontSize: 11.sp,
              fontWeight: FontWeight.w900,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 36.h,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Quote requested for $title'),
                    backgroundColor: AppTheme.primaryBlue,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.scaffoldColor,
                foregroundColor: AppTheme.primaryBlue,
                elevation: 0,
                side: BorderSide(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.sp)),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'GET QUOTE',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10.sp,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
