import 'package:flutter/material.dart';

class ModuloCard extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final IconData icono;
  final Color colorIcono;
  final bool estaSeleccionado;
  final VoidCallback? onTap;

  const ModuloCard({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.colorIcono,
    this.estaSeleccionado = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: estaSeleccionado 
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Círculo con el ícono del color correspondiente
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorIcono.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icono, color: colorIcono, size: 28),
                ),
                const SizedBox(height: 20),
                // Título del Módulo
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2537),
                  ),
                ),
                const SizedBox(height: 8),
                // Descripción corta
                Text(
                  descripcion,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                if (estaSeleccionado) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Módulo Seleccionado',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
