class RequerimientoModel {
  final int? id;
  final DateTime? creadoEl;
  final String clienteId;
  final String titulo;
  final String descripcion;
  final String? urlFoto;
  final String estado;

  RequerimientoModel({
    this.id,
    this.creadoEl,
    required this.clienteId,
    required this.titulo,
    required this.descripcion,
    this.urlFoto,
    this.estado = 'Pendiente',
  });

  // Convierte un JSON de Supabase a un objeto de Flutter
  factory RequerimientoModel.fromJson(Map<String, dynamic> json) {
    return RequerimientoModel(
      id: json['id'] as int?,
      creadoEl: json['creado_el'] != null 
          ? DateTime.parse(json['creado_el'] as String) 
          : null,
      clienteId: json['cliente_id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      urlFoto: json['url_foto'] as String?,
      estado: json['estado'] as String? ?? 'Pendiente',
    );
  }

  // Convierte un objeto de Flutter a un JSON para insertarlo en Supabase
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'cliente_id': clienteId,
      'titulo': titulo,
      'descripcion': descripcion,
      'url_foto': urlFoto,
      'estado': estado,
    };
    if (id != null) {
      data['id'] = id;
    }
    return data;
  }
}
