import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../admin/admin_dashboard_view.dart';
import '../cliente/cliente_home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _activarKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _activarEmailController = TextEditingController();
  final _activarPasswordController = TextEditingController();
  final _authService = AuthService();
  
  bool _cargando = false;

  void _intentarLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final response = await _authService.iniciarSesion(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        final rol = await _authService.obtenerRolUsuario(response.user!.id);

        if (!mounted) return;

        if (rol == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardView()),
          );
        } else if (rol == 'cliente') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ClienteHomeView()),
          );
        } else {
          _mostrarError('El usuario no tiene un rol válido asignado.');
        }
      }
    } catch (e) {
      _mostrarError('Error de autenticación: Correo o contraseña incorrectos.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _mostrarDialogoActivacion() async {
    _activarEmailController.clear();
    _activarPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activar Cuenta de Cliente', 
          style: TextStyle(color: Color(0xFF0F2537), fontWeight: FontWeight.bold)),
        content: Form(
          key: _activarKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Si el administrador ya te dio de alta, ingresa tu correo y define tu contraseña de acceso.',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _activarEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Tu Correo Pre-registrado',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Ingresa tu correo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _activarPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Crea tu Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => v == null || v.length < 6 ? 'La contraseña debe tener mínimo 6 caracteres' : null,
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
            onPressed: _procesarActivacion,
            child: const Text('Activar Acceso'),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarActivacion() async {
    if (!_activarKey.currentState!.validate()) return;
    Navigator.pop(context);
    setState(() => _cargando = true);

    try {
      await _authService.activarCuentaCliente(
        email: _activarEmailController.text.trim(),
        password: _activarPasswordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Cuenta activada con éxito! Ya puedes iniciar sesión.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        _mostrarError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }
    void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _activarEmailController.dispose();
    _activarPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(30),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.construction_rounded, size: 60, color: Theme.of(context).primaryColor),
                const SizedBox(height: 15),
                const Text(
                  'Sistema de Mantenimiento',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F2537)),
                ),
                const SizedBox(height: 5),
                Text(
                  'Por favor inicia sesión para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Ingresa tu correo' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Ingresa tu contraseña' : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _cargando ? null : _intentarLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _cargando
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Ingresar al Sistema', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _cargando ? null : _mostrarDialogoActivacion,
                  child: const Text(
                    '¿Eres un cliente nuevo? Activa tu cuenta aquí',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F2537)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
