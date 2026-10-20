import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_view.dart';

class AdminSidebar extends StatelessWidget {
  final int indexSeleccionado;
  final ValueChanged<int> onIndexChanged;

  const AdminSidebar({
    super.key,
    required this.indexSeleccionado,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Container(
      width: 260,
      color: const Color(0xFF0F2537), // Azul oscuro idéntico a Control de Obra
      child: Column(
        children: [
          // Sección Superior: Perfil del Administrador
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Administrador',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Panel de Control',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Opciones de Navegación del Menú
          _buildItemMenu(
            index: 0,
            icono: Icons.dashboard_rounded,
            titulo: 'Resumen Global',
          ),
          _buildItemMenu(
            index: 1,
            icono: Icons.assignment_late_rounded,
            titulo: 'Requerimientos',
          ),
          _buildItemMenu(
            index: 2,
            icono: Icons.people_alt_rounded,
            titulo: 'Gestión de Clientes',
          ),
          const Spacer(),
          // Botón de Cerrar Sesión en la parte inferior
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () async {
              await authService.cerrarSesion();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildItemMenu({required int index, required IconData icono, required String titulo}) {
    final estaSeleccionado = indexSeleccionado == index;
    return ListTile(
      selected: estaSeleccionado,
      selectedTileColor: Colors.white.withValues(alpha: 0.05),
      leading: Icon(icono, color: estaSeleccionado ? Colors.blue : Colors.white70),
      title: Text(
        titulo,
        style: TextStyle(
          color: estaSeleccionado ? Colors.white : Colors.white70,
          fontWeight: estaSeleccionado ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () => onIndexChanged(index),
    );
  }
}
