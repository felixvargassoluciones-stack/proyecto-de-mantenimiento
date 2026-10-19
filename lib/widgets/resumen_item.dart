import 'package:flutter/material.dart';

class ResumenItem extends StatelessWidget {
  final String cantidad;
  final String etiqueta;
  final IconData icono;
  final Color colorIcono;

  const ResumenItem({
    super.key,
    required this.cantidad,
    required this.etiqueta,
    required this.icono,
    required this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Micro-ícono circular
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorIcono.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, color: colorIcono, size: 20),
            ),
            const SizedBox(width: 15),
            // Métricas
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  cantidad,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F2537),
                  ),
                ),
                Text(
                  etiqueta,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
