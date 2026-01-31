import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/features/tasks/domain/repositories/task_repository.dart';
import 'package:quran_gate_academy/features/tasks/presentation/cubit/task_state.dart';

/// Task Cubit
class TaskCubit extends Cubit<TaskState> {
  final TaskRepository taskRepository;

  TaskCubit({required this.taskRepository}) : super(TaskInitial());
}
