import 'package:flutter/material.dart';

import '../../../core/bootstrap.dart';
import '../../../theme/colors.dart';
import '../../../theme/spacing.dart';
import '../models/habit.dart';
import '../models/habit_schedule.dart';
import '../models/habit_type.dart';

/// Screen for creating a new habit.
class HabitCreateScreen extends StatefulWidget {
  const HabitCreateScreen({super.key});

  @override
  State<HabitCreateScreen> createState() => _HabitCreateScreenState();
}

class _HabitCreateScreenState extends State<HabitCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _goalController = TextEditingController();
  final _descriptionController = TextEditingController();

  HabitType _selectedType = HabitType.learning;
  HabitFrequency _frequency = HabitFrequency.daily;
  int _targetPerDay = 1;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final svc = AppBootstrap.maybeHabitService;
    if (svc == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit service is loading. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    final now = DateTime.now();
    final habit = Habit(
      id: 'hb-${now.millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      type: _selectedType,
      schedule: HabitSchedule(frequency: _frequency),
      targetPerDay: _targetPerDay,
      goal: _goalController.text.trim().isEmpty
          ? null
          : _goalController.text.trim(),
      createdAt: now,
      isActive: true,
    );

    await svc.createHabit(habit);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${habit.title}" created!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'What habit do you want to build?',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Habit Title',
                  hintText: 'e.g. Morning Run, Read 20 Pages',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.checklist_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter a habit title' : null,
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Why is this habit important?',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_rounded),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Type
              Text(
                'Category',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: HabitType.values.map((type) {
                  final selected = _selectedType == type;
                  final color = _typeColor(type);
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_typeIcon(type), size: 16, color: selected ? Colors.white : color),
                        const SizedBox(width: 4),
                        Text(type.label),
                      ],
                    ),
                    selected: selected,
                    selectedColor: color,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                    ),
                    onSelected: (v) => setState(() => _selectedType = type),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Frequency
              Text(
                'Frequency',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<HabitFrequency>(
                initialValue: _frequency,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.repeat_rounded),
                ),
                items: HabitFrequency.values.map((f) {
                  return DropdownMenuItem(
                    value: f,
                    child: Text(f.label),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _frequency = v);
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Target per day
              Text(
                'Target per day',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    onPressed: _targetPerDay > 1
                        ? () => setState(() => _targetPerDay--)
                        : null,
                  ),
                  Text(
                    '$_targetPerDay',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    onPressed: _targetPerDay < 10
                        ? () => setState(() => _targetPerDay++)
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'time${_targetPerDay > 1 ? 's' : ''} per day',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Goal
              TextFormField(
                controller: _goalController,
                decoration: const InputDecoration(
                  labelText: 'Long-term goal (optional)',
                  hintText: 'e.g. Run a marathon, Read 50 books',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_rounded),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_isSaving ? 'Creating...' : 'Create Habit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _typeColor(HabitType type) {
    switch (type) {
      case HabitType.learning:
        return AppColors.primary;
      case HabitType.health:
        return Colors.red;
      case HabitType.exercise:
        return Colors.orange;
      case HabitType.reading:
        return Colors.indigo;
      case HabitType.meditation:
        return Colors.teal;
      case HabitType.coding:
        return Colors.blue;
      case HabitType.career:
        return const Color(0xFF7C3AED);
      case HabitType.finance:
        return Colors.green;
      case HabitType.productivity:
        return Colors.amber;
      case HabitType.family:
        return Colors.pink;
      case HabitType.custom:
        return Colors.grey;
    }
  }

  IconData _typeIcon(HabitType type) {
    switch (type) {
      case HabitType.learning:
        return Icons.school_rounded;
      case HabitType.health:
        return Icons.favorite_rounded;
      case HabitType.exercise:
        return Icons.fitness_center_rounded;
      case HabitType.reading:
        return Icons.menu_book_rounded;
      case HabitType.meditation:
        return Icons.self_improvement_rounded;
      case HabitType.coding:
        return Icons.code_rounded;
      case HabitType.career:
        return Icons.work_rounded;
      case HabitType.finance:
        return Icons.account_balance_rounded;
      case HabitType.productivity:
        return Icons.checklist_rounded;
      case HabitType.family:
        return Icons.family_restroom_rounded;
      case HabitType.custom:
        return Icons.star_rounded;
    }
  }
}
