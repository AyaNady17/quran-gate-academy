import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:quran_gate_academy/core/models/learning_material_model.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_cubit.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_state.dart';
import 'package:url_launcher/url_launcher.dart';

/// Material detail page showing full information and preview
class LearningMaterialDetailPage extends StatelessWidget {
  final String materialId;

  const LearningMaterialDetailPage({
    super.key,
    required this.materialId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = GetIt.I<LearningMaterialCubit>();
        cubit.loadMaterial(materialId);
        return cubit;
      },
      child: Scaffold(
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
                    return _buildDetailContent(context, state.material);
                  }

                  if (state is LearningMaterialError) {
                    return _buildErrorState(context, state.message);
                  }

                  return const Center(child: Text('Loading material...'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailContent(
      BuildContext context, LearningMaterialModel material) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, material),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMaterialInfo(context, material),
                const SizedBox(height: 32),
                _buildDescription(context, material),
                const SizedBox(height: 32),
                _buildMetadata(context, material),
                if (material.tags.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildTags(context, material),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LearningMaterialModel material) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getTypeColor(material.type),
            _getTypeColor(material.type).withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getTypeIcon(material.type),
                              size: 16, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            material.type.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      material.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (material.category != null &&
                        material.category!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        material.category!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialInfo(
      BuildContext context, LearningMaterialModel material) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            children: [
              Icon(_getTypeIcon(material.type),
                  size: 64, color: _getTypeColor(material.type)),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Material Information',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        context, Icons.storage, 'Size', material.fileSizeFormatted),
                    _buildInfoRow(context, Icons.visibility, 'Views',
                        '${material.viewCount}'),
                    if (material.publishedAt != null)
                      _buildInfoRow(
                        context,
                        Icons.calendar_today,
                        'Published',
                        DateFormat('MMM dd, yyyy').format(material.publishedAt!),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (material.fileUrl != null && material.fileUrl!.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openMaterial(material.fileUrl!),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Material'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getTypeColor(material.type),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(
      BuildContext context, LearningMaterialModel material) {
    if (material.description == null || material.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            material.description!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, LearningMaterialModel material) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildMetadataRow(context, 'Type', material.type.toUpperCase()),
          if (material.category != null && material.category!.isNotEmpty)
            _buildMetadataRow(context, 'Category', material.category!),
          _buildMetadataRow(context, 'File Size', material.fileSizeFormatted),
          _buildMetadataRow(context, 'Views', '${material.viewCount}'),
          _buildMetadataRow(context, 'Status', material.status.toUpperCase()),
          if (material.publishedAt != null)
            _buildMetadataRow(
              context,
              'Published',
              DateFormat('MMMM dd, yyyy').format(material.publishedAt!),
            ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(BuildContext context, LearningMaterialModel material) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tags',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: material.tags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: _getTypeColor(material.type).withValues(alpha: 0.1),
                labelStyle: TextStyle(color: _getTypeColor(material.type)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading material',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
            ),
          ],
        ),
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
        return Colors.purple;
      case 'audio':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Future<void> _openMaterial(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
