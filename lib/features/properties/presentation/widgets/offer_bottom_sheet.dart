import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/properties/data/offer_repository.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';
import 'package:sampatti_bazar/shared/widgets/primary_button.dart';

class OfferBottomSheet extends ConsumerStatefulWidget {
  final PropertyModel property;

  const OfferBottomSheet({super.key, required this.property});

  @override
  ConsumerState<OfferBottomSheet> createState() => _OfferBottomSheetState();
}

class _OfferBottomSheetState extends ConsumerState<OfferBottomSheet> {
  late double _offerAmount;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _offerAmount = widget.property.price;
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  Future<void> _submitOffer() async {
    final user = ref.read(currentUserDataProvider).value;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(offerRepositoryProvider).submitOffer(
            propertyId: widget.property.id,
            buyerId: user.uid,
            ownerId: widget.property.ownerId,
            amount: _offerAmount,
          );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Offer submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit offer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final minOffer = widget.property.price * 0.7; // 70% of asking price
    final maxOffer = widget.property.price * 1.5; // 150% of asking price

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
      decoration: BoxDecoration(
        color: context.scaffoldColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.sp)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.sp),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Make an Offer',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: context.primaryTextColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Asking Price: ${_formatCurrency(widget.property.price)}',
            style: TextStyle(
              fontSize: 14.sp,
              color: context.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 32.h),
          Center(
            child: Text(
              _formatCurrency(_offerAmount),
              style: TextStyle(
                fontSize: 40.sp,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryBlue,
                letterSpacing: -1,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8.h,
              activeTrackColor: AppTheme.primaryBlue,
              inactiveTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
              thumbColor: AppTheme.primaryBlue,
              overlayColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.sp),
            ),
            child: Slider(
              value: _offerAmount,
              min: minOffer,
              max: maxOffer,
              divisions: 100,
              onChanged: (value) {
                setState(() {
                  _offerAmount = value;
                });
              },
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatCurrency(minOffer), style: TextStyle(color: context.secondaryTextColor, fontSize: 12.sp)),
              Text(_formatCurrency(maxOffer), style: TextStyle(color: context.secondaryTextColor, fontSize: 12.sp)),
            ],
          ),
          SizedBox(height: 40.h),
          PrimaryButton(
            text: 'SUBMIT OFFER',
            isLoading: _isLoading,
            onPressed: _submitOffer,
          ),
        ],
      ),
    );
  }
}
