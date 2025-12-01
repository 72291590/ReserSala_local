import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_navbar.dart';

class AdminAllReservationsScreen extends StatefulWidget {
  const AdminAllReservationsScreen({super.key});

  @override
  State<AdminAllReservationsScreen> createState() =>
      _AdminAllReservationsScreenState();
}

class _AdminAllReservationsScreenState
    extends State<AdminAllReservationsScreen> {
  int _selectedIndex = 0;

  // ===========================
  //  NAVBAR
  // ===========================
  void _onTabTapped(int index) {
  if (index == _selectedIndex) return; // No recargar la misma pantalla

  setState(() => _selectedIndex = index);

  if (index == 0) {
    Navigator.pushReplacementNamed(context, "/admin_reservations");
  } else if (index == 1) {
    Navigator.pushReplacementNamed(context, "/admin_dashboard");
  } else if (index == 2) {
    Navigator.pushReplacementNamed(context, "/rooms");
  } else if (index == 3) {
    Navigator.pushReplacementNamed(context, "/users");
  } else if (index == 4) {
    Navigator.pushReplacementNamed(context, "/admin_calendar");
  } else if (index == 5) {
    Navigator.pushReplacementNamed(context, "/admin_settings");
  } 
}


  // ===========================
  //  OBTENER DATOS DE USUARIO
  // ===========================
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final doc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    return doc.data();
  }

  // ===========================
  //  ENVIAR NOTIFICACIÓN FIRESTORE
  // ===========================
  Future<void> sendNotificationToUser(
      String userId, String title, String body, String type) async {
    final ref = FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("notifications")
        .doc();

    await ref.set({
      "title": title,
      "body": body,
      "type": type,
      "read": false,
      "timestamp": Timestamp.now(),
    });
  }

  // ===========================
  //  ACTUALIZAR ESTADO + NOTIFICAR
  // ===========================
  Future<void> updateStatus(
      String reservationId, String status, String userId, String roomName) async {
    await FirebaseFirestore.instance
        .collection("reservations")
        .doc(reservationId)
        .update({"status": status});

    String title = "";
    String body = "";
    String type = "";

    if (status == "Aprobado") {
      title = "Reserva aprobada";
      body = "Tu reserva del salón $roomName ha sido aprobada ✔";
      type = "approved";
    } else if (status == "Rechazado") {
      title = "Reserva rechazada";
      body = "Tu solicitud del salón $roomName ha sido rechazada ❌";
      type = "rejected";
    } else if (status == "completed") {
      title = "Reserva finalizada";
      body = "Tu reserva en $roomName ha finalizado.";
      type = "completed";
    }

    await sendNotificationToUser(userId, title, body, type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Estado actualizado: $status")),
    );
  }

  // ===========================
  //  UI PRINCIPAL
  // ===========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todas las Reservas"),
        centerTitle: true,
      ),

      bottomNavigationBar: AdminNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reservations")
            .orderBy("start", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No hay reservas registradas"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final id = docs[i].id;

              final room = data["roomId"];
              final status = data["status"];
              final userId = data["userId"];
              final start = (data["start"] as Timestamp).toDate();
              final end = (data["end"] as Timestamp).toDate();
              final resources = data["resourcesText"] ?? "";

              return FutureBuilder(
                future: getUserData(userId),
                builder: (context, snapshotUser) {
                  final user = snapshotUser.data;
                  final name = user?["name"] ?? "Usuario desconocido";
                  final email = user?["email"] ?? "";

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SALÓN
                          Text(
                            "Salón: $room",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // FECHA Y HORAS
                          Text(
                            "${start.day}/${start.month}/${start.year} "
                            "(${start.hour}:00 - ${end.hour}:00)",
                            style: const TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 10),

                          // USUARIO
                          Text("👤 $name", style: const TextStyle(fontSize: 16)),
                          if (email.isNotEmpty)
                            Text("📧 $email",
                                style: const TextStyle(color: Colors.black54)),

                          const SizedBox(height: 10),

                          // RECURSOS
                          if (resources.isNotEmpty)
                            Text("📌 Recursos: $resources"),

                          const SizedBox(height: 12),

                          // ESTADO
                          Chip(
                            label: Text(status.toUpperCase()),
                            backgroundColor: status == "Aprobado"
                                ? Colors.green.shade200
                                : status == "Rechazado"
                                    ? Colors.red.shade200
                                    : status == "completed"
                                        ? Colors.blue.shade200
                                        : Colors.orange.shade200,
                          ),

                          const SizedBox(height: 15),

                          // BOTONES
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    updateStatus(id, "Aprobado", userId, room),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text("Aprobar"),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    updateStatus(id, "Rechazado", userId, room),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text("Rechazar"),
                              ),
                              ElevatedButton(
                                onPressed: () => updateStatus(
                                    id, "completed", userId, room),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Text("Finalizar"),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
