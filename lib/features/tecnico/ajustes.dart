import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tech_navbar.dart';

class TechSettingsPage extends StatefulWidget {
  const TechSettingsPage({super.key});

  @override
  State<TechSettingsPage> createState() => _TechSettingsPageState();
}

class _TechSettingsPageState extends State<TechSettingsPage> {
  int _selectedIndex = 4; // Ajustes es pestaña 4

  void _onTap(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, "/tech_reservations");
        break;
      case 1:
        Navigator.pushReplacementNamed(context, "/tech_users");
        break;
      case 2:
        Navigator.pushReplacementNamed(context, "/tech_rooms");
        break;
      case 3:
        Navigator.pushReplacementNamed(context, "/tech_calendar");
        break;
      case 4:
        Navigator.pushReplacementNamed(context, "/tech_settings");
        break;
    }
  }

  // 🔐 Cambiar contraseña
  void _changePassword() {
    final email = FirebaseAuth.instance.currentUser?.email ?? "correo no disponible";

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Cambiar contraseña"),
          content: Text(
            "Se enviará un correo para restablecer tu contraseña a:\n\n$email",
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Enviar"),
              onPressed: () async {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Correo enviado. Revisa tu bandeja."),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // 🔒 Cerrar sesión
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6A5AE0),
        centerTitle: true,
        title: const Text(
          "Ajustes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 2,
      ),

      bottomNavigationBar: TechNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🧑‍🔧 Perfil técnico
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFFE8E0FF),
                  child: const Icon(
                    Icons.engineering,
                    size: 32,
                    color: Color(0xFF6A5AE0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? "Técnico",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Usuario técnico del sistema",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            "Configuración",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A4EB7),
            ),
          ),

          const SizedBox(height: 14),

          // 🔧 Cambiar contraseña
          _settingsTile(
            icon: Icons.lock_reset,
            title: "Cambiar contraseña",
            onTap: _changePassword,
          ),

          // 📞 Soporte
          _settingsTile(
            icon: Icons.help_outline,
            title: "Soporte técnico",
            subtitle: "resersala.soporte@gmail.com",
            onTap: () {},
          ),

          const SizedBox(height: 30),

          // 🔴 Cerrar sesión
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text(
              "Cerrar sesión",
              style: TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _logout,
          )
        ],
      ),
    );
  }

  // 🌟 Tile bonito reutilizable
  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8E0FF),
          child: Icon(icon, color: const Color(0xFF6A5AE0)),
        ),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
        onTap: onTap,
      ),
    );
  }
}
