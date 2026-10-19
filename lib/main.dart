import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'config/theme.dart';
import 'views/auth/login_view.dart';



void main() async {
  // Asegura que los bindings nativos estén listos antes de inicializar servicios remotos
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización global de Supabase
    // Inicialización global de Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey, // Cambiado anonKey por publishableKey
  );


  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Mantenimiento',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Temporalmente iniciamos en una pantalla vacía, luego configuraremos el flujo de login/roles
            home: const LoginView(),

    );
  }
}
