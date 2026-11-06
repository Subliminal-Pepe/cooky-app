/*
 * Author: Alban DAVID
 * Github : https://github.com/AlbanDAVID/cooky-app
 * This file is governed by the GNU General Public License, version 3.0.
 * A copy of the license is included in the LICENSE file at the root of this project.
 */

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Navigation drawer shared by all the main pages.
class AppDrawer extends StatelessWidget {
  /// Route of the page currently displayed, used to highlight the entry.
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  void _goTo(BuildContext context, String route) {
    if (route == currentRoute) {
      Navigator.pop(context);
      return;
    }
    Navigator.popAndPushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              child: Image.asset(
                "android/app/src/main/res/mipmap-hdpi/ic_launcher.png",
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(AppLocalizations.of(context)!.home),
              selected: currentRoute == '/home',
              onTap: () => _goTo(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context)!.settings),
              selected: currentRoute == '/settings',
              onTap: () => _goTo(context, '/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(AppLocalizations.of(context)!.about),
              selected: currentRoute == '/about',
              onTap: () => _goTo(context, '/about'),
            ),
          ],
        ),
      ),
    );
  }
}
