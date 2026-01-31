import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:quran_gate_academy/features/schedule/presentation/cubit/schedule_state.dart';

/// Schedule Cubit
class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository scheduleRepository;

  ScheduleCubit({required this.scheduleRepository}) : super(ScheduleInitial());
}
