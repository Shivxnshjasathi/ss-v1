import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ConstructionScreen extends StatelessWidget {
  const ConstructionScreen({super.key});

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
        title: const Text('Project Intake', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 16)),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black), onPressed: () {}),
          IconButton(icon: const Icon(Icons.person_outline, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Phase 01: Onboarding', style: TextStyle(color: Color(0xFF1E60FF), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            const Text('BUILD YOUR VISION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text(
              'Provide your plot details and budget to generate a custom construction roadmap and material estimate.',
              style: TextStyle(color: Colors.grey[700], fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Text('Project Scope', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Tell us about the physical dimensions and financial plan.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 24),
            _buildInputField('Plot Size (sq. ft.)', 'e.g. 1500', 'Minimum required size is 450 sq. ft.'),
            const SizedBox(height: 24),
            _buildInputField('Estimated Budget (₹)', 'e.g. 25,00,000', 'Includes labor and standard materials.'),
            const SizedBox(height: 32),
            const Text('Construction Category', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(color: Colors.black, border: Border.all(color: Colors.black)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('RESIDENTIAL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                        SizedBox(height: 4),
                        Text('Homes & Villas', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('COMMERCIAL', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12)),
                        SizedBox(height: 4),
                        Text('Office & Retail', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Documents', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            const SizedBox(height: 4),
            Text('Verify ownership to proceed with legal clearances.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            const SizedBox(height: 16),
            _buildUploadBox(),
            const SizedBox(height: 24),
            const Text('UPLOADED FILES (2)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.grey, letterSpacing: 0.5)),
            const SizedBox(height: 12),
            _buildFileItem('plot_layout_final.pdf', '2.4 MB'),
            const SizedBox(height: 12),
            _buildFileItem('ownership_deed.jpg', '1.1 MB'),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_outlined, size: 16, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your data is encrypted. We only share details with verified architects and regulatory bodies for clearance.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E60FF),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text('START PROJECT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text('SAVE DRAFT', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, String helper) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.subdirectory_arrow_right, size: 12, color: Colors.grey.shade500),
            const SizedBox(width: 4),
            Text(helper, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
         color: const Color(0xFFFAFBFC),
         border: Border.all(color: const Color(0xFF1E60FF).withValues(alpha: 0.3), style: BorderStyle.solid), // Dotted border difficult, using slight solid
         borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF1E60FF)),
          ),
          const SizedBox(height: 16),
          const Text('Tap to upload blueprints', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('PDF, JPG or PNG (Max 10MB). Proof of ownership and plot maps required.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(height: 16),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
             decoration: BoxDecoration(
               border: Border.all(color: Colors.grey.shade400),
             ),
             child: const Text('Browse Files', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(String name, String size) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined, color: Color(0xFF1E60FF), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 2),
                Text(size, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
              ],
            ),
          ),
          const Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.black54),
          const SizedBox(width: 16),
          const Icon(Icons.delete_outline, size: 18, color: Colors.black54),
        ],
      ),
    );
  }
}
