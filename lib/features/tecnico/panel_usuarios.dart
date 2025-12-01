import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tech_navbar.dart';

class TechUsersPage extends StatefulWidget {
  const TechUsersPage({super.key});

  @override
  State<TechUsersPage> createState() => _TechUsersPageState();
}

class _TechUsersPageState extends State<TechUsersPage> {
  int _selectedIndex = 1;

  void _onTap(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    if (index == 0) Navigator.pushReplacementNamed(context, "/tech_reservations");
    if (index == 2) Navigator.pushReplacementNamed(context, "/tech_rooms");
    if (index == 3) Navigator.pushReplacementNamed(context, "/tech_calendar");
    if (index == 4) Navigator.pushReplacementNamed(context, "/tech_settings");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Usuarios")),
      bottomNavigationBar: TechNavbar(currentIndex: _selectedIndex, onTap: _onTap),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final users = snapshot.data!.docs;

          return ListView(
            children: users.map((u) {
              final data = u.data() as Map<String, dynamic>;
              final disabled = data["disabled"] ?? false;

                            return Card(
                child: ListTile(
                  title: Text(data["name"] ?? "Sin nombre"),
                  subtitle: Text(data["email"] ?? ""),

                  trailing: Switch(
                    value: !disabled,            // 🔥 Activo → verde
                    activeColor: Colors.green,   // color ON
                    inactiveThumbColor: Colors.black54, // 🔥 usuario bloqueado → negro
                    inactiveTrackColor: Colors.grey[400],
                    onChanged: (val) {
                      FirebaseFirestore.instance
                          .collection("users")
                          .doc(u.id)
                          .update({"disabled": !val});   // 🔥 Guarda invertido en BD
                    },
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
