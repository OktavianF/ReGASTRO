import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://jrrrphzpfdjndluwalag.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpycnJwaHpwZmRqbmRsdXdhbGFnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODk4OTg3MDYsImV4cCI6MjEwNTQ3NDcwNn0.xP7J61Js2PgIK8-qATJ3rm24i-_ahexeJHa_S3d8dn4',
  );

  runApp(
    const ProviderScope(
      child: ReGastroApp(),
    ),
  );
}

class ReGastroApp extends StatelessWidget {
  const ReGastroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReGASTRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
