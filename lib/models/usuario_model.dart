class UsuarioModel {
  final String id;
  final String nombre;
  final String rol;

  UsuarioModel({
    required this.id,
    required this.nombre,
    required this.rol,
  });

  // Convierte un JSON de Supabase a un objeto de Flutter
  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      rol: json['rol'] as String,
    );
  }

  // Convierte un objeto de Flutter a un JSON para guardarlo en Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'rol': rol,
    };
  }
}
