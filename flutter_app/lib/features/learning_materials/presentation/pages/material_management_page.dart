import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/course_model.dart';
import 'package:quran_gate_academy/core/models/learning_material_model.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/utils/web_file_picker.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_cubit.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_state.dart';

/// Material Management Page - For admins to upload and manage learning materials
class MaterialManagementPage extends StatelessWidget {
  const MaterialManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LearningMaterialCubit>()..loadMaterials(),
      child: const _MaterialManagementContent(),
    );
  }
}

class _MaterialManagementContent extends StatefulWidget {
  const _MaterialManagementContent();

  @override
  State<_MaterialManagementContent> createState() =>
      _MaterialManagementContentState();
}

class _MaterialManagementContentState
    extends State<_MaterialManagementContent> {
  String? _selectedType;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/materials-management'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                _buildFilters(context),
                Expanded(child: _buildMaterialsList(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.library_books,
            size: 32,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learning Materials Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
              Text(
                'Upload and manage course materials',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              context.read<LearningMaterialCubit>().loadMaterials();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showUploadDialog(context),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Material'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Filter by Type',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Types')),
                DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                DropdownMenuItem(value: 'video', child: Text('Video')),
                DropdownMenuItem(value: 'audio', child: Text('Audio')),
                DropdownMenuItem(value: 'document', child: Text('Document')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
                _applyFilters();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Filter by Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Categories')),
                DropdownMenuItem(value: 'Quran Recitation', child: Text('Quran Recitation')),
                DropdownMenuItem(value: 'Tajweed', child: Text('Tajweed')),
                DropdownMenuItem(value: 'Memorization', child: Text('Memorization')),
                DropdownMenuItem(value: 'Tafsir', child: Text('Tafsir')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
                _applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(BuildContext context) {
    return BlocConsumer<LearningMaterialCubit, LearningMaterialState>(
      listener: (context, state) {
        if (state is LearningMaterialCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Material uploaded successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<LearningMaterialCubit>().loadMaterials();
        } else if (state is LearningMaterialDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Material deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          context.read<LearningMaterialCubit>().loadMaterials();
        } else if (state is LearningMaterialError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is LearningMaterialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LearningMaterialsLoaded) {
          if (state.materials.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildMaterialsTable(context, state.materials);
        }

        if (state is LearningMaterialError) {
          return _buildErrorState(context, state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMaterialsTable(
      BuildContext context, List<LearningMaterialModel> materials) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<LearningMaterialCubit>().loadMaterials();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Course')),
                DataColumn(label: Text('File Size')),
                DataColumn(label: Text('Views')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: materials.map((material) {
                return DataRow(cells: [
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        material.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(_buildTypeChip(material.type)),
                  DataCell(Text(material.category ?? '-')),
                  DataCell(Text(material.courseId ?? 'All Courses')),
                  DataCell(Text(_formatFileSize(material.fileSize ?? 0))),
                  DataCell(Text(material.viewCount.toString())),
                  DataCell(_buildStatusChip(material.status)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility, size: 20),
                          onPressed: () {
                            // TODO: Open material preview
                          },
                          tooltip: 'View',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          color: AppTheme.errorColor,
                          onPressed: () {
                            _confirmDelete(context, material);
                          },
                          tooltip: 'Delete',
                        ),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'video':
        icon = Icons.video_library;
        color = Colors.blue;
        break;
      case 'audio':
        icon = Icons.audio_file;
        color = Colors.purple;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(type.toUpperCase()),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    final color = status == 'published' ? Colors.green : Colors.grey;
    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(fontSize: 10),
      ),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 64,
            color: AppTheme.textSecondaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Learning Materials Found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your first learning material to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Materials',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.errorColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<LearningMaterialCubit>().loadMaterials();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    context.read<LearningMaterialCubit>().loadMaterials(
          type: _selectedType,
          category: _selectedCategory,
        );
  }

  void _confirmDelete(BuildContext context, LearningMaterialModel material) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text(
          'Are you sure you want to delete "${material.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context
                  .read<LearningMaterialCubit>()
                  .deleteMaterial(material.id, material.fileId ?? '');
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showUploadDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<LearningMaterialCubit>(),
        child: _UploadMaterialDialog(),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class _UploadMaterialDialog extends StatefulWidget {
  @override
  State<_UploadMaterialDialog> createState() => _UploadMaterialDialogState();
}

class _UploadMaterialDialogState extends State<_UploadMaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedType;
  String? _selectedCategory;
  String? _selectedCourseId;
  List<int>? _fileBytes;
  String? _fileName;
  bool _isLoading = false;
  List<CourseModel> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final coursesData =
          await context.read<LearningMaterialCubit>().getAllCourses();
      setState(() {
        _courses = coursesData.map((data) => CourseModel.fromJson(data)).toList();
      });
    } catch (e) {
      // Silently fail - courses dropdown will remain empty
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      if (kIsWeb) {
        // Use our custom web file picker for web
        final result = await WebFilePicker.pickFile();

        if (result != null) {
          setState(() {
            _fileBytes = result.bytes;
            _fileName = result.name;

            // Auto-detect type from extension
            final extension = result.extension;
            if (extension == 'pdf') {
              _selectedType = 'pdf';
            } else if (extension == 'mp4' || extension == 'avi' || extension == 'mov') {
              _selectedType = 'video';
            } else if (extension == 'mp3' || extension == 'wav' || extension == 'm4a') {
              _selectedType = 'audio';
            } else {
              _selectedType = 'document';
            }
          });
        }
      } else {
        // Use regular file_picker for mobile/desktop
        final result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          withData: true,
        );

        if (result != null && result.files.single.bytes != null) {
          setState(() {
            _fileBytes = result.files.single.bytes!;
            _fileName = result.files.single.name;

            // Auto-detect type from extension
            final extension = result.files.single.extension?.toLowerCase();
            if (extension == 'pdf') {
              _selectedType = 'pdf';
            } else if (extension == 'mp4' || extension == 'avi' || extension == 'mov') {
              _selectedType = 'video';
            } else if (extension == 'mp3' || extension == 'wav' || extension == 'm4a') {
              _selectedType = 'audio';
            } else {
              _selectedType = 'document';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadMaterial() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file to upload'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authState = context.read<AuthCubit>().state;
    String uploadedBy = 'admin';
    if (authState is AuthAuthenticated) {
      uploadedBy = authState.user.id;
    }

    context.read<LearningMaterialCubit>().createMaterial(
          title: _titleController.text.trim(),
          type: _selectedType!,
          fileBytes: _fileBytes!,
          fileName: _fileName!,
          uploadedBy: uploadedBy,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _selectedCategory,
          courseId: _selectedCourseId,
        );

    // Wait a bit for the cubit to emit the state
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Learning Material'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // File Picker
                InkWell(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _fileName ?? 'Click to select file',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Type
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                    DropdownMenuItem(value: 'video', child: Text('Video')),
                    DropdownMenuItem(value: 'audio', child: Text('Audio')),
                    DropdownMenuItem(value: 'document', child: Text('Document')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('None')),
                    DropdownMenuItem(
                        value: 'Quran Recitation', child: Text('Quran Recitation')),
                    DropdownMenuItem(value: 'Tajweed', child: Text('Tajweed')),
                    DropdownMenuItem(
                        value: 'Memorization', child: Text('Memorization')),
                    DropdownMenuItem(value: 'Tafsir', child: Text('Tafsir')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Course
                DropdownButtonFormField<String>(
                  value: _selectedCourseId,
                  decoration: const InputDecoration(
                    labelText: 'Course (optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Courses')),
                    ..._courses.map((course) {
                      return DropdownMenuItem(
                        value: course.id,
                        child: Text(course.title),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCourseId = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _uploadMaterial,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Upload'),
        ),
      ],
    );
  }
}
