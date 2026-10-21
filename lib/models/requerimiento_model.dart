class RequerimientoModel {
  final int? id;
  final DateTime? creadoEl;
  final String clienteId;
  final String titulo;
  final String descripcion;
  // CAMBIO CLAVE: Ahora soporta una lista de URLs de evidencias
  final List<String>? urlsFotos;
  final String estado;

  RequerimientoModel({
    this.id,
    this.creadoEl,
    required this.clienteId,
    required this.titulo,
    required this.descripcion,
    this.urlsFotos,
    this.estado = 'Pendiente',
  });

  // Convierte un JSON de Supabase (con arreglo text[]) a un objeto de Flutter
  factory RequerimientoModel.fromJson(Map<String, dynamic> json) {
    // Mapeo seguro del formato array de Postgres a List<String> en Dart
    List<String>? listaUrls;
    if (json['url_foto'] != null) {
      listaUrls = List<String>.from(json['url_foto'] as List);
    }

    return RequerimientoModel(
      id: json['id'] as int?,
      creadoEl: json['creado_el'] != null 
          ? DateTime.parse(json['creado_el'] as String) 
          : null,
      clienteId: json['cliente_id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      urlsFotos: listaUrls, // Asignación de la lista de imágenes
      estado: json['estado'] as String? ?? 'Pendiente',
    );
  }

  // Convierte un objeto de Flutter a un JSON compatible con text[] en Supabase
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'cliente_id': clienteId,
      'titulo': titulo,
      'descripcion': descripcion,
      'url_foto': urlsFotos, // Supabase detecta la lista y la guarda como arreglo text[]
      'estado': estado,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
