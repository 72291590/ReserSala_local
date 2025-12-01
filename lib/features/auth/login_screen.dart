import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // 🌈 Fondo azul profesional
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF003C8F), // azul oscuro
              Color(0xFF1565C0), // azul intermedio
              Color(0xFF1E88E5), // azul claro
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26),

            child: Column(
              children: [
                const SizedBox(height: 20),

                // LOGO
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(
                    Icons.meeting_room,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 18),

                // TÍTULO
                const Text(
                  "ReserSala",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Sistema de reservas de salas",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),

                const SizedBox(height: 28),

                // TARJETA BLANCA
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 26),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // EMAIL
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Correo institucional",
                            labelStyle:
                                const TextStyle(color: Colors.white70),
                            prefixIcon:
                                const Icon(Icons.email, color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Colors.white),
                            ),
                          ),
                          onChanged: (value) => email = value,
                          validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? "Ingrese correo"
                                  : null,
                        ),

                        const SizedBox(height: 18),

                        // PASSWORD
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            labelStyle:
                                const TextStyle(color: Colors.white70),
                            prefixIcon:
                                const Icon(Icons.lock, color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Colors.white54),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: Colors.white),
                            ),
                          ),
                          obscureText: true,
                          onChanged: (value) => password = value,
                          validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? "Ingrese contraseña"
                                  : null,
                        ),

                        const SizedBox(height: 20),

                        // ERROR
                        if (authVM.error != null)
                          Text(
                            authVM.error!,
                            style: const TextStyle(
                                color: Colors.yellowAccent,
                                fontWeight: FontWeight.bold),
                          ),

                        const SizedBox(height: 22),

                        // BOTÓN EN BLANCO
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: authVM.isLoading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }

                                    await authVM.login(
                                      email: email,
                                      password: password,
                                    );

                                    final role = authVM.user?.role;

                                    if (role == null) return;

                                    switch (role) {
                                      case 'admin':
                                        Navigator.pushReplacementNamed(
                                            context, '/home_admin');
                                        break;

                                      case 'tecnico':
                                        Navigator.pushReplacementNamed(
                                            context, '/tech_reservations');
                                        break;

                                      default:
                                        Navigator.pushReplacementNamed(
                                            context, '/home_customer');
                                        break;
                                    }
                                  },
                            child: authVM.isLoading
                                ? const CircularProgressIndicator(
                                    color: Color(0xFF003C8F),
                                    strokeWidth: 2,
                                  )
                                : const Text(
                                    "Ingresar",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF003C8F),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/register');
                          },
                          child: const Text(
                            "¿No tienes cuenta? Regístrate",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
