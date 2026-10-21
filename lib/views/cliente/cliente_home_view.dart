import 'package:flutter/material.dart';
import '../../models/requerimiento_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../auth/login_view.dart';
import 'crear_ticket_view.dart';

class ClienteHomeView extends StatefulWidget {
  const ClienteHomeView({super.key});

  @override
  State<ClienteHomeView> createState() => _ClienteHomeViewState();
}

class _ClienteHomeViewState extends State<ClienteHomeView> {
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  late Future<List<RequerimientoModel>> _futureTickets;

  @override
  void initState() {
    super.initState();
    _cargarTickets();
  }

  void _cargarTickets() {
    final String userId = _authService.usuarioActual?.id ?? '';
    setState(() {
      _futureTickets = _databaseService.obtenerRequerimientosCliente(userId);
    });
  }

  Color _obtenerColorEstado(String estado) {
    switch (estado) {
      case 'En Proceso': return Colors.blue;
      case 'Resuelto': return Colors.green;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Requerimientos', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF0F2537),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarTickets,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () async {
              await _authService.cerrarSesion();
              if (!context.mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView()));
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFF4F6F9),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido al Soporte Operativo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F2537)),
            ),
            const SizedBox(height: 5),
            Text(
              'Historial y seguimiento de tus requerimientos de mantenimiento.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<RequerimientoModel>>(
                future: _futureTickets,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar los reportes de Supabase.'));
                  }
                  final tickets = snapshot.data ?? [];
                  if (tickets.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          Text('No tienes requerimientos registrados.', style: TextStyle(fontSize: 16, color: Colors.grey.shade500)),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.build_circle_outlined, color: _obtenerColorEstado(ticket.estado), size: 36),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ticket.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(ticket.descripcion, style: TextStyle(color: Colors.grey.shade600)),
                                    const SizedBox(height: 8),
                                    // NUEVO: Verificador dinámico de lote de imágenes para el Cliente
                                    if (ticket.urlsFotos != null && ticket.urlsFotos!.isNotEmpty)
                                      TextButton.icon(
                                        icon: const Icon(Icons.image_search_rounded, size: 18),
                                        label: Text('Ver Evidencias Fotográficas (${ticket.urlsFotos!.length})'),
                                        onPressed: () {
                                          _mostrarDialogoEvidencias(ticket);
                                        },
                                      )
                                    else
                                      Text('Sin evidencia adjunta', style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              // NUEVO: Tag visual de estado idéntico al del administrador
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _obtenerColorEstado(ticket.estado).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  ticket.estado,
                                  style: TextStyle(color: _obtenerColorEstado(ticket.estado), fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const CrearTicketView()));
          _cargarTickets();
        },
        backgroundColor: const Color(0xFF0F2537),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Reporte', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Modulo de visualización en carrusel optimizado para el Cliente
  void _mostrarDialogoEvidencias(RequerimientoModel ticket) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ticket.titulo),
        content: SizedBox(
          width: 500,
          height: 350,
          child: Scrollbar(
            thumbVisibility: true,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ticket.urlsFotos!.length,
              itemBuilder: (context, idx) {
                return Container(
                  width: 380,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      ticket.urlsFotos![idx],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          )
        ],
      ),
    );
  }
}
