import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:signature/signature.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class RentAgreementSignScreen extends ConsumerStatefulWidget {
  final String agreementId;

  const RentAgreementSignScreen({super.key, required this.agreementId});

  @override
  ConsumerState<RentAgreementSignScreen> createState() => _RentAgreementSignScreenState();
}

class _RentAgreementSignScreenState extends ConsumerState<RentAgreementSignScreen> {
  final _aadhaarController = TextEditingController();
  bool _isKycVerified = false;
  bool _isLoading = false;

  void _showEkycBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('E-KYC Verification', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 24.sp)),
              SizedBox(height: 8.h),
              const Text('Enter your 12-digit Aadhaar to verify identity.', style: TextStyle(color: Colors.grey)),
              SizedBox(height: 24.h),
              TextField(
                controller: _aadhaarController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                decoration: InputDecoration(
                  labelText: 'Aadhaar Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w)),
                  prefixIcon: Icon(Icons.fingerprint),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (_aadhaarController.text.length == 12) {
                      setState(() {
                        _isKycVerified = true;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('E-KYC Successful'), backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid 12-digit Aadhaar number'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                  ),
                  child: const Text('Verify via OTP Mock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSignatureDialog(ServiceRequestModel doc) {
    final SignatureController signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Draw Your Signature', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 300.w,
              height: 150.h,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
              child: Signature(
                controller: signatureController,
                backgroundColor: Colors.grey.shade100,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => signatureController.clear(),
                  child: const Text('Clear', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (signatureController.isNotEmpty) {
                      final Uint8List? data = await signatureController.toPngBytes();
                      if (data != null) {
                        final String base64Signature = base64Encode(data);
                        Navigator.pop(ctx);
                        _signDocument(doc, base64Signature);
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please draw your signature')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                  child: const Text('Confirm', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _signDocument(ServiceRequestModel doc, String base64Signature) async {
    final user = ref.read(currentUserDataProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to sign')));
      context.push('/login');
      return;
    }

    if (!_isKycVerified) {
       _showEkycBottomSheet();
       return;
    }

    setState(() => _isLoading = true);

    try {
      final newDetails = Map<String, dynamic>.from(doc.details);
      
      // Assume the receiver is the Lessee if the current user isn't the creator
      // To be strictly correct we just append their signature
      newDetails['lesseeSignature'] = {
        'uid': user.uid,
        'name': user.name,
        'timestamp': DateTime.now().toIso8601String(),
        'kycMethod': 'Aadhaar',
      };
      newDetails['lesseeSignatureImage'] = base64Signature;

      await ref.read(serviceRequestRepositoryProvider).updateRequestDetails(doc.id, newDetails);
      // If both signed, mark as Completed
      if (newDetails.containsKey('lessorSignature') && newDetails.containsKey('lesseeSignature')) {
        await ref.read(serviceRequestRepositoryProvider).updateRequestStatus(doc.id, 'Completed');
      }

      if (mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.green, size: 60.w),
                SizedBox(height: 16.h),
                Text('Document Signed!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp)),
                SizedBox(height: 8.h),
                const Text('Your digital signature has been affixed legally.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () {
                    context.pop();
                    context.go('/services/tracking');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, minimumSize: const Size(double.infinity, 45)),
                  child: const Text('View Dashboard', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = ref.watch(streamRequestByIdProvider(widget.agreementId));
    final userAsync = ref.watch(currentUserDataProvider);
    final currentUser = userAsync.value;
    
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text('Sign Rental Agreement', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp)),
        centerTitle: true,
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        iconTheme: IconThemeData(color: context.iconColor),
      ),
      body: stream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (doc) {
          if (doc == null) {
            return const Center(child: Text('Agreement not found or link expired.'));
          }

          final l10n = AppLocalizations.of(context)!;
          final details = doc.details;
          
          final hasLesseeSigned = details.containsKey('lesseeSignature');
          final isCreator = currentUser?.uid == doc.userId;
          final fullyExecuted = doc.status.toLowerCase() == 'fully executed' || doc.status.toLowerCase() == 'completed';

          return SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fullyExecuted)
                  Container(
                    margin: EdgeInsets.only(bottom: 24.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.w), border: Border.all(color: Colors.green.withValues(alpha: 0.3))),
                    child: Row(
                      children: [
                        Icon(Icons.gavel, color: Colors.green, size: 32.w),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Fully Executed', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.green, fontSize: 16.sp)),
                              SizedBox(height: 4.h),
                              Text('This legal document has been signed by both parties and securely stamped.', style: TextStyle(color: Colors.green, fontSize: 12.sp, fontWeight: FontWeight.w500, height: 1.4.h)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(color: AppTheme.cyanAccent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12.w), border: Border.all(color: AppTheme.cyanAccent.withValues(alpha: 0.1))),
                  child: Row(
                    children: [
                      Container(padding: EdgeInsets.all(8.w), decoration: BoxDecoration(color: context.scaffoldColor, borderRadius: BorderRadius.circular(8.w)), child: Icon(Icons.verified_user_outlined, color: AppTheme.cyanAccent, size: 20.w)),
                      SizedBox(width: 12.w),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Digital Smart Contract', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 12.sp, letterSpacing: -0.2)),
                        SizedBox(height: 2.h),
                        Text('E-Stamped Series • UID: ${doc.id}', style: TextStyle(fontSize: 9.sp, color: context.secondaryTextColor, fontWeight: FontWeight.w800, letterSpacing: 0.5))
                      ]),
                    ],
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l10n.lessorLabel, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)), 
                      SizedBox(height: 8.h), 
                      Text(details['lessorName'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.sp, letterSpacing: -0.3)),
                      if (details['lessorSignatureImage'] != null) ...[
                        SizedBox(height: 8.h),
                        Image.memory(base64Decode(details['lessorSignatureImage']), height: 50.h, color: Colors.blue.shade900),
                      ]
                    ])),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l10n.lesseeLabel, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)), 
                      SizedBox(height: 8.h), 
                      Text(details['lesseeName'] ?? 'Unknown', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.sp, letterSpacing: -0.3)),
                      if (details['lesseeSignatureImage'] != null) ...[
                        SizedBox(height: 8.h),
                        Image.memory(base64Decode(details['lesseeSignatureImage']), height: 50.h, color: Colors.blue.shade900),
                      ]
                    ])),
                  ],
                ),
                SizedBox(height: 32.h),
                _buildClause('01', l10n.premisesTerm, 'The Lessor hereby leases to the Lessee the residential apartment located at ${details['propertyAddress']} for a period of 11 months.'),
                _buildClause('02', l10n.monthlyRentClause, 'The Lessee shall pay a monthly rent of ₹${details['rent']} on or before the 5th of every calendar month via bank transfer.'),
                _buildClause('03', l10n.securityDepositClause, 'An interest-free refundable security deposit of ₹${details['deposit']} has been paid. This shall be returned upon peaceful possession handover.'),
                SizedBox(height: 32.h),
                
                if (fullyExecuted)
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Simulating PDF Download...')));
                      },
                      icon: Icon(Icons.download, color: AppTheme.primaryBlue),
                      label: Text('Download Legal PDF', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue)),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)), side: const BorderSide(color: AppTheme.primaryBlue)),
                    ),
                  )
                else if (hasLesseeSigned)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.w)),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 32.w),
                        SizedBox(height: 8.h),
                        Text('You have successfully signed this document.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  )
                else if (isCreator)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.w), border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
                    child: Column(
                      children: [
                        Icon(Icons.pending_actions, color: Colors.orange, size: 32.w),
                        SizedBox(height: 8.h),
                        Text('Awaiting Tenant Signature', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.orange, fontSize: 15.sp)),
                        SizedBox(height: 4.h),
                        Text('You have successfully created and signed this document as the Lessor. Please share the link with the Tenant for their signature.', textAlign: TextAlign.center, style: TextStyle(color: Colors.orange, fontSize: 12.sp, height: 1.4.h)),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _showSignatureDialog(doc),
                      icon: _isLoading ? SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(Icons.fingerprint, color: Colors.white),
                      label: Text(_isKycVerified ? 'Accept & Digitally Sign' : 'Complete E-KYC to Sign', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.white)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w))),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClause(String number, String title, String body) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.grey)),
          SizedBox(width: 16.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp, color: Theme.of(context).textTheme.bodyLarge?.color, letterSpacing: -0.2)), SizedBox(height: 6.h), Text(body, style: TextStyle(color: Colors.grey, fontSize: 12.sp, height: 1.5.h, fontWeight: FontWeight.w500)), SizedBox(height: 16.h), Divider(height: 1.h, color: Colors.grey.withValues(alpha: 0.2))])),
        ],
      ),
    );
  }
}
