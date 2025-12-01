import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tech_navbar.dart';

class TechSettingsPage extends StatefulWidget {
  const TechSettingsPage({super.key});

  @override
  State<TechSettingsPage> createState() => _TechSettingsPageState();
}

class _TechSettingsPageState extends State<TechSettingsPage> {
  int _selectedIndex = 4; // Ajustes técnico

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    if (index == 0) Navigator.pushReplacementNamed(context, "/tech_reservations");
    if (index == 1) Navigator.pushReplacementNamed(context, "/tech_users");
    if (index == 2) Navigator.pushReplacementNamed(context, "/tech_rooms");
    if (index == 3) Navigator.pushReplacementNamed(context, "/tech_calendar");
    if (index == 4) Navigator.pushReplacementNamed(context, "/tech_settings");
  }

  // ---------------------------------------------------------
  // CERRAR SESIÓN
  // ---------------------------------------------------------
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
    }
  }

  // ---------------------------------------------------------
  // CAMBIAR CONTRASEÑA
  // ---------------------------------------------------------
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
        backgroundColor: const Color(0xFF6A5AE0),
        title: const Text("Ajustes"),
        centerTitle: true,
      ),

      bottomNavigationBar: TechNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ======================================
          // PERFIL DEL TECNICO
          // ======================================
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFE8E0FF),
                child: Icon(Icons.engineering, size: 28, color: Color(0xFF6A5AE0)),
              ),
              title: Text(user?.email ?? "Técnico"),
              subtitle: const Text("Usuario técnico del sistema"),
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
