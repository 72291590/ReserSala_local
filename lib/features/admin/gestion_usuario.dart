import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resersala/features/admin/admin_navbar.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  int _selectedIndex = 3;

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) Navigator.pushReplacementNamed(context, "/admin_reservations");
    if (index == 1) Navigator.pushReplacementNamed(context, "/admin_dashboard");
    if (index == 2) Navigator.pushReplacementNamed(context, "/rooms");
    if (index == 3) Navigator.pushReplacementNamed(context, "/users");
    if (index == 4) Navigator.pushReplacementNamed(context, "/admin_calendar");
    if (index == 5) Navigator.pushReplacementNamed(context, "/admin_settings");

  }

  // Cambiar estado activo/inactivo
  Future<void> toggleUserStatus(String uid, bool currentStatus) async {
    await FirebaseFirestore.instance.collection("users").doc(uid).update({
      "active": !currentStatus,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            currentStatus ? "Usuario bloqueado" : "Usuario activado"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Usuarios"),
        automaticallyImplyLeading: false,
      ),

      bottomNavigationBar: AdminNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .orderBy("name")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(child: Text("No hay usuarios registrados"));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (_, i) {
              final doc = users[i];
              final data = doc.data() as Map<String, dynamic>;

              final name = data["name"] ?? "Sin nombre";
              final email = data["email"] ?? "Sin email";
              final role = data["role"] ?? "customer";
              final active = data["active"] ?? true;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: active ? Colors.green : Colors.red,
                    child: Icon(
                      active ? Icons.check : Icons.block,
                      color: Colors.white,
                    ),
                  ),

                  title: Text(name),
                  subtitle: Text("$email\nRol: $role"),
                  isThreeLine: true,

                  trailing: Switch(
                    value: active,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                    onChanged: (_) => toggleUserStatus(doc.id, active),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
