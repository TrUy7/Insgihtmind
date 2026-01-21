import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Tambahkan import ini
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // --- KODE UNTUK MENCETAK TOKEN ---
  // Kita beri delay 2 detik agar proses login Firebase Auth selesai di latar belakang
  Future.delayed(const Duration(seconds: 2), () async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      print("\n================ TOKEN UNTUK POSTMAN ================");
      print(token);
      print("=====================================================\n");
    } else {
      print("\nLOG: User belum login atau sesi habis. Token tidak muncul.\n");
    }
  });
  // ---------------------------------

  runApp(
    const ProviderScope(
      child: InsightMindApp(),
    ),
  );
}