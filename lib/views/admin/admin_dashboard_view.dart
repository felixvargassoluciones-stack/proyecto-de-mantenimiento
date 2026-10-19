import 'package:flutter/material.dart';
import '../../models/requerimiento_model.dart';
import '../../services/database_service.dart';
import '../../widgets/modulo_card.dart';
import '../../widgets/resumen_item.dart';
import 'admin_sidebar.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _seccionActiva = 0; // 0: Resumen Global, 1: Lista de Requerimientos
  final _databaseService = DatabaseService();
  
  // Variables para métricas
  int _pendientes = 0;
  int _enProceso = 0;
  int _resueltos = 0;
  bool _cargando = true;
  List<RequerimientoModel> _todosLosTickets = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosGlobales();
  }

  // Consulta la base de datos para actualizar las métricas y la lista operativa
  Future<void> _cargarDatosGlobales() async {
    setState(() => _cargando = true);
    try {
      final todos = await _databaseService.obtenerTodosLosRequerimientos();
      
      int p = 0;
      int ep = 0;
      int r = 0;

      for (var ticket in todos) {
        if (ticket.estado == 'En Proceso') {
          ep++;
        } else if (ticket.estado == 'Resuelto') {
          r++;
        } else {
          p++;
        }
      }

      setState(() {
        _todosLosTickets = todos;
        _pendientes = p;
        _enProceso = ep;
        _resueltos = r;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
    }
  }

  // Modifica el estado en Supabase y refresca la interfaz automáticamente
   void _cambiarEstatusTicket(int ticketId, String nuevoEstado) async {
    try {
      await _databaseService.actualizarEstadoRequerimiento(ticketId, nuevoEstado);
      
      if (!mounted) return; // Añadido para solucionar la línea 69
      _cargarDatosGlobales(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado actualizado con éxito'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return; // Añadido para solucionar la línea 73
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el estado'), backgroundColor: Colors.redAccent),
      );
    }
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
      body: Row(
        children: [
          AdminSidebar(
            indexSeleccionado: _seccionActiva,
            onIndexChanged: (nuevoIndex) {
              setState(() => _seccionActiva = nuevoIndex);
            },
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF4F6F9),
              padding: const EdgeInsets.all(30),
              child: _cargando 
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Encabezado dinámico
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _seccionActiva == 0 ? 'Panel de Supervisión Global' : 'Listado de Requerimientos',
                                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F2537)),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _seccionActiva == 0 
                                    ? 'Control y asignación de requerimientos de mantenimiento del sistema'
                                    : 'Gestión directa, visualización de evidencias y cambio de estados',
                                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F2537), size: 28),
                            onPressed: _cargarDatosGlobales,
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Vista 1: Resumen Dashboard (Clon de Control de Obra)
                      if (_seccionActiva == 0) ...[
                        Row(
                          children: [
                            ModuloCard(
                              titulo: 'Mantenimiento Correctivo',
                              descripcion: 'Atención inmediata a fallas y reportes críticos enviados por los clientes.',
                              icono: Icons.build_circle_rounded,
                              colorIcono: Colors.amber.shade700,
                              estaSeleccionado: true,
                              onTap: () => setState(() => _seccionActiva = 1),
                            ),
                            ModuloCard(
                              titulo: 'Mantenimiento Preventivo',
                              descripcion: 'Programación de revisiones periódicas e inspección de infraestructura.',
                              icono: Icons.verified_user_rounded,
                              colorIcono: Colors.green.shade600,
                              estaSeleccionado: false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Resumen Operativo Global',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2537)),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            ResumenItem(
                              cantidad: _pendientes.toString(),
                              etiqueta: 'Requerimientos Pendientes',
                              icono: Icons.pending_actions_rounded,
                              colorIcono: Colors.orange,
                            ),
                            ResumenItem(
                              cantidad: _enProceso.toString(),
                              etiqueta: 'En Proceso de Atención',
                              icono: Icons.loop_rounded,
                              colorIcono: Colors.blue,
                            ),
                            ResumenItem(
                              cantidad: _resueltos.toString(),
                              etiqueta: 'Tickets Resueltos',
                              icono: Icons.check_circle_outline_rounded,
                              colorIcono: Colors.green,
                            ),
                          ],
                        ),
                      ],
                      // Vista 2: Control Operativo Detallado de Registros
                      if (_seccionActiva == 1)
                        Expanded(
                          child: _todosLosTickets.isEmpty
                            ? const Center(child: Text('No hay requerimientos registrados en el sistema.'))
                            : ListView.builder(
                                itemCount: _todosLosTickets.length,
                                itemBuilder: (context, index) {
                                  final ticket = _todosLosTickets[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Icon(Icons.assignment_rounded, color: _obtenerColorEstado(ticket.estado), size: 36),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(ticket.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                const SizedBox(height: 4),
                                                Text(ticket.descripcion, style: TextStyle(color: Colors.grey.shade600)),
                                                const SizedBox(height: 8),
                                                // Valida si el registro cuenta con evidencia fotográfica en el Storage
                                                if (ticket.urlFoto != null)
                                                  TextButton.icon(
                                                    icon: const Icon(Icons.image_search_rounded, size: 18),
                                                    label: const Text('Ver Evidencia Fotográfica'),
                                                    onPressed: () {
                                                      // Abre cuadro de diálogo con la imagen remota sin bloqueos CORS
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) => AlertDialog(
                                                          title: Text(ticket.titulo),
                                                          content: Image.network(ticket.urlFoto!, fit: BoxFit.contain),
                                                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
                                                        ),
                                                      );
                                                    },
                                                  )
                                                   // Antes: style: TextStyle(fontSize: 11, color: Colors.grey.shade400, style: FontStyle.italic),
                                                else
                                                  Text('Sin evidencia adjunta', style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          // Selector dinámico (Dropdown) para modificar estados en caliente
                                          DropdownButton<String>(
                                            value: ticket.estado,
                                            icon: Icon(Icons.arrow_drop_down_circle_outlined, color: _obtenerColorEstado(ticket.estado)),
                                            underline: const SizedBox(),
                                            style: TextStyle(color: _obtenerColorEstado(ticket.estado), fontWeight: FontWeight.bold),
                                            items: <String>['Pendiente', 'En Proceso', 'Resuelto']
                                                .map<DropdownMenuItem<String>>((String valor) {
                                              return DropdownMenuItem<String>(
                                                value: valor,
                                                child: Text(valor),
                                              );
                                            }).toList(),
                                            onChanged: (String? nuevoValor) {
                                              if (nuevoValor != null && ticket.id != null) {
                                                _cambiarEstatusTicket(ticket.id!, nuevoValor);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                        ),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
