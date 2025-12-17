import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimelineHeader extends StatelessWidget {
  final DateTime today;
  final int daysToShow;
  final double dayWidth;

  const TimelineHeader({
    super.key,
    required this.today,
    required this.daysToShow,
    required this.dayWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondaryColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: List.generate(daysToShow, (index) {
          final date = today.add(Duration(days: index));
          final isToday = index == 0;
          return SizedBox(
            width: dayWidth,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getWeekday(date.weekday).toUpperCase(),
                  style: GoogleFonts.exo2(
                    fontSize: 10,
                    color: isToday ? theme.primaryColor : secondaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: isToday
                      ? BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        )
                      : null,
                  child: Text(
                    date.day.toString(),
                    style: GoogleFonts.exo2(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
