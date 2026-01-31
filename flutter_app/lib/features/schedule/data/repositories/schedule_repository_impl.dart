import 'package:quran_gate_academy/features/schedule/data/services/schedule_service.dart';
import 'package:quran_gate_academy/features/schedule/domain/repositories/schedule_repository.dart';

/// Schedule repository implementation
class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleService scheduleService;

  ScheduleRepositoryImpl({required this.scheduleService});
}
