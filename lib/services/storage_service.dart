import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'evidencias';

  // Sube una sola imagen en bytes a Supabase Storage y retorna su URL pública limpia
  Future<String?> subirEvidencia({
    required Uint8List archivoBytes,
    required String nombreArchivo,
  }) async {
    try {
      final nombreLimpio = nombreArchivo.replaceAll(' ', '_');
      final String rutaUnica = '${DateTime.now().millisecondsSinceEpoch}_$nombreLimpio';

      await _supabase.storage.from(_bucketName).uploadBinary(
            rutaUnica,
            archivoBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600', 
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      final resultadoUrl = _supabase.storage.from(_bucketName).getPublicUrl(rutaUnica);
      return resultadoUrl.toString();
    } catch (e) {
      throw Exception('Error en Supabase Storage: $e');
    }
  }

  // NUEVO: Sube múltiples imágenes en paralelo y retorna una lista de URLs públicas
  Future<List<String>> subirMultiplesEvidencias({
    required List<Uint8List> listaArchivosBytes,
    required List<String> listaNombresArchivos,
  }) async {
    try {
      List<Future<String?>> tareasSubida = [];

      for (int i = 0; i < listaArchivosBytes.length; i++) {
        tareasSubida.add(
          subirEvidencia(
            archivoBytes: listaArchivosBytes[i],
            nombreArchivo: listaNombresArchivos[i],
          ),
        );
      }

      // Ejecuta todas las subidas al mismo tiempo en internet
      final resultados = await Future.wait(tareasSubida);
      
      // Filtra cualquier URL nula por seguridad y retorna la lista limpia
      return resultados.where((url) => url != null).cast<String>().toList();
    } catch (e) {
      throw Exception('Error al subir el lote de evidencias: $e');
    }
  }
}
