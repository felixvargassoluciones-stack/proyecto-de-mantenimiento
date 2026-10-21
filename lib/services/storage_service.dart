import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'evidencias';

  // Sube una imagen en bytes a Supabase Storage y retorna su URL pública limpia
  Future<String?> subirEvidencia({
    required Uint8List archivoBytes,
    required String nombreArchivo,
  }) async {
    try {
      final nombreLimpio = nombreArchivo.replaceAll(' ', '_');
      final String rutaUnica = '${DateTime.now().millisecondsSinceEpoch}_$nombreLimpio';

      // CAMBIO CLAVE: Se usa uploadBinary para compatibilidad nativa en Flutter Web
      await _supabase.storage.from(_bucketName).uploadBinary(
            rutaUnica,
            archivoBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600', 
              upsert: false,
              contentType: 'image/jpeg',
            ),
          );

      // Extracción a String de forma segura y compatible con cualquier versión del SDK
      final resultadoUrl = _supabase.storage.from(_bucketName).getPublicUrl(rutaUnica);
      
      // Si el SDK devuelve un objeto, lo convertimos a String de forma explícita
      final String urlLimpia = resultadoUrl.toString();
      
      return urlLimpia;
    } catch (e) {
      throw Exception('Error en Supabase Storage: $e');
    }
  }
}
