import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener el usuario actualmente autenticado
  User? get usuarioActual => _supabase.auth.currentUser;

  // Iniciar sesión con Correo y Contraseña
  Future<AuthResponse> iniciarSesion({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Obtener el rol del usuario desde la tabla 'perfiles'
  Future<String?> obtenerRolUsuario(String userId) async {
    try {
      final data = await _supabase
          .from('perfiles')
          .select('rol')
          .eq('id', userId)
          .maybeSingle();
      
      if (data != null) {
        return data['rol'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Cerrar Sesión
  Future<void> cerrarSesion() async {
    await _supabase.auth.signOut();
  }
}
