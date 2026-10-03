import 'package:flutter/material.dart';
import 'pages/homePage/homePage.dart';
import 'database/database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Khởi tạo Database cục bộ (Single Source of Truth theo Cashew Architecture)
  AppDatabase();
  runApp(const CashewStudyDocsApp());
}

class CashewStudyDocsApp extends StatelessWidget {
  const CashewStudyDocsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Tài liệu Học tập - Cashew Architecture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3C72),
          primary: const Color(0xFF1E3C72),
          secondary: const Color(0xFF2A5298),
          surface: const Color(0xFFF8F9FA),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3C72),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          elevation: 1.5,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color(0xFF1E3C72).withValues(alpha: 0.15),
          backgroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home: const HomePage(),
    );
  }
}
