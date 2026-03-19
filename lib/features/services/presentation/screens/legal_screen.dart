import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 28),
          onPressed: () => context.pop(),
        ),
        title: const Text('Legal Documents', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 16)),
        centerTitle: true,
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
            // Custom Stepper
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStep(context, 'REVIEW', isCompleted: true),
                _buildStepLine(context, isCompleted: true),
                _buildStep(context, 'VERIFY', isCompleted: true),
                _buildStepLine(context, isCompleted: false),
                _buildStep(context, 'SIGN', isCompleted: false, stepNumber: '3'),
              ],
            ),
            const SizedBox(height: 32),

            // Title
            const Text('Rent Agreement', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
            const SizedBox(height: 4),
            Text('Residential Lease for Property ID: SR-89291-BLR', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 24),

            // Badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FAFD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: Color(0xFF00D1FF)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('DIGITAL VERIFICATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                      SizedBox(height: 2),
                      Text('E-STAMPED DOCUMENT • 2024 SERIES', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Parties
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('LESSOR (LANDLORD)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text('Ramesh Kumar Iyer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('LESSEE (TENANT)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text('Aditi Sharma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Clauses
            _buildClause('01', 'PREMISES & TERM', 'The Lessor hereby leases to the Lessee the residential apartment located at Flat 402, Skyline Heights, Indiranagar, Bangalore for a period of 11 months starting June 1, 2024.'),
            _buildClause('02', 'MONTHLY RENT', 'The Lessee shall pay a monthly rent of ₹32,000 (Thirty-Two Thousand Rupees) on or before the 5th of every calendar month via bank transfer.'),
            _buildClause('03', 'SECURITY DEPOSIT', 'An interest-free refundable security deposit of ₹1,50,000 has been paid. This shall be returned upon peaceful possession handover.'),
            _buildClause('04', 'NOTICE PERIOD', 'Both parties agree to a mandatory 2-month notice period prior to early termination of the lease by either the Lessor or the Lessee.'),
            
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This document is digitally prepared by Sampatti Bazar Legal. By signing, you agree to the Terms of Service and digital e-stamp protocols.',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text('View Full Document Details >', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download, size: 16, color: Colors.black),
                      label: const Text('Download', style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.draw, size: 16, color: Colors.white),
                      label: const Text('Sign Document', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E60FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.description, size: 12, color: Colors.grey),
                SizedBox(width: 4),
                Text('VERIFIED BY DIGITAL INDIA E-SIGN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, String title, {required bool isCompleted, String? stepNumber}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.black : const Color(0xFF1E60FF),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(stepNumber ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCompleted ? Colors.black : const Color(0xFF1E60FF))),
      ],
    );
  }

  Widget _buildStepLine(BuildContext context, {required bool isCompleted}) {
    return Container(
      width: 60,
      height: 2,
      margin: const EdgeInsets.only(top: 15, left: 8, right: 8),
      color: isCompleted ? Colors.black : Colors.grey.shade300,
    );
  }

  Widget _buildClause(String number, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                const SizedBox(height: 8),
                Text(body, style: TextStyle(color: Colors.grey[700], fontSize: 12, height: 1.5)),
                const SizedBox(height: 16),
                const Divider(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
