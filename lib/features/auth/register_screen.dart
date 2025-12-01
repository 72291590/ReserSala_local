import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';
  String phone = '';
  String role = 'customer';

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE9F0FF),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              // LOGO
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6A5AE0), // Morado
                      Color(0xFF8E7CFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.meeting_room_rounded,
                  size: 45,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Crear cuenta ReserSala",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3D98),
                ),
              ),

              const SizedBox(height: 8),
              const Text(
                "Registra tus datos para continuar",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C6F93),
                ),
              ),

              const SizedBox(height: 25),

              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // NAME
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Nombre completo",
                            prefixIcon: Icon(Icons.person),
                          ),
                          onChanged: (v) => name = v,
                          validator: (v) =>
                              v == null || v.isEmpty ? "Ingrese nombre" : null,
                        ),

                        const SizedBox(height: 12),

                        // EMAIL
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Correo institucional",
                            prefixIcon: Icon(Icons.email_rounded),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (v) => email = v,
                          validator: (v) =>
                              v == null || v.isEmpty ? "Ingrese correo" : null,
                        ),

                        const SizedBox(height: 12),

                        // PASSWORD
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                          obscureText: true,
                          onChanged: (v) => password = v,
                          validator: (v) => v != null && v.length >= 6
                              ? null
                              : "Mínimo 6 caracteres",
                        ),

                        const SizedBox(height: 12),

                        // PHONE
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Teléfono",
                            prefixIcon: Icon(Icons.phone_android_rounded),
                          ),
                          onChanged: (v) => phone = v,
                          validator: (v) =>
                              v == null || v.isEmpty ? "Ingrese teléfono" : null,
                        ),

                        const SizedBox(height: 12),

                        // ROLE UPDATED (solo 4 roles)
                        DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: "Rol en el sistema"),
                          value: role,
                          items: const [
                            DropdownMenuItem(
                                value: "customer", child: Text("Cliente")),
                            DropdownMenuItem(
                                value: "employee", child: Text("Empleado técnico")),
                            DropdownMenuItem(
                                value: "gestor", child: Text("Gestor / Supervisor")),
                            DropdownMenuItem(
                                value: "admin", child: Text("Administrador")),
                          ],
                          onChanged: (v) => setState(() => role = v!),
                        ),

                        const SizedBox(height: 20),

                        if (authVM.error != null)
                          Text(
                            authVM.error!,
                            style:
                                const TextStyle(color: Colors.red, fontSize: 14),
                          ),

                        const SizedBox(height: 16),

                        // BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A5AE0),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: authVM.isLoading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) return;

                                    await authVM.register(
                                      name: name,
                                      email: email,
                                      password: password,
                                      role: role,
                                      phone: phone,
                                    );

                                    if (!mounted) return;

                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  },
                            child: authVM.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Registrar",
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            "¿Ya tienes cuenta? Inicia sesión",
                            style: TextStyle(
                              color: Color(0xFF6A5AE0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
