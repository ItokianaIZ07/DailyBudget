import 'package:flutter/material.dart';
import 'core/database/database_service.dart';
import 'package:gestion_depenses/features/navigation/presentation/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.instance.initialize();

  runApp(MaterialApp(
    home: MainPage(),
  ));
}