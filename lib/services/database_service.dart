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

  // ADMIN: Obtener TODOS los requerimientos del sistema (Global)
  Future<List<RequerimientoModel>> obtenerTodosLosRequerimientos() async {
    final response = await _supabase
        .from('requerimientos')
        .select()
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
}
