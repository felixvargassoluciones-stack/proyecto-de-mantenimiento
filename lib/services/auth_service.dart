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

  // Registra un nuevo cliente de forma abierta en el sistema con rol 'pendiente'
  Future<void> registrarNuevoCliente({
    required String nombre,
    required String email,
    required String password,
  }) async {
    try {
      final correoLimpio = email.trim().toLowerCase();

      // Registramos en Supabase Auth inyectando el nombre en los metadatos
      final response = await _supabase.auth.signUp(
        email: correoLimpio,
        password: password,
        data: {
          'nombre': nombre.trim(),
        },
      );

      if (response.user == null) {
        throw Exception('No se pudo crear la cuenta de usuario.');
      }
    } catch (e) {
      if (e.toString().contains('already exists') || e.toString().contains('422')) {
        throw Exception('Este correo ya está registrado. Intenta iniciar sesión.');
      }
      rethrow;
    }
  }








}
