import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/requerimiento_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // CLIENTE: Crear un nuevo ticket de mantenimiento
  Future<void> crearRequerimiento(RequerimientoModel requerimiento) async {
    await _supabase.from('requerimientos').insert(requerimiento.toJson());
  }

  // CLIENTE: Obtener historial exclusivo de un cliente específico
  Future<List<RequerimientoModel>> obtenerRequerimientosCliente(String clienteId) async {
    final response = await _supabase
        .from('requerimientos')
        .select()
        .eq('cliente_id', clienteId)
        .order('creado_el', ascending: false);

    return (response as List)
        .map((json) => RequerimientoModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ADMIN: Obtener TODOS los requerimientos con los datos de sus Perfiles integrados
  Future<List<RequerimientoModel>> obtenerTodosLosRequerimientos() async {
    // MODIFICADO: Realiza un Join con la tabla perfiles para traer nombre y email de una sola vez
    final response = await _supabase
        .from('requerimientos')
        .select('*, perfiles(nombre, email)')
        .order('creado_el', ascending: false);

    return (response as List)
        .map((json) => RequerimientoModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ADMIN: Actualizar el estado de un ticket ('Pendiente', 'En Proceso', 'Resuelto')
  Future<void> actualizarEstadoRequerimiento(int id, String nuevoEstado) async {
    await _supabase
        .from('requerimientos')
        .update({'estado': nuevoEstado})
        .eq('id', id);
  }

  // Obtener la lista de perfiles con rol de cliente o pendientes de aprobación
  Future<List<Map<String, dynamic>>> obtenerClientes() async {
    try {
      final List<dynamic> response = await _supabase
          .from('perfiles')
          .select('email, nombre, rol, creado_el')
          .inFilter('rol', ['cliente', 'pendiente'])
          .order('creado_el', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al obtener clientes: $e');
    }
  }

   // Pre-registrar un nuevo cliente desde el panel de administración de forma correcta
  Future<void> registrarCliente({
    required String nombre,
    required String email,
  }) async {
    try {
      // MODIFICADO: Registra al usuario en el motor de Autenticación para generar su ID real
      // Se le asigna una contraseña temporal por defecto (ej. 'Obra2026*') para que pueda loguearse
      await _supabase.auth.signUp(
        email: email.trim().toLowerCase(),
        password: 'Obra2026*', 
        data: {
          'nombre': nombre, // Tu Trigger handle_new_user() tomará este nombre automáticamente
        },
      );
    } catch (e) {
      throw Exception('Error al registrar el cliente en el sistema: $e');
    }
  }


  // Actualizar el rol de un cliente (Aprobación rápida del Administrador)
  Future<void> actualizarRolCliente({
    required String email,
    required String nuevoRol,
  }) async {
    try {
      await _supabase
          .from('perfiles')
          .update({'rol': nuevoRol})
          .eq('email', email.trim().toLowerCase());
    } catch (e) {
      throw Exception('Error al actualizar el rol del usuario: $e');
    }
  }

  // ==========================================
  // NUEVO: FUNCIONES DE ELIMINACIÓN PARA EL ADMIN
  // ==========================================

  // ADMIN: Eliminar un requerimiento/ticket por ID del sistema
  Future<void> eliminarRequerimiento(int id) async {
    try {
      await _supabase
          .from('requerimientos')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar el requerimiento: $e');
    }
  }

  // ADMIN: Eliminar un perfil de cliente por su Correo Electrónico
  Future<void> eliminarClientePorEmail(String email) async {
    try {
      await _supabase
          .from('perfiles')
          .delete()
          .eq('email', email.trim().toLowerCase());
    } catch (e) {
      throw Exception('Error al eliminar el cliente: $e');
    }
  }
}
