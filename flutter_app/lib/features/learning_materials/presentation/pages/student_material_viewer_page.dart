import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/learning_material_model.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_cubit.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_state.dart';
import 'package:url_launcher/url_launcher.dart';

/// Student Material Viewer Page - View and interact with learning materials
class StudentMaterialViewerPage extends StatelessWidget {
  final String materialId;

  const StudentMaterialViewerPage({
    super.key,
    required this.materialId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LearningMaterialCubit>()..loadMaterial(materialId),
      child: _StudentMaterialViewerContent(materialId: materialId),
    );
  }
}

class _StudentMaterialViewerContent extends StatelessWidget {
  final String materialId;

  const _StudentMaterialViewerContent({required this.materialId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/learning-materials'),
          Expanded(
            child: BlocBuilder<LearningMaterialCubit, LearningMaterialState>(
              builder: (context, state) {
                if (state is LearningMaterialLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is LearningMaterialDetailLoaded) {
                  return _buildMaterialViewer(context, state.material);
                }

                if (state is LearningMaterialError) {
                  return _buildErrorState(context, state.message);
                }

                return const Center(child: Text('Material not found'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialViewer(BuildContext context, LearningMaterialModel material) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, material),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Material Preview/Viewer
                _buildMaterialPreview(context, material),

                const SizedBox(height: 32),

                // Material Info
                _buildMaterialInfo(context, material),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LearningMaterialModel material) {
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
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                ),
                Row(
                  children: [
                    _buildTypeChip(material.type),
                    if (material.category != null) ...[
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          material.category!,
                          style: const TextStyle(fontSize: 12),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
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

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        type.toUpperCase(),
        style: TextStyle(fontSize: 12, color: color),
      ),
      visualDensity: VisualDensity.compact,
      backgroundColor: color.withOpacity(0.1),
    );
  }

  Widget _buildMaterialPreview(BuildContext context, LearningMaterialModel material) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 600),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getTypeIcon(material.type),
            size: 64,
            color: _getTypeColor(material.type),
          ),
          const SizedBox(height: 16),
          Text(
            'Click below to open this ${material.type} file',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _openMaterial(context, material),
            icon: const Icon(Icons.open_in_new),
            label: Text('Open ${material.type.toUpperCase()}'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _downloadMaterial(context, material),
            icon: const Icon(Icons.download),
            label: const Text('Download File'),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialInfo(BuildContext context, LearningMaterialModel material) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Material Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            if (material.description != null && material.description!.isNotEmpty) ...[
              _buildInfoRow('Description', material.description!),
              const Divider(),
            ],

            if (material.fileSize != null)
              _buildInfoRow(
                'File Size',
                '${(material.fileSize! / 1024 / 1024).toStringAsFixed(2)} MB',
              ),
            const Divider(),

            _buildInfoRow('Views', '${material.viewCount}'),
            const Divider(),

            if (material.publishedAt != null)
              _buildInfoRow(
                'Published',
                _formatDate(material.publishedAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimaryColor,
              ),
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
            'Error Loading Material',
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
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'video':
        return Icons.video_library;
      case 'audio':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'video':
        return Colors.blue;
      case 'audio':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _openMaterial(BuildContext context, LearningMaterialModel material) async {
    if (material.fileId == null) {
      _showError(context, 'File not available');
      return;
    }

    try {
      // Get the file view URL from the storage
      final cubit = context.read<LearningMaterialCubit>();
      final fileUrl = await cubit.learningMaterialRepository.getFileViewUrl(material.fileId!);

      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showError(context, 'Cannot open this file type');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error opening file: ${e.toString()}');
      }
    }
  }

  Future<void> _downloadMaterial(BuildContext context, LearningMaterialModel material) async {
    if (material.fileId == null) {
      _showError(context, 'File not available');
      return;
    }

    try {
      // Get the file download URL from the storage
      final cubit = context.read<LearningMaterialCubit>();
      final downloadUrl = await cubit.learningMaterialRepository.getFileDownloadUrl(material.fileId!);

      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          _showSuccess(context, 'Download started');
        }
      } else {
        if (context.mounted) {
          _showError(context, 'Cannot download this file');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error downloading file: ${e.toString()}');
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
