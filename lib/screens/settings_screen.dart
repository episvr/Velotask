import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velotask/main.dart';
import 'package:velotask/screens/tags_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velotask/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = packageInfo.version;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _version = '1.0.0';
        });
      }
    }
  }

  Future<void> _setTheme(ThemeMode mode) async {
    themeNotifier.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
  }

  Future<void> _setLocale(Locale? locale) async {
    localeNotifier.value = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale != null) {
      await prefs.setString('locale', locale.languageCode);
    } else {
      await prefs.remove('locale');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          _buildSectionHeader(context, l10n.general),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, child) {
              return ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: Text(l10n.theme),
                subtitle: Text(
                  currentMode == ThemeMode.system
                      ? l10n.systemDefault
                      : currentMode == ThemeMode.dark
                      ? l10n.darkMode
                      : l10n.lightMode,
                ),
                onTap: () => _showThemeDialog(context, currentMode),
              );
            },
          ),
          ValueListenableBuilder<Locale?>(
            valueListenable: localeNotifier,
            builder: (context, currentLocale, child) {
              return ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(
                  currentLocale?.languageCode == 'zh' ? '中文' : 'English',
                ),
                onTap: () => _showLanguageDialog(context, currentLocale),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.organization),
          ListTile(
            leading: const Icon(Icons.label_outline),
            title: Text(l10n.manageTags),
            subtitle: Text(l10n.manageTagsSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TagsScreen()),
              );
            },
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.about),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.version),
            subtitle: Text(_version),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.sourceCode),
            subtitle: Text(l10n.viewOnGithub),
            onTap: () async {
              final uri = Uri.parse(
                'https://github.com/Source-of-USTB/Velotask',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.selectTheme),
        children: [
          RadioListTile<ThemeMode>(
            title: Text(l10n.systemDefault),
            value: ThemeMode.system,
            groupValue: currentMode,
            onChanged: (value) {
              if (value != null) _setTheme(value);
              Navigator.pop(context);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.lightMode),
            value: ThemeMode.light,
            groupValue: currentMode,
            onChanged: (value) {
              if (value != null) _setTheme(value);
              Navigator.pop(context);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.darkMode),
            value: ThemeMode.dark,
            groupValue: currentMode,
            onChanged: (value) {
              if (value != null) _setTheme(value);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, Locale? currentLocale) {
    final l10n = AppLocalizations.of(context)!;
    final effectiveLocale = currentLocale ?? const Locale('en');

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.language),
        children: [
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: effectiveLocale.languageCode,
            onChanged: (value) {
              if (value != null) _setLocale(Locale(value));
              Navigator.pop(context);
            },
          ),
          RadioListTile<String>(
            title: const Text('中文'),
            value: 'zh',
            groupValue: effectiveLocale.languageCode,
            onChanged: (value) {
              if (value != null) _setLocale(Locale(value));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
