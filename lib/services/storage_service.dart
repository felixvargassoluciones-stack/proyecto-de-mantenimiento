import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'evidencias';
  // Sube una imagen en bytes a Supabase Storage y retorna su URL pública
  Future<String?> subirEvidencia({
    required Uint8List archivoBytes,
    required String nombreArchivo,
  }) async {
    try {
      // Reemplazamos espacios por guiones bajos para asegurar compatibilidad de URLs en la web
      final nombreLimpio = nombreArchivo.replaceAll(' ', '_');
      final String rutaUnica = '${DateTime.now().millisecondsSinceEpoch}_$nombreLimpio';

      // Usamos el método .upload estándar pasando los bytes directamente
      await _supabase.storage.from(_bucketName).upload(
            rutaUnica,
            archivoBytes,
            fileOptions: const FileOptions(
              cacheControl: '3600', 
              upsert: false,
              contentType: 'image/jpeg', // Forzamos el content-type para previsualización web correcta
            ),
          );
      // Obtener y retornar la URL pública exacta del archivo subido
      final String urlPublica = _supabase.storage.from(_bucketName).getPublicUrl(rutaUnica);
      return urlPublica;
    } catch (e) {
      // Lanzamos el error hacia la vista para que el SnackBar le avise al usuario si el Storage falla
      throw Exception('Error en Supabase Storage: $e');
    }
  }
}
