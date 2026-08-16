import 'package:flutter/material.dart';
import 'package:gestion_depenses/core/themes/app_theme.dart';
import 'core/database/database_service.dart';
import 'package:gestion_depenses/features/navigation/presentation/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.instance.initialize();

  runApp(
    MaterialApp(
      home: MainPage(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.colors.primarySoft,
          brightness: Brightness.light,
        ),
      ),

      themeMode: ThemeMode.light,
    ),
  );
}
