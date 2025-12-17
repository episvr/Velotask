import 'package:flutter/material.dart';
import 'package:velotask/models/todo_filter.dart';

class FilterSection extends StatelessWidget {
  final TodoFilter currentFilter;
  final Function(TodoFilter) onFilterChanged;

  const FilterSection({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            _buildFilterChip(context, 'Active', TodoFilter.active),
            const SizedBox(width: 8),
            _buildFilterChip(context, 'All', TodoFilter.all),
            const SizedBox(width: 8),
            _buildFilterChip(context, 'Done', TodoFilter.completed),
            const SizedBox(width: 8),
            _buildFilterChip(context, 'High Priority', TodoFilter.highPriority),
            const SizedBox(width: 8),
            _buildFilterChip(context, 'DDL', TodoFilter.ddl),
            const SizedBox(width: 8),
            _buildFilterChip(context, 'TDL', TodoFilter.tdl),
            const SizedBox(width: 8),
            _buildFilterChip(context, 'WTD', TodoFilter.wtd),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    TodoFilter filter,
  ) {
    final isSelected = currentFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        onFilterChanged(filter);
      },
      backgroundColor: Colors.transparent,
      selectedColor: Theme.of(context).primaryColor,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.secondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected
              ? Colors.transparent
              : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
        ),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}
