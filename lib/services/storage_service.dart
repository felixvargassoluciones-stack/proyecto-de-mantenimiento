import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'evidencias';

  // Sube una imagen en bytes y retorna la URL pública del archivo
  Future<String?> subirEvidencia({
    required Uint8List archivoBytes,
    required String nombreArchivo,
  }) async {
    try {
      // Creamos una ruta única usando el tiempo actual para evitar colisiones de nombres
      final String rutaUnica = '${DateTime.now().millisecondsSinceEpoch}_$nombreArchivo';

      // Subida de datos binarios directos al Bucket
      await _supabase.storage.from(_bucketName).uploadBinary(
            rutaUnica,
            archivoBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Obtener y retornar la URL pública del archivo subido
      final String urlPublica = _supabase.storage.from(_bucketName).getPublicUrl(rutaUnica);
      return urlPublica;
    } catch (e) {
      return null;
    }
  }
}
