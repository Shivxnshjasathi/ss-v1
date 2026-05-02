import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/profile/data/document_repository.dart';
import 'package:sampatti_bazar/features/profile/domain/document_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final user = ref.read(currentUserDataProvider).value;
    if (user == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isUploading = true);
      try {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        
        // Determine type based on extension
        final ext = fileName.split('.').last.toLowerCase();
        final type = (ext == 'pdf' || ext == 'doc' || ext == 'docx') ? 'Document' : 'Image';

        await ref.read(documentRepositoryProvider).uploadDocument(
          userId: user.uid,
          file: file,
          fileName: fileName,
          type: type,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document uploaded successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);
    
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text('My Documents', style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900, fontSize: 20.sp)),
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Please log in'));
          
          final docsAsync = ref.watch(userDocumentsProvider(user.uid));
          
          return docsAsync.when(
            data: (docs) {
              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_rounded, size: 64.w, color: context.secondaryTextColor.withValues(alpha: 0.2)),
                      SizedBox(height: 16.h),
                      Text('No documents yet', style: TextStyle(color: context.secondaryTextColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(24.w),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return _DocumentTile(doc: doc);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
            error: (err, _) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isUploading ? null : _pickAndUpload,
        backgroundColor: AppTheme.primaryBlue,
        icon: _isUploading 
          ? SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Icon(Icons.add, color: Colors.white),
        label: Text(_isUploading ? 'UPLOADING...' : 'UPLOAD DOCUMENT', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11.sp, letterSpacing: 0.5)),
      ),
    );
  }
}

class _DocumentTile extends ConsumerWidget {
  final DocumentModel doc;
  const _DocumentTile({required this.doc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPdf = doc.name.toLowerCase().endsWith('.pdf');
    final dateStr = DateFormat('MMM dd, yyyy').format(doc.uploadedAt);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isPdf ? Colors.red.withValues(alpha: 0.1) : AppTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.description, 
              color: isPdf ? Colors.red : AppTheme.primaryBlue, 
              size: 20.w
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.name, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis, 
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp, color: context.primaryTextColor)),
                SizedBox(height: 4.h),
                Text('${doc.type} • $dateStr', 
                  style: TextStyle(color: context.secondaryTextColor, fontSize: 11.sp, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.open_in_new_rounded, color: AppTheme.primaryBlue, size: 20.w),
                onPressed: () => launchUrl(Uri.parse(doc.url)),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20.w),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: const Text('Are you sure you want to delete this document?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(documentRepositoryProvider).deleteDocument(doc.id, doc.url);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
