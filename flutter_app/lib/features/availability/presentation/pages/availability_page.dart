import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_gate_academy/core/di/injection.dart';
import 'package:quran_gate_academy/core/models/availability_model.dart';
import 'package:quran_gate_academy/core/theme/app_theme.dart';
import 'package:quran_gate_academy/core/widgets/app_sidebar.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:quran_gate_academy/features/auth/presentation/cubit/auth_state.dart';
import 'package:quran_gate_academy/features/availability/presentation/cubit/availability_cubit.dart';
import 'package:quran_gate_academy/features/availability/presentation/cubit/availability_state.dart';

/// Availability Management Page for Teachers
class AvailabilityPage extends StatelessWidget {
  const AvailabilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    return BlocProvider(
      create: (context) => getIt<AvailabilityCubit>()
        ..loadAvailability(teacherId: authState.user.id),
      child: const _AvailabilityView(),
    );
  }
}

class _AvailabilityView extends StatelessWidget {
  const _AvailabilityView();

  static const List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(currentRoute: '/availability'),
          Expanded(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildAvailabilityGrid(context)),
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
            Icons.calendar_month,
            size: 32,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Availability',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
              Text(
                'Manage your weekly teaching schedule',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
            ],
          ),
          const Spacer(),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              return IconButton(
                onPressed: () {
                  if (authState is AuthAuthenticated) {
                    context
                        .read<AvailabilityCubit>()
                        .loadAvailability(teacherId: authState.user.id);
                  }
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityGrid(BuildContext context) {
    return BlocConsumer<AvailabilityCubit, AvailabilityState>(
      listener: (context, state) {
        if (state is AvailabilitySlotCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Availability slot added successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload availability
          final authState = context.read<AuthCubit>().state;
          if (authState is AuthAuthenticated) {
            context
                .read<AvailabilityCubit>()
                .loadAvailability(teacherId: authState.user.id);
          }
        } else if (state is AvailabilitySlotDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Availability slot removed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Reload availability
          final authState = context.read<AuthCubit>().state;
          if (authState is AuthAuthenticated) {
            context
                .read<AvailabilityCubit>()
                .loadAvailability(teacherId: authState.user.id);
          }
        } else if (state is AvailabilityError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is AvailabilityLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AvailabilityLoaded) {
          return _buildWeeklySchedule(context, state.slots);
        }

        if (state is AvailabilityError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final authState = context.read<AuthCubit>().state;
                    if (authState is AuthAuthenticated) {
                      context
                          .read<AvailabilityCubit>()
                          .loadAvailability(teacherId: authState.user.id);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('No availability data'));
      },
    );
  }

  Widget _buildWeeklySchedule(
      BuildContext context, List<AvailabilityModel> slots) {
    // Group slots by day of week
    final slotsByDay = <String, List<AvailabilityModel>>{};
    for (final day in _daysOfWeek) {
      slotsByDay[day] = slots.where((slot) => slot.dayOfWeek == day).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Schedule',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ...slotsByDay.entries.map((entry) {
                return _buildDayRow(context, entry.key, entry.value);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayRow(
      BuildContext context, String day, List<AvailabilityModel> slots) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                day,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddSlotDialog(context, day),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Slot'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (slots.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No availability slots for this day',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  slots.map((slot) => _buildSlotChip(context, slot)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSlotChip(BuildContext context, AvailabilityModel slot) {
    return Chip(
      label: Text('${slot.startTime} - ${slot.endTime}'),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _confirmDeleteSlot(context, slot),
    );
  }

  void _showAddSlotDialog(BuildContext context, String day) {
    final startTimeController = TextEditingController(text: '09:00');
    final endTimeController = TextEditingController(text: '10:00');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add Availability Slot - $day'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: startTimeController,
              decoration: const InputDecoration(
                labelText: 'Start Time (HH:mm)',
                border: OutlineInputBorder(),
                hintText: '09:00',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: endTimeController,
              decoration: const InputDecoration(
                labelText: 'End Time (HH:mm)',
                border: OutlineInputBorder(),
                hintText: '10:00',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                context.read<AvailabilityCubit>().createSlot(
                      teacherId: authState.user.id,
                      dayOfWeek: day,
                      startTime: startTimeController.text,
                      endTime: endTimeController.text,
                    );
              }
              Navigator.of(dialogContext).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSlot(BuildContext context, AvailabilityModel slot) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Availability Slot'),
        content: Text(
          'Are you sure you want to delete the ${slot.dayOfWeek} slot from ${slot.startTime} to ${slot.endTime}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AvailabilityCubit>().deleteSlot(slot.id);
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
}
