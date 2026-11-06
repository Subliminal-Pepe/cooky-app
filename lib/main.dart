/*
 * Author: Alban DAVID
 * Github : https://github.com/AlbanDAVID/cooky-app
 * This file is governed by the GNU General Public License, version 3.0.
 * A copy of the license is included in the LICENSE file at the root of this project.
 */

// ignore_for_file: prefer_const_constructors, override_on_non_overriding_member

import 'package:Cooky/pages/about.dart';
import 'package:Cooky/pages/language.dart';
import 'package:Cooky/pages/add_ingredients.dart';
import 'package:Cooky/data/categories_database/categories_names.dart';
import 'package:Cooky/data/categories_database/categories_names_services.dart';
import 'package:Cooky/data/theme_database/theme_database.dart';
import 'package:Cooky/pages/create_recipe.dart';
import 'package:Cooky/pages/settings.dart';
import 'package:Cooky/utils/dialbox_add_ingredient_quantity.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:Cooky/pages/home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init the hive
  await Hive.initFlutter();

  // Call the hive adapter we created for caterogires recipe name
  Hive.registerAdapter(CategoriesNamesAdapter());

  // open a box (my box is used to load all data selected in CreateRecipe)
  // All the data are in a list "recipeList" which contain : [0] Recipe name, [1]Total Time, [2] Difficulty, [3] Cost, [4] Path of the photo, [5] List of ingredients, [6] List of steps, [7] Categorie of the recipe
  var box = await Hive.openBox('mybox');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final CategoriesNamesService _categoriesNamesService =
      CategoriesNamesService();
  final ThemeDatabase _themeDatabase = ThemeDatabase();

  // Keep the future stable so a theme change does not reload the categories.
  late final Future<List<CategoriesNames>> _categoriesFuture =
      _categoriesNamesService.getAllCategories();

  MyApp({super.key});

  // open mybox for get the language and theme preferences
  final _myBox = Hive.box('mybox');

  // if no language selected, by default the app will take the phone language supported (en, fr). But, il the user want to choose, the new languge preference will be saved
  checkLanguagePref() {
    if (_myBox.get("LANGUAGE") != null) {
      return Locale(_myBox.get("LANGUAGE"));
    }
  }

  // Build a Material 3 theme. Dynamic colors are used when the platform (e.g.
  // Android 12+) provides them, otherwise the selected seed color is used.
  ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        centerTitle: true,
        elevation: 0,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: colorScheme.surfaceVariant),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the Hive box so theme changes are applied immediately.
    return ValueListenableBuilder(
      valueListenable: _myBox.listenable(),
      builder: (context, Box box, _) {
        final AppThemeMode appThemeMode = _themeDatabase.getThemeMode();
        final AppThemeColor appThemeColor = _themeDatabase.getThemeColor();

        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            final bool useDynamicColors =
                appThemeColor == AppThemeColor.dynamic &&
                    lightDynamic != null &&
                    darkDynamic != null;

            final Color seedColor = ThemeDatabase.seedColorFor(appThemeColor);

            final ColorScheme lightScheme = useDynamicColors
                ? lightDynamic!
                : ColorScheme.fromSeed(
                    seedColor: seedColor,
                    brightness: Brightness.light,
                  );

            final ColorScheme darkScheme = useDynamicColors
                ? darkDynamic!
                : ColorScheme.fromSeed(
                    seedColor: seedColor,
                    brightness: Brightness.dark,
                  );

            return MaterialApp(
              title: 'Cooky',
              // internationalization
              locale:
                  checkLanguagePref(), // if _myBox.get("LANGUAGE") != null : the user will have the language selected. Else, checkLanguagePref() return null value and as indicated in the doc of "locale" variable If the 'locale' is null then the system's locale value is used.

              localizationsDelegates: const [
                AppLocalizations.delegate, // Add this line
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en'), // English
                Locale('fr'), // French
              ],

              debugShowCheckedModeBanner: false,
              theme: _buildTheme(lightScheme),
              darkTheme: _buildTheme(darkScheme),
              themeMode: ThemeDatabase.toFlutterThemeMode(appThemeMode),
              // use FuturBuilder to load all data from "catBox" when app is started and go to the Home page(the hive box from CategoriesNamesService wih all the categories)
              home: FutureBuilder(
                future: _categoriesFuture,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<CategoriesNames>> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Home();
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              routes: {
                //'/recipe': (context) => RecipeStruct(),

                '/create_recipe': (context) => CreateRecipe(),
                '/add_ingredients': (context) => AddIngred(),
                '/dialbox_add_ingredient_and_quantity': (context) =>
                    const AddIngredientQuantity(),
                '/language': (context) => const Language(),
                '/settings': (context) => const Settings(),
                '/about': (context) => const About(),
                '/home': (context) => const Home(),
              },
            );
          },
        );
      },
    );
  }
}
