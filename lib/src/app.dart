import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import halaman-halaman Anda
import 'package:insightmind_app/features/insightmind/presentation/pages/home_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/screening_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/history_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/daily_journal_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/reports_page.dart';
import 'package:insightmind_app/features/insightmind/presentation/pages/login_page.dart';

// Provider untuk memantau status login
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class InsightMindApp extends ConsumerStatefulWidget {
  const InsightMindApp({super.key});

  @override
  ConsumerState<InsightMindApp> createState() => _InsightMindAppState();
}

class _InsightMindAppState extends ConsumerState<InsightMindApp> {
  int _selectedIndex = 0;

  // List halaman Dashboard
  static const List<Widget> _pages = [
    HomePage(),
    ScreeningPage(),
    HistoryPage(),
    DailyJournalPage(),
    ReportsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mendengarkan status auth
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'InsightMind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF6366F1),
          secondary: Color(0xFF8B5CF6),
          tertiary: Color(0xFFF59E0B),
          surface: Color(0xFFFEFEFE),
          background: Color(0xFFF8FAFC),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF1F2937),
          onBackground: Color(0xFF1F2937),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Poppins', fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
          displayMedium: TextStyle(fontFamily: 'Poppins', fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
          displaySmall: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
          headlineLarge: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
          headlineMedium: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
          headlineSmall: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
          titleLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
          titleMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937)),
          titleSmall: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
          bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF374151)),
          bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF374151)),
          bodySmall: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF6B7280)),
          labelLarge: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
          labelMedium: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
          labelSmall: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF1F2937),
          centerTitle: true,
          titleTextStyle: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
          iconTheme: IconThemeData(color: Color(0xFF1F2937)),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF6366F1),
          unselectedItemColor: Color(0xFF9CA3AF),
          selectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w500),
          unselectedLabelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w400),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD1D5DB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      
      // PERBAIKAN UTAMA: Menggunakan Switcher halaman berdasarkan Auth
      home: authState.when(
        data: (user) {
          if (user != null) {
            // Jika user ditemukan (sudah login), tampilkan Dashboard
            return Scaffold(
              body: _pages[_selectedIndex],
              bottomNavigationBar: _buildBottomNav(),
            );
          } else {
            // Jika user null (belum login), tampilkan Login
            return const LoginPage();
          }
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Scaffold(
          body: Center(child: Text('Error in Auth: $err')),
        ),
      ),
    );
  }

  // Widget Bottom Navigation Bar (Sesuai desain Anda)
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology_alt_rounded), label: 'Screening'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: 'Harian'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Laporan'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}