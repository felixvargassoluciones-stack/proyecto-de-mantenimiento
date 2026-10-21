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
  // Listas preparadas para acumular múltiples evidencias fotográficas en lote
  final List<Uint8List> _listaImagenesBytes = [];
  final List<String> _listaNombresImagenes = [];

  // Función para tomar foto con la cámara y apilar los bytes en memoria
  Future<void> _capturarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
      );

      if (foto != null) {
        final bytes = await foto.readAsBytes();
        setState(() {
          _listaImagenesBytes.add(bytes);
          _listaNombresImagenes.add(foto.name);
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

      List<String>? urlsFotosPublicas;

      // 1. Si hay fotos acumuladas, subirlas en paralelo al bucket de Supabase
      if (_listaImagenesBytes.isNotEmpty) {
        urlsFotosPublicas = await _storageService.subirMultiplesEvidencias(
          listaArchivosBytes: _listaImagenesBytes,
          listaNombresArchivos: _listaNombresImagenes,
        );
      }

      // 2. Construcción del modelo con el arreglo completo de URLs
      final nuevoTicket = RequerimientoModel(
        clienteId: userId,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        urlsFotos: urlsFotosPublicas != null && urlsFotosPublicas.isNotEmpty ? urlsFotosPublicas : null,
      );

      // 3. Persistencia de datos en la tabla requerimientos de PostgreSQL
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
                    
                    // Zona de captura multimedia interactiva
                    GestureDetector(
                      onTap: _guardando ? null : _capturarFoto,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          // Línea original: color: _listaImagenesBytes.isNotEmpty ? Colors.blue.withOpacity(0.05) : Colors.grey.shade50,
                          color: _listaImagenesBytes.isNotEmpty ? Colors.blue.withValues(alpha: 0.05) : Colors.grey.shade50,

                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _listaImagenesBytes.isNotEmpty ? Colors.blue : Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _listaImagenesBytes.isNotEmpty ? Icons.add_a_photo_rounded : Icons.camera_alt_rounded, 
                              size: 40, 
                              color: _listaImagenesBytes.isNotEmpty ? Colors.blue : Colors.grey.shade400
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _listaImagenesBytes.isNotEmpty 
                                  ? '¡Fotos adjuntadas: ${_listaImagenesBytes.length}!' 
                                  : 'Evidencia Fotográfica',
                              style: TextStyle(
                                fontSize: 14, 
                                fontWeight: FontWeight.w600, 
                                color: _listaImagenesBytes.isNotEmpty ? Colors.blue : Colors.grey.shade700
                              ),
                            ),
                            Text(
                              'Haz clic aquí para añadir otra foto de la avería',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Carrusel dinámico horizontal de previsualización de imágenes fijadas
                    if (_listaImagenesBytes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Previsualización de evidencias:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                          TextButton(
                            onPressed: () => setState(() { _listaImagenesBytes.clear(); _listaNombresImagenes.clear(); }),
                            child: const Text('Limpiar todas', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _listaImagenesBytes.length,
                          itemBuilder: (context, idx) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(_listaImagenesBytes[idx], width: 80, height: 80, fit: BoxFit.cover),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

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
