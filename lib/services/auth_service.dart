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

 // Verifica si el cliente fue pre-registrado y le crea sus credenciales de acceso
  Future<void> activarCuentaCliente({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Validar en la tabla de perfiles que el correo fue dado de alta por el admin
      final perfil = await _supabase
          .from('perfiles')
          .select('nombre')
          .eq('email', email.trim()) // Agregado .trim() para limpiar espacios ocultos
          .eq('rol', 'cliente')
          .maybeSingle();

      if (perfil == null) {
        throw Exception('Este correo electrónico no está autorizado por el administrador.');
      }

      // 2. Si existe, registrar el usuario en Supabase Auth de forma segura
      // El Trigger SQL unirá este ID con el perfil existente automáticamente usando el correo
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('No se pudo crear la credencial de autenticación.');
      }
    } catch (e) {
      if (e.toString().contains('already exists')) {
        throw Exception('Esta cuenta ya se encuentra activa. Inicia sesión directamente.');
      }
      rethrow;
    }
  }







}
