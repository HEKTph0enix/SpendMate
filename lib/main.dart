import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'database/database_helper.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize database (creates tables if first run)
  await DatabaseHelper().database;
  
  runApp(const SpendMateApp());
}
