import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velotask/models/todo.dart';
import 'package:velotask/widgets/timeline_header.dart';
import 'package:velotask/widgets/timeline_task_row.dart';

class TimelineScreen extends StatelessWidget {
  final List<Todo> todos;

  const TimelineScreen({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextMonth = today.add(const Duration(days: 30));

    // Filter tasks that overlap with the next 30 days
    final timelineTasks = todos.where((todo) {
      if (todo.isCompleted) return false;

      final start = todo.startDate ?? todo.createdAt ?? today;
      final end = todo.ddl ?? start;

      // Normalize dates to start of day
      final startDate = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(
        end.year,
        end.month,
        end.day,
      ).add(const Duration(days: 1)).subtract(const Duration(seconds: 1));

      return startDate.isBefore(nextMonth) && endDate.isAfter(today);
    }).toList();

    // Sort by start date
    timelineTasks.sort((a, b) {
      final startA = a.startDate ?? a.createdAt ?? today;
      final startB = b.startDate ?? b.createdAt ?? today;
      return startA.compareTo(startB);
    });

    const double dayWidth = 60.0;
    const int daysToShow = 30;
    final double totalWidth = dayWidth * daysToShow;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'TIMELINE',
          style: GoogleFonts.exo2(
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.0,
            color: Theme.of(context).primaryColor,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: timelineTasks.isEmpty
          ? Center(
              child: Text(
                'No tasks for the next 30 days',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.6),
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: totalWidth,
                child: Column(
                  children: [
                    TimelineHeader(
                      today: today,
                      daysToShow: daysToShow,
                      dayWidth: dayWidth,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        itemCount: timelineTasks.length,
                        itemBuilder: (context, index) {
                          return TimelineTaskRow(
                            todo: timelineTasks[index],
                            today: today,
                            daysToShow: daysToShow,
                            dayWidth: dayWidth,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
