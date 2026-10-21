import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/requerimiento_model.dart';
import '../../services/database_service.dart';
import '../../widgets/modulo_card.dart';
import '../../widgets/resumen_item.dart';
import 'admin_sidebar.dart';
import 'admin_clientes_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  int _seccionActiva = 0; 
  final _databaseService = DatabaseService();
  
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
  void _cambiarEstatusTicket(int ticketId, String nuevoEstado) async {
    try {
      await _databaseService.actualizarEstadoRequerimiento(ticketId, nuevoEstado);
      
      if (!mounted) return;
      
      setState(() {
        final index = _todosLosTickets.indexWhere((t) => t.id == ticketId);
        if (index != -1) {
          final ticketActualizado = RequerimientoModel(
            id: _todosLosTickets[index].id,
            creadoEl: _todosLosTickets[index].creadoEl,
            clienteId: _todosLosTickets[index].clienteId,
            titulo: _todosLosTickets[index].titulo,
            descripcion: _todosLosTickets[index].descripcion,
            urlsFotos: _todosLosTickets[index].urlsFotos,
            estado: nuevoEstado,
            clienteNombre: _todosLosTickets[index].clienteNombre,
            clienteEmail: _todosLosTickets[index].clienteEmail,
          );
          _todosLosTickets[index] = ticketActualizado;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado actualizado con éxito'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el estado'), backgroundColor: Colors.redAccent),
      );
    }
  }
  void _borrarTicketDelSistema(int ticketId) async {
    try {
      await _databaseService.eliminarRequerimiento(ticketId);
      if (!mounted) return;
      
      setState(() {
        _todosLosTickets.removeWhere((t) => t.id == ticketId);
      });
      _cargarDatosGlobales();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Requerimiento eliminado permanentemente'), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al eliminar el registro'), backgroundColor: Colors.redAccent),
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

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return '--/--/----';
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year;
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$anio $hora:$minuto';
  }

  String _obtenerTituloEncabezado() {
    switch (_seccionActiva) {
      case 1: return 'Listado de Requerimientos';
      case 2: return 'Gestión de Clientes';
      default: return 'Panel de Supervisión Global';
    }
  }

  String _obtenerSubtituloEncabezado() {
    switch (_seccionActiva) {
      case 1: return 'Gestión directa y visualización de evidencias';
      case 2: return 'Control de acceso de clientes';
      default: return 'Control y asignación de requerimientos';
    }
  }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool esMovil = constraints.maxWidth < 800;

        Widget sidebarWidget = AdminSidebar(
          indexSeleccionado: _seccionActiva,
          onIndexChanged: (nuevoIndex) {
            setState(() => _seccionActiva = nuevoIndex);
            if (esMovil) {
              Navigator.pop(context); 
            }
          },
        );

        return Scaffold(
          appBar: esMovil
              ? AppBar(
                  backgroundColor: const Color(0xFF0F2537),
                  title: Text(_obtenerTituloEncabezado(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  iconTheme: const IconThemeData(color: Colors.white),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _cargarDatosGlobales,
                    ),
                  ],
                )
              : null,
          drawer: esMovil ? Drawer(child: sidebarWidget) : null,
          body: Row(
            children: [
              if (!esMovil) sidebarWidget,
              Expanded(
                child: Container(
                  color: const Color(0xFFF4F6F9),
                  padding: EdgeInsets.all(esMovil ? 16 : 30),
                  child: _seccionActiva == 2 
                    ? const AdminClientesView() 
                    : _cargando 
                      ? const Center(child: CircularProgressIndicator())
                      : ListView( 
                          children: [
                            if (!esMovil) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _obtenerTituloEncabezado(),
                                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F2537)),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          _obtenerSubtituloEncabezado(),
                                          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F2537), size: 28),
                                    onPressed: _cargarDatosGlobales,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),
                            ],
                            
                            if (_seccionActiva == 0) ...[
                              esMovil
                                  ? Column( 
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        ModuloCard(titulo: 'Mantenimiento Correctivo', descripcion: 'Atención inmediata a fallas críticas reportadas.', icono: Icons.build_circle_rounded, colorIcono: Colors.amber.shade700, estaSeleccionado: true, onTap: () => setState(() => _seccionActiva = 1)),
                                        const SizedBox(height: 15),
                                        ModuloCard(titulo: 'Mantenimiento Preventivo', descripcion: 'Programación de revisiones periódicas.', icono: Icons.verified_user_rounded, colorIcono: Colors.green.shade600, estaSeleccionado: false),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(child: ModuloCard(titulo: 'Mantenimiento Correctivo', descripcion: 'Atención inmediata a fallas críticas reportadas.', icono: Icons.build_circle_rounded, colorIcono: Colors.amber.shade700, estaSeleccionado: true, onTap: () => setState(() => _seccionActiva = 1))),
                                        const SizedBox(width: 20),
                                        Expanded(child: ModuloCard(titulo: 'Mantenimiento Preventivo', descripcion: 'Programación de revisiones periódicas.', icono: Icons.verified_user_rounded, colorIcono: Colors.green.shade600, estaSeleccionado: false)),
                                      ],
                                    ),
                              const SizedBox(height: 40),
                              const Text(
                                'Resumen Operativo Global',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2537)),
                              ),
                              const SizedBox(height: 15),
                              esMovil
                                  ? Column( 
                                      children: [
                                        ResumenItem(cantidad: _pendientes.toString(), etiqueta: 'Pendientes', icono: Icons.pending_actions_rounded, colorIcono: Colors.orange),
                                        const SizedBox(height: 12),
                                        ResumenItem(cantidad: _enProceso.toString(), etiqueta: 'En Proceso', icono: Icons.loop_rounded, colorIcono: Colors.blue),
                                        const SizedBox(height: 12),
                                        ResumenItem(cantidad: _resueltos.toString(), etiqueta: 'Resueltos', icono: Icons.check_circle_outline_rounded, colorIcono: Colors.green),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(child: ResumenItem(cantidad: _pendientes.toString(), etiqueta: 'Requerimientos Pendientes', icono: Icons.pending_actions_rounded, colorIcono: Colors.orange)),
                                        const SizedBox(width: 20),
                                        Expanded(child: ResumenItem(cantidad: _enProceso.toString(), etiqueta: 'En Proceso de Atención', icono: Icons.loop_rounded, colorIcono: Colors.blue)),
                                        const SizedBox(width: 20),
                                        Expanded(child: ResumenItem(cantidad: _resueltos.toString(), etiqueta: 'Tickets Resueltos', icono: Icons.check_circle_outline_rounded, colorIcono: Colors.green)),
                                      ],
                                    ),
                            ],
                            if (_seccionActiva == 1)
                              _todosLosTickets.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40),
                                    child: Center(child: Text('No hay requerimientos registrados en el sistema.')),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(), 
                                    itemCount: _todosLosTickets.length,
                                    itemBuilder: (context, index) {
                                      final ticket = _todosLosTickets[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Flex( 
                                            direction: esMovil ? Axis.vertical : Axis.horizontal,
                                            crossAxisAlignment: esMovil ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.assignment_rounded, color: _obtenerColorEstado(ticket.estado), size: 36),
                                                  const SizedBox(width: 15),
                                                ],
                                              ),
                                              Expanded(
                                                flex: esMovil ? 0 : 1,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(ticket.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.person_outline_rounded, size: 13, color: Colors.grey.shade500),
                                                        const SizedBox(width: 4),
                                                        Expanded(child: Text('Cliente: ${ticket.clienteNombre ?? "Cargando..."}', style: const TextStyle(fontSize: 12, color: Color(0xFF0F2537), fontWeight: FontWeight.bold))),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.alternate_email_rounded, size: 12, color: Colors.grey.shade500),
                                                        const SizedBox(width: 4),
                                                        Expanded(child: Text('Correo: ${ticket.clienteEmail ?? "Sin correo"}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
                                                        const SizedBox(width: 4),
                                                        Text('Reportado el: ${_formatearFecha(ticket.creadoEl)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(ticket.descripcion, style: TextStyle(color: Colors.grey.shade700)),
                                                    const SizedBox(height: 8),
                                                    if (ticket.urlsFotos != null && ticket.urlsFotos!.isNotEmpty)
                                                      TextButton.icon(
                                                        icon: const Icon(Icons.image_search_rounded, size: 18),
                                                        label: Text('Ver Evidencias (${ticket.urlsFotos!.length})'),
                                                        onPressed: () {
                                                          _mostrarDialogoFotos(ticket);
                                                        },
                                                      )
                                                    else
                                                      Text('Sin evidencia adjunta', style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 24),
                                                tooltip: 'Eliminar Ticket',
                                                onPressed: () {
                                                  if (ticket.id == null) return;
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext ctx) => AlertDialog(
                                                      title: const Text('¿Eliminar Requerimiento?'),
                                                      content: const Text('Esta acción borrará de forma permanente el registro del sistema de control de obra y no se puede deshacer.'),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(ctx);
                                                            _borrarTicketDelSistema(ticket.id!);
                                                          }, 
                                                          child: const Text('Eliminar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(width: 10),
                                              Padding(
                                                padding: EdgeInsets.only(top: esMovil ? 12 : 0),
                                                child: DropdownButton<String>(
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
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarDialogoFotos(RequerimientoModel ticket) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ticket.titulo),
        content: SizedBox(
          width: 500,
          height: 350,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.trackpad,
              },
            ),
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
                      child: InteractiveViewer(
                        clipBehavior: Clip.none,
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Image.network(
                          ticket.urlsFotos![idx],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
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
