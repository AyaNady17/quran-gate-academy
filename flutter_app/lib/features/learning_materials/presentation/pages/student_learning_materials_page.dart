import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/learning_material_model.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_cubit.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_state.dart';

/// Student Learning Materials Page - Shows learning materials for enrolled courses
class StudentLearningMaterialsPage extends StatelessWidget {
  const StudentLearningMaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LearningMaterialCubit>()..loadMaterials(),
      child: const _StudentLearningMaterialsContent(),
    );
  }
}

class _StudentLearningMaterialsContent extends StatefulWidget {
  const _StudentLearningMaterialsContent();

  @override
  State<_StudentLearningMaterialsContent> createState() =>
      _StudentLearningMaterialsContentState();
}

class _StudentLearningMaterialsContentState
    extends State<_StudentLearningMaterialsContent> {
  String? _selectedType;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/learning-materials'),
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
                'Learning Materials',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
              Text(
                'Access your course materials',
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All Categories')),
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
                _applyFilters();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList(BuildContext context) {
    return BlocBuilder<LearningMaterialCubit, LearningMaterialState>(
      builder: (context, state) {
        if (state is LearningMaterialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LearningMaterialsLoaded) {
          if (state.materials.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildMaterialsGrid(context, state.materials);
        }

        if (state is LearningMaterialError) {
          return _buildErrorState(context, state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMaterialsGrid(
      BuildContext context, List<LearningMaterialModel> materials) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<LearningMaterialCubit>().loadMaterials();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: materials.length,
        itemBuilder: (context, index) {
          return _buildMaterialCard(context, materials[index]);
        },
      ),
    );
  }

  Widget _buildMaterialCard(
      BuildContext context, LearningMaterialModel material) {
    IconData icon;
    Color color;

    switch (material.type.toLowerCase()) {
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

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          context.go('/learning-materials/${material.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                material.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              if (material.category != null)
                Chip(
                  label: Text(
                    material.category!,
                    style: const TextStyle(fontSize: 10),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.visibility, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${material.viewCount} views',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
            'Materials will appear here when your teacher uploads them',
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
}
