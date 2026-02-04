import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:file_picker/file_picker.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_cubit.dart';
import 'package:appwrite/appwrite.dart';
import 'dart:typed_data';

/// Material management page for uploading and managing learning materials
class MaterialManagementPage extends StatefulWidget {
  const MaterialManagementPage({super.key});

  @override
  State<MaterialManagementPage> createState() => _MaterialManagementPageState();
}

class _MaterialManagementPageState extends State<MaterialManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();

  String? _selectedType;
  String? _selectedStatus = AppConfig.materialStatusPublished;
  String? _selectedCourseId;

  Uint8List? _fileBytes;
  String? _fileName;
  int? _fileSize;

  bool _isUploading = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _fileBytes = file.bytes;
          _fileName = file.name;
          _fileSize = file.size;
          _error = null;

          // Auto-detect type from extension
          if (file.extension != null) {
            final ext = file.extension!.toLowerCase();
            if (ext == 'pdf') {
              _selectedType = AppConfig.materialTypePdf;
            } else if (['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext)) {
              _selectedType = AppConfig.materialTypeVideo;
            } else if (['mp3', 'wav', 'ogg', 'm4a'].contains(ext)) {
              _selectedType = AppConfig.materialTypeAudio;
            } else if (['doc', 'docx', 'txt', 'ppt', 'pptx'].contains(ext)) {
              _selectedType = AppConfig.materialTypeDocument;
            }
          }
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick file: $e';
      });
    }
  }

  Future<void> _uploadMaterial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fileBytes == null) {
      setState(() {
        _error = 'Please select a file to upload';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _error = null;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      if (authState is! AuthAuthenticated) {
        throw Exception('Not authenticated');
      }

      final storage = AppConfig.storage;
      final databases = AppConfig.databases;

      // Upload file to Appwrite Storage
      final file = await storage.createFile(
        bucketId: AppConfig.learningMaterialsBucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: _fileBytes!,
          filename: _fileName!,
        ),
      );

      // Get file URL
      final fileUrl = '${AppConfig.appwriteEndpoint}/storage/buckets/${AppConfig.learningMaterialsBucketId}/files/${file.$id}/view?project=${AppConfig.appwriteProjectId}';

      // Parse tags
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      // Create material document
      await databases.createDocument(
        databaseId: AppConfig.appwriteDatabaseId,
        collectionId: AppConfig.learningMaterialsCollectionId,
        documentId: ID.unique(),
        data: {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category': _categoryController.text.trim(),
          'type': _selectedType,
          'fileUrl': fileUrl,
          'fileId': file.$id,
          'fileSize': _fileSize,
          'courseId': _selectedCourseId ?? '',
          'uploadedBy': authState.user.id,
          'status': _selectedStatus,
          'tags': tags.toString(),
          'viewCount': 0,
          'publishedAt': _selectedStatus == AppConfig.materialStatusPublished
              ? DateTime.now().toIso8601String()
              : null,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Material uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh materials list
        GetIt.I<LearningMaterialCubit>().loadMaterials();

        // Reset form
        _formKey.currentState!.reset();
        setState(() {
          _titleController.clear();
          _descriptionController.clear();
          _categoryController.clear();
          _tagsController.clear();
          _fileBytes = null;
          _fileName = null;
          _fileSize = null;
          _selectedType = null;
          _selectedCourseId = null;
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Upload failed: $e';
        _isUploading = false;
      });
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/materials/manage'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildUploadForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Learning Material',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload and manage learning materials for students',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  Widget _buildUploadForm() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File picker
            InkWell(
              onTap: _isUploading ? null : _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _fileBytes != null ? Colors.green : Colors.grey[300]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: Column(
                  children: [
                    Icon(
                      _fileBytes != null ? Icons.check_circle : Icons.cloud_upload,
                      size: 48,
                      color: _fileBytes != null ? Colors.green : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _fileBytes != null
                          ? 'File Selected: $_fileName'
                          : 'Click to select a file',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    if (_fileBytes != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Size: ${_formatFileSize(_fileSize!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ] else
                      const SizedBox(height: 8),
                    Text(
                      'Supported: PDF, Videos (MP4, MOV), Audio (MP3, WAV), Documents',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter material title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter material description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            // Category
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g., Quran Recitation, Tajweed, Arabic',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Type dropdown
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'pdf',
                  child: Text('PDF'),
                ),
                DropdownMenuItem(
                  value: 'video',
                  child: Text('Video'),
                ),
                DropdownMenuItem(
                  value: 'audio',
                  child: Text('Audio'),
                ),
                DropdownMenuItem(
                  value: 'document',
                  child: Text('Document'),
                ),
              ],
              onChanged: _isUploading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
              validator: (value) {
                if (value == null) {
                  return 'Type is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Status dropdown
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'published',
                  child: Text('Published'),
                ),
                DropdownMenuItem(
                  value: 'draft',
                  child: Text('Draft'),
                ),
              ],
              onChanged: _isUploading
                  ? null
                  : (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
            ),
            const SizedBox(height: 16),

            // Course ID (TODO: Replace with course selector)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Course ID (Optional)',
                hintText: 'Enter course ID for course-specific access',
                border: OutlineInputBorder(),
                helperText: 'Leave empty for all students to access',
              ),
              onChanged: (value) {
                setState(() {
                  _selectedCourseId = value.trim().isEmpty ? null : value.trim();
                });
              },
            ),
            const SizedBox(height: 16),

            // Tags
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags',
                hintText: 'Separate tags with commas (e.g., beginner, tajweed, quran)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Error message
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadMaterial,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.upload),
                label: Text(_isUploading ? 'Uploading...' : 'Upload Material'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
