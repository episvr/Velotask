import 'package:flutter/material.dart';
import 'package:velotask/models/todo.dart';
import 'package:velotask/theme/app_theme.dart';

class DialogInputRow extends StatelessWidget {
  final IconData icon;
  final Widget child;
  final bool isInput;

  const DialogInputRow({
    super.key,
    required this.icon,
    required this.child,
    this.isInput = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: isInput
              ? Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: child,
                )
              : child,
        ),
      ],
    );
  }
}

class TaskTypeSelector extends StatelessWidget {
  final TaskType selectedType;
  final Function(TaskType) onTypeChanged;

  const TaskTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildTypeTag(context, TaskType.ddl, 'DDL'),
        const SizedBox(width: 8),
        _buildTypeTag(context, TaskType.tdl, 'TDL'),
        const SizedBox(width: 8),
        _buildTypeTag(context, TaskType.wtd, 'WTD'),
      ],
    );
  }

  Widget _buildTypeTag(BuildContext context, TaskType type, String label) {
    final isSelected = selectedType == type;
    return InkWell(
      onTap: () => onTypeChanged(type),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.secondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class PrioritySelector extends StatelessWidget {
  final int selectedPriority;
  final Function(int) onPriorityChanged;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildPriorityTag(context, 0, 'Low', AppTheme.lowPriority),
        const SizedBox(width: 8),
        _buildPriorityTag(context, 1, 'Med', AppTheme.mediumPriority),
        const SizedBox(width: 8),
        _buildPriorityTag(context, 2, 'High', AppTheme.highPriority),
      ],
    );
  }

  Widget _buildPriorityTag(
    BuildContext context,
    int value,
    String label,
    Color color,
  ) {
    final isSelected = selectedPriority == value;
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return InkWell(
      onTap: () => onPriorityChanged(value),
      borderRadius: BorderRadius.circular(8),
      hoverColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : secondaryColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : secondaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DialogDatePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final Function(DateTime?) onSelect;
  final bool isOptional;

  const DialogDatePicker({
    super.key,
    required this.label,
    required this.date,
    required this.onSelect,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                datePickerTheme: DatePickerThemeData(
                  dayShape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              child: Transform.scale(
                scale: 0.9,
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(size: const Size(320, 400)),
                  child: child!,
                ),
              ),
            );
          },
        );
        onSelect(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: secondaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: secondaryColor, fontSize: 12)),
            Text(
              date == null
                  ? (isOptional ? '--/--' : 'Today')
                  : '${date!.month}/${date!.day}',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
