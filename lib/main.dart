import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:insightmind_app/features/insightmind/presentation/pages/login_page.dart'; // Import ini harus benar
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(
    const ProviderScope(
      child: InsightMindApp(),
    ),
  );
}