/*
 * Author: Alban DAVID
 * Github : https://github.com/AlbanDAVID/cooky-app
 * This file is governed by the GNU General Public License, version 3.0.
 * A copy of the license is included in the LICENSE file at the root of this project.
 */

import 'package:Cooky/data/theme_database/theme_database.dart';
import 'package:Cooky/utils/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final ThemeDatabase _themeDatabase = ThemeDatabase();

  String _themeModeLabel(AppLocalizations l10n, AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return l10n.themeModeSystem;
      case AppThemeMode.light:
        return l10n.themeModeLight;
      case AppThemeMode.dark:
        return l10n.themeModeDark;
    }
  }

  IconData _themeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
    }
  }

  String _themeColorLabel(AppLocalizations l10n, AppThemeColor color) {
    switch (color) {
      case AppThemeColor.dynamic:
        return l10n.dynamicColor;
      case AppThemeColor.purple:
        return l10n.themePurple;
      case AppThemeColor.blue:
        return l10n.themeBlue;
      case AppThemeColor.green:
        return l10n.themeGreen;
      case AppThemeColor.teal:
        return l10n.themeTeal;
      case AppThemeColor.orange:
        return l10n.themeOrange;
      case AppThemeColor.pink:
        return l10n.themePink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final AppThemeMode themeMode = _themeDatabase.getThemeMode();
    final AppThemeColor themeColor = _themeDatabase.getThemeColor();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      drawer: const AppDrawer(currentRoute: '/settings'),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _SectionHeader(title: l10n.customization),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(l10n.themeMode, style: theme.textTheme.titleMedium),
          ),
          for (final AppThemeMode mode in AppThemeMode.values)
            RadioListTile<AppThemeMode>(
              value: mode,
              groupValue: themeMode,
              title: Text(_themeModeLabel(l10n, mode)),
              secondary: Icon(_themeModeIcon(mode)),
              onChanged: (AppThemeMode? value) {
                if (value == null) {
                  return;
                }
                _themeDatabase.setThemeMode(value);
                setState(() {});
              },
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(l10n.themes, style: theme.textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.dynamicColorSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final AppThemeColor color in AppThemeColor.values)
                  _ThemeSwatch(
                    label: _themeColorLabel(l10n, color),
                    color: color == AppThemeColor.dynamic
                        ? null
                        : ThemeDatabase.seedColorFor(color),
                    selected: color == themeColor,
                    onTap: () {
                      _themeDatabase.setThemeColor(color);
                      setState(() {});
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _ThemePreview(),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            onTap: () => Navigator.pushNamed(context, '/language'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDynamic = color == null;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: 96,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDynamic ? null : color,
                  gradient: isDynamic
                      ? SweepGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.tertiary,
                            colorScheme.secondary,
                            colorScheme.primary,
                          ],
                        )
                      : null,
                ),
                child: selected
                    ? Icon(
                        Icons.check,
                        size: 20,
                        color:
                            isDynamic ||
                                ThemeData.estimateBrightnessForColor(color!) ==
                                    Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.themePreview, style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  FilledButton(onPressed: () {}, child: Text(l10n.add)),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: () {}, child: Text(l10n.cancel)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
