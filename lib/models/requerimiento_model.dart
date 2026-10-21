class RequerimientoModel {
  final int? id;
  final DateTime? creadoEl;
  final String clienteId;
  final String titulo;
  final String descripcion;
  final List<String>? urlsFotos;
  final String estado;
  
  // NUEVAS PROPIEDADES: Mapeadas desde la relación foreign key de perfiles
  final String? clienteNombre;
  final String? clienteEmail;

  RequerimientoModel({
    this.id,
    this.creadoEl,
    required this.clienteId,
    required this.titulo,
    required this.descripcion,
    this.urlsFotos,
    this.estado = 'Pendiente',
    this.clienteNombre,
    this.clienteEmail,
  });

  // Convierte un JSON de Supabase (con relación integrada de perfiles) a un objeto de Flutter
  factory RequerimientoModel.fromJson(Map<String, dynamic> json) {
    List<String>? listaUrls;
    if (json['url_foto'] != null) {
      listaUrls = List<String>.from(json['url_foto'] as List);
    }

    // Extracción segura de los metadatos del perfil del cliente adjunto
    String? nombre;
    String? email;
    if (json['perfiles'] != null) {
      final perfilesData = json['perfiles'] as Map<String, dynamic>;
      nombre = perfilesData['nombre'] as String?;
      email = perfilesData['email'] as String?;
    }

    return RequerimientoModel(
      id: json['id'] as int?,
      creadoEl: json['creado_el'] != null 
          ? DateTime.parse(json['creado_el'] as String) 
          : null,
      clienteId: json['cliente_id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      urlsFotos: listaUrls,
      estado: json['estado'] as String? ?? 'Pendiente',
      clienteNombre: nombre, // Asignación del nombre del remitente
      clienteEmail: email,   // Asignación del correo del remitente
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'cliente_id': clienteId,
      'titulo': titulo,
      'descripcion': descripcion,
      'url_foto': urlsFotos,
      'estado': estado,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
