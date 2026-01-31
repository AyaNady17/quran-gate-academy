import 'package:quran_gate_academy/features/tasks/data/services/task_service.dart';
import 'package:quran_gate_academy/features/tasks/domain/repositories/task_repository.dart';

/// Task repository implementation
class TaskRepositoryImpl implements TaskRepository {
  final TaskService taskService;

  TaskRepositoryImpl({required this.taskService});
}
