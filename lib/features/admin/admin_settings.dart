import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_navbar.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  int _selectedIndex = 5; // Ajustes es la pestaña 5

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    if (index == 0) Navigator.pushReplacementNamed(context, "/admin_reservations");
    if (index == 1) Navigator.pushReplacementNamed(context, "/admin_dashboard");
    if (index == 2) Navigator.pushReplacementNamed(context, "/rooms");
    if (index == 3) Navigator.pushReplacementNamed(context, "/users");
    if (index == 4) Navigator.pushReplacementNamed(context, "/admin_calendar");
    if (index == 5) Navigator.pushReplacementNamed(context, "/admin_settings");
  }

  // Cerrar sesión
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
    }
  }

  // Cambiar contraseña
  void _changePassword() {
    final email = FirebaseAuth.instance.currentUser?.email ?? "";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Cambiar contraseña"),
          content: Text(
            "Se enviará un correo a:\n\n$email\n\n"
            "¿Deseas continuar?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Correo enviado. Revisa tu bandeja para restablecer."),
                  ),
                );
              },
              child: const Text("Enviar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Ajustes"),
        centerTitle: true,
      ),

      bottomNavigationBar: AdminNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ======================================
          // PERFIL DEL ADMIN
          // ======================================
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                radius: 24,
                child: Icon(Icons.admin_panel_settings, size: 28),
              ),
              title: Text(user?.email ?? "Administrador"),
              subtitle: const Text("Administrador del sistema"),
            ),
          ),

          const SizedBox(height: 20),

          // ======================================
          // OPCIONES
          // ======================================
          const Text(
            "Configuración",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          ListTile(
            leading: const Icon(Icons.lock_reset),
            title: const Text("Cambiar contraseña"),
            onTap: _changePassword,
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Soporte técnico"),
            subtitle: const Text("resersala.soporte@gmail.com"),
            onTap: () {},
          ),

          const SizedBox(height: 20),

          // ======================================
          // CERRAR SESIÓN
          // ======================================
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Cerrar sesión"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _logout,
            ),
          ),
        ],
      ),
    );
  }
}
