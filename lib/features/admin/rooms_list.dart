import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_navbar.dart';

class RoomsListPage extends StatefulWidget {
  const RoomsListPage({super.key});

  @override
  State<RoomsListPage> createState() => _RoomsListPageState();
}

class _RoomsListPageState extends State<RoomsListPage> {
  int _selectedIndex = 2;

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

  // ================================
  // AGREGAR SALÓN
  // ================================
  void _showAddRoomDialog() {
    final nameCtrl = TextEditingController();
    final capacityCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Agregar salón"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: capacityCtrl,
                decoration: const InputDecoration(labelText: "Capacidad"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection("rooms").add({
                  "name": nameCtrl.text.trim(),
                  "capacity": int.tryParse(capacityCtrl.text.trim()) ?? 0,
                  "description": descCtrl.text.trim(),
                  "active": true,
                  "disabledReason": "",
                });

                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // ================================
  // DESACTIVAR CON MOTIVO
  // ================================
  void _deactivateRoom(String id) {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Desactivar salón"),
          content: TextField(
            controller: reasonCtrl,
            decoration:
                const InputDecoration(labelText: "Motivo de desactivación"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection("rooms").doc(id).update({
                  "active": false,
                  "disabledReason": reasonCtrl.text.trim(),
                });

                Navigator.pop(context);
              },
              child: const Text("Desactivar"),
            ),
          ],
        );
      },
    );
  }

  // ACTIVAR SALÓN
  void _activateRoom(String id) {
    FirebaseFirestore.instance.collection("rooms").doc(id).update({
      "active": true,
      "disabledReason": "",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Salones"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddRoomDialog,
          )
        ],
      ),

      bottomNavigationBar: AdminNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("rooms")
            .orderBy("name")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = snapshot.data!.docs;

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (_, i) {
              final doc = rooms[i];
              final room = doc.data() as Map<String, dynamic>;

              final isActive = room["active"] ?? true;

              return Card(
                margin: const EdgeInsets.all(12),
                color: isActive ? Colors.white : Colors.grey.shade200,
                child: ListTile(
                  title: Text(
                    room["name"] ?? "",
                    style: TextStyle(
                      color: isActive ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Capacidad: ${room["capacity"]}"),
                      Text(room["description"] ?? ""),

                      if (!isActive)
                        Text(
                          "⚠️ Desactivado: ${room["disabledReason"]}",
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                  isThreeLine: true,

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Editar salón
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            "/edit_room",
                            arguments: {"id": doc.id, "data": room},
                          );
                        },
                      ),

                      // Activar / Desactivar
                      IconButton(
                        icon: Icon(
                          isActive ? Icons.hide_source : Icons.check_circle,
                          color: isActive ? Colors.red : Colors.green,
                        ),
                        onPressed: () {
                          if (isActive) {
                            _deactivateRoom(doc.id);
                          } else {
                            _activateRoom(doc.id);
                          }
                        },
                      ),
                    ],
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
