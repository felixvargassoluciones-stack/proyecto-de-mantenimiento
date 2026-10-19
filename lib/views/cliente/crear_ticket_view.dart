import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/requerimiento_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';

class CrearTicketView extends StatefulWidget {
  const CrearTicketView({super.key});

  @override
  State<CrearTicketView> createState() => _CrearTicketViewState();
}

class _CrearTicketViewState extends State<CrearTicketView> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  final _storageService = StorageService();
  final _picker = ImagePicker();
  
  bool _guardando = false;
  Uint8List? _imagenBytes;
  String? _nombreImagen;

  // Función para tomar foto con la cámara del dispositivo
  Future<void> _capturarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75, // Reduce peso optimizando la subida a Supabase
      );

      if (foto != null) {
        final bytes = await foto.readAsBytes();
        setState(() {
          _imagenBytes = bytes;
          _nombreImagen = foto.name;
        });
      }
    } catch (e) {
      _mostrarMensaje('No se pudo acceder a la cámara.', Colors.redAccent);
    }
  }

  void _enviarReporte() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final String? userId = _authService.usuarioActual?.id;
      
      if (userId == null) {
        _mostrarMensaje('Error: No se identificó la sesión.', Colors.redAccent);
        return;
      }

      String? urlFotoPublica;

      // 1. Si el cliente capturó una foto, subirla primero al Storage
      if (_imagenBytes != null && _nombreImagen != null) {
        urlFotoPublica = await _storageService.subirEvidencia(
          archivoBytes: _imagenBytes!,
          nombreArchivo: _nombreImagen!,
        );
      }

      // 2. Crear el modelo con la URL de la foto de Supabase Storage
      final nuevoTicket = RequerimientoModel(
        clienteId: userId,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        urlFoto: urlFotoPublica, // URL limpia del bucket público
      );

      // 3. Guardar registro en PostgreSQL
      await _databaseService.crearRequerimiento(nuevoTicket);

      if (!mounted) return;
      _mostrarMensaje('Reporte registrado con éxito.', Colors.green);
      Navigator.pop(context);
    } catch (e) {
      _mostrarMensaje('Error al guardar el requerimiento.', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Requerimiento', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0F2537),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFF4F6F9),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Reportar Falla o Avería',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F2537)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Describe detalladamente la situación para que el administrador pueda revisarla.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título del Reporte',
                        hintText: 'Ej. Falla en aire acondicionado',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Por favor ingresa un título' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descripcionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Descripción Detallada',
                        hintText: 'Especifica la ubicación exacta de la falla...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Por favor ingresa una descripción' : null,
                    ),
                    const SizedBox(height: 24),
                    // Contenedor multimedia interactivo
                    GestureDetector(
                      onTap: _guardando ? null : _capturarFoto,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _imagenBytes != null ? Colors.blue.withValues(alpha: 0.05) : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _imagenBytes != null ? Colors.blue : Colors.grey.shade300,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _imagenBytes != null ? Icons.verified_rounded : Icons.add_a_photo_rounded, 
                              size: 40, 
                              color: _imagenBytes != null ? Colors.blue : Colors.grey.shade400
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _imagenBytes != null ? '¡Foto adjuntada con éxito!' : 'Evidencia Fotográfica',
                              style: TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.w600, 
                                color: _imagenBytes != null ? Colors.blue : Colors.grey.shade700
                              ),
                            ),
                            Text(
                              _imagenBytes != null ? 'Haz clic de nuevo si deseas cambiar la captura' : 'Haz clic aquí para activar la cámara',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _guardando ? null : _enviarReporte,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F2537),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _guardando
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Enviar Requerimiento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
