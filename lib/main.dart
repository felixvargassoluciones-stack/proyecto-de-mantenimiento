import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'config/theme.dart';
import 'services/auth_service.dart';
import 'views/auth/login_view.dart';
import 'views/admin/admin_dashboard_view.dart';
import 'views/cliente/cliente_home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización global de Supabase con persistencia nativa en LocalStorage activada por defecto
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MaterialApp(
      title: 'Sistema de Mantenimiento',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // NUEVO: StreamBuilder reactivo encargado de mantener la sesión abierta permanentemente
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Si Supabase está leyendo los datos locales en caché, muestra una pantalla de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          final session = snapshot.data?.session;

          // Si no hay sesión válida activa en el navegador, va directo al Login
          if (session == null) {
            return const LoginView();
          }

          // Si hay una sesión activa persistente, resuelve el rol en segundo plano de forma dinámica
          return FutureBuilder<String?>(
            future: authService.obtenerRolUsuario(session.user.id),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final rol = roleSnapshot.data;

              if (rol == 'admin') {
                return const AdminDashboardView();
              } else if (rol == 'cliente') {
                return const ClienteHomeView();
              } else {
                // Si el rol es pendiente o inválido, limpia la sesión y muestra el Login
                return const LoginView();
              }
            },
          );
        },
      ),
    );
  }
}
