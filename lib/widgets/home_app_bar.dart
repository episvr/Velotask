import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velotask/models/todo.dart';
import 'package:velotask/screens/timeline_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:velotask/main.dart';

class HomeAppBar extends StatelessWidget {
  final List<Todo> todos;

  const HomeAppBar({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Velotask',
            style: GoogleFonts.exo2(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, mode, child) {
            return IconButton(
              icon: Icon(
                mode == ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () async {
                final newMode = mode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
                themeNotifier.value = newMode;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('theme_mode', newMode.toString());
              },
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.view_timeline_outlined,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TimelineScreen(todos: todos),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
