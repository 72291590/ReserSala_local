import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tech_navbar.dart';

class TechRoomsPage extends StatefulWidget {
  const TechRoomsPage({super.key});

  @override
  State<TechRoomsPage> createState() => _TechRoomsPageState();
}

class _TechRoomsPageState extends State<TechRoomsPage> {
  int _selectedIndex = 2;

  void _onTap(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

    if (index == 0) Navigator.pushReplacementNamed(context, "/tech_reservations");
    if (index == 1) Navigator.pushReplacementNamed(context, "/tech_users");
    if (index == 3) Navigator.pushReplacementNamed(context, "/tech_calendar");
    if (index == 4) Navigator.pushReplacementNamed(context, "/tech_settings");
  }

  // 🔥 Bloquear salón (con motivo)
  void _disableRoom(String id) {
    showDialog(
      context: context,
      builder: (_) {
        final reasonCtrl = TextEditingController();

        return AlertDialog(
          title: const Text("Bloquear salón"),
          content: TextField(
            controller: reasonCtrl,
            decoration: const InputDecoration(labelText: "Motivo de bloqueo"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection("rooms").doc(id).update({
                  "disabled": true,
                  "disableReason": reasonCtrl.text.trim(),
                });
                Navigator.pop(context);
              },
              child: const Text("Confirmar"),
            )
          ],
        );
      },
    );
  }

  // 🔥 Habilitar salón
  void _enableRoom(String id) {
    FirebaseFirestore.instance.collection("rooms").doc(id).update({
      "disabled": false,
      "disableReason": "",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Salones")),
      bottomNavigationBar:
          TechNavbar(currentIndex: _selectedIndex, onTap: _onTap),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("rooms").snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final rooms = snapshot.data!.docs;

          return ListView(
            children: rooms.map((r) {
              final data = r.data() as Map<String, dynamic>;
              final disabled = data["disabled"] ?? false;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  title: Text(
                    data["name"],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Capacidad: ${data["capacity"]}"),

                  // 🔥 SWITCH INVERTIDO (igual que usuarios)
                  trailing: Switch(
                    value: !disabled, // ON = salón habilitado
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.black,
                    inactiveTrackColor: Colors.grey[400],
                    onChanged: (val) {
                      if (val) {
                        // Activar salón
                        _enableRoom(r.id);
                      } else {
                        // Desactivar salón con motivo
                        _disableRoom(r.id);
                      }
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
