import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:quran_gate_academy/core/config/app_config.dart';
import 'package:quran_gate_academy/core/models/learning_material_model.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_cubit.dart';
import 'package:quran_gate_academy/features/learning_materials/presentation/cubit/learning_material_state.dart';
import 'package:go_router/go_router.dart';

/// Learning materials library page
class LearningMaterialsPage extends StatefulWidget {
  const LearningMaterialsPage({super.key});

  @override
  State<LearningMaterialsPage> createState() => _LearningMaterialsPageState();
}

class _LearningMaterialsPageState extends State<LearningMaterialsPage> {
  String? _selectedType;
  final _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = GetIt.I<LearningMaterialCubit>();
        _loadMaterialsForStudent(cubit);
        return cubit;
      },
      child: Scaffold(
        body: Row(
          children: [
            const AppSidebar(currentRoute: '/learning-materials'),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(context),
                  _buildFilters(context),
                  Expanded(
                    child: BlocConsumer<LearningMaterialCubit,
                        LearningMaterialState>(
                      listener: (context, state) {
                        if (state is LearningMaterialError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is LearningMaterialLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (state is LearningMaterialsLoaded) {
                          if (state.materials.isEmpty) {
                            return _buildEmptyState();
                          }

                          return RefreshIndicator(
                            onRefresh: () => _refreshMaterials(context),
                            child: _isGridView
                                ? _buildGridView(state.materials)
                                : _buildListView(state.materials),
                          );
                        }

                        if (state is LearningMaterialError) {
                          return _buildErrorState(context, state.message);
                        }

                        return const Center(
                            child: Text('Welcome to Learning Materials'));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Materials',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Browse study materials and resources',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search materials...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters(context);
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onSubmitted: (_) => _applyFilters(context),
          ),
          const SizedBox(height: 12),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  'All Types',
                  _selectedType == null,
                  () {
                    setState(() => _selectedType = null);
                    _applyFilters(context);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'PDF',
                  _selectedType == AppConfig.materialTypePdf,
                  () {
                    setState(() => _selectedType = AppConfig.materialTypePdf);
                    _applyFilters(context);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Video',
                  _selectedType == AppConfig.materialTypeVideo,
                  () {
                    setState(() => _selectedType = AppConfig.materialTypeVideo);
                    _applyFilters(context);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Audio',
                  _selectedType == AppConfig.materialTypeAudio,
                  () {
                    setState(() => _selectedType = AppConfig.materialTypeAudio);
                    _applyFilters(context);
                  },
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Document',
                  _selectedType == AppConfig.materialTypeDocument,
                  () {
                    setState(() =>
                        _selectedType = AppConfig.materialTypeDocument);
                    _applyFilters(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildGridView(List<LearningMaterialModel> materials) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        return _buildMaterialCard(materials[index]);
      },
    );
  }

  Widget _buildListView(List<LearningMaterialModel> materials) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        return _buildMaterialListTile(materials[index]);
      },
    );
  }

  Widget _buildMaterialCard(LearningMaterialModel material) {
    return InkWell(
      onTap: () => _openMaterial(material.id),
      child: Container(
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
            // Thumbnail or type icon
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: _getTypeColor(material.type).withValues(alpha: 0.1),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Center(
                child: Icon(
                  _getTypeIcon(material.type),
                  size: 64,
                  color: _getTypeColor(material.type),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (material.description != null &&
                        material.description!.isNotEmpty)
                      Text(
                        material.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          material.fileSizeFormatted,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.visibility,
                                size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              '${material.viewCount}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialListTile(LearningMaterialModel material) {
    return InkWell(
      onTap: () => _openMaterial(material.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getTypeColor(material.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTypeIcon(material.type),
                size: 32,
                color: _getTypeColor(material.type),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (material.description != null &&
                      material.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      material.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        material.fileSizeFormatted,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.visibility, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '${material.viewCount}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No materials found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
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
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading materials',
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
            onPressed: () => _refreshMaterials(context),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
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
        return Colors.purple;
      case 'audio':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Future<void> _loadMaterialsForStudent(LearningMaterialCubit cubit) async {
    // TODO: Implement course-based filtering when PlanRepository is available
    // For now, load all published materials
    await cubit.loadMaterials(
      category: null,
      type: _selectedType,
    );
  }

  void _applyFilters(BuildContext context) {
    final cubit = context.read<LearningMaterialCubit>();
    final query = _searchController.text.trim();

    if (query.isNotEmpty) {
      cubit.searchMaterials(query);
    } else {
      _loadMaterialsForStudent(cubit);
    }
  }

  Future<void> _refreshMaterials(BuildContext context) async {
    final cubit = context.read<LearningMaterialCubit>();
    await _loadMaterialsForStudent(cubit);
  }

  void _openMaterial(String materialId) {
    context.go('/learning-materials/$materialId');
  }
}
