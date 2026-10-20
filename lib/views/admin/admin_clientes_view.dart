import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class AdminClientesView extends StatefulWidget {
  const AdminClientesView({super.key});

  @override
  State<AdminClientesView> createState() => _AdminClientesViewState();
}

class _AdminClientesViewState extends State<AdminClientesView> {
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  bool _cargando = false;
  List<Map<String, dynamic>> _clientes = [];

  @override
  void initState() {
    super.initState();
    _cargarClientes();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _cargarClientes() async {
    setState(() => _cargando = true);
    try {
      final datos = await _databaseService.obtenerClientes();
      setState(() => _clientes = datos);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }
  // Nueva función para aprobar cuentas pendientes con un solo clic
  Future<void> _autorizarCliente(String email) async {
    setState(() => _cargando = true);
    try {
      await _databaseService.actualizarRolCliente(
        email: email,
        nuevoRol: 'cliente',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Cliente autorizado con éxito!'), backgroundColor: Colors.green),
        );
      }
      _cargarClientes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
      setState(() => _cargando = false);
    }
  }

  Future<void> _mostrarFormularioAlta() async {
    _nombreController.clear();
    _emailController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Nuevo Cliente', 
          style: TextStyle(color: Color(0xFF0F2537), fontWeight: FontWeight.bold)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa el nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Ingresa el correo';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F2537),
              foregroundColor: Colors.white,
            ),
            onPressed: _procesarAltaCliente,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarAltaCliente() async {
    if (!_formKey.currentState!.validate()) return;
    
    Navigator.pop(context);
    setState(() => _cargando = true);

    try {
      await _databaseService.registrarCliente(
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente registrado con éxito'), backgroundColor: Colors.green),
        );
      }
      _cargarClientes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
      setState(() => _cargando = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('Gestión de Clientes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0F2537),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarClientes,
          )
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F2537))))
          : _clientes.isEmpty
              ? const Center(child: Text('No hay clientes registrados en el sistema.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _clientes.length,
                  itemBuilder: (context, index) {
                    final cliente = _clientes[index];
                    final String rol = cliente['rol'] ?? 'cliente';
                    final bool esPendiente = rol == 'pendiente';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: esPendiente ? Colors.orange.shade50 : const Color(0xFFF4F6F9),
                          child: Icon(
                            Icons.person, 
                            color: esPendiente ? Colors.orange : const Color(0xFF0F2537),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(cliente['nombre'] ?? 'Sin Nombre', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            // Etiqueta dinámica de estado visual
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: esPendiente ? Colors.orange.shade100 : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                esPendiente ? 'PENDIENTE' : 'ACTIVO',
                                style: TextStyle(
                                  fontSize: 10, 
                                  fontWeight: FontWeight.bold, 
                                  color: esPendiente ? Colors.orange.shade900 : Colors.green.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(cliente['email'] ?? 'Sin Correo'),
                        // Botón de acción rápida condicional para aprobación instantánea
                        trailing: esPendiente
                            ? IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                                tooltip: 'Autorizar Acceso',
                                onPressed: () => _autorizarCliente(cliente['email'] ?? ''),
                              )
                            : const Icon(Icons.chevron_right, color: Colors.grey),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0F2537),
        foregroundColor: Colors.white,
        onPressed: _mostrarFormularioAlta,
        child: const Icon(Icons.add),
      ),
    );
  }
}
