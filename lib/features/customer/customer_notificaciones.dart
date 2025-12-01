import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notificaciones"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .collection("notifications")
            .orderBy("timestamp", descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar notificaciones"));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                "No tienes notificaciones",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (_, i) {
              final doc = notifications[i];
              final data = doc.data() as Map<String, dynamic>;

              final title = data["title"] ?? "Notificación";
              final body = data["body"] ?? "";
              final type = data["type"] ?? "info"; // approved / rejected / completed
              final isRead = data["read"] ?? false;

              final timestamp = data["timestamp"] as Timestamp?;
              final date = timestamp?.toDate();

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white, size: 28),
                ),
                onDismissed: (_) {
                  FirebaseFirestore.instance
                      .collection("users")
                      .doc(user.uid)
                      .collection("notifications")
                      .doc(doc.id)
                      .delete();
                },

                child: GestureDetector(
                  onTap: () {
                    if (!isRead) {
                      FirebaseFirestore.instance
                          .collection("users")
                          .doc(user.uid)
                          .collection("notifications")
                          .doc(doc.id)
                          .update({"read": true});
                    }
                  },

                  child: Card(
                    elevation: isRead ? 1 : 4,
                    shadowColor: isRead ? Colors.grey : Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),

                      leading: Icon(
                        _getIcon(type),
                        size: 32,
                        color: _getColor(type),
                      ),

                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontWeight:
                                    isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Nuevo",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                        ],
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(body),
                          if (date != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              "${date.day}/${date.month}/${date.year}  ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ====================================================
  //  ICONO SEGÚN TIPO DE NOTIFICACIÓN
  // ====================================================
  IconData _getIcon(String type) {
    switch (type) {
      case "approved":
        return Icons.check_circle;
      case "rejected":
        return Icons.cancel;
      case "completed":
        return Icons.flag;
      default:
        return Icons.notifications;
    }
  }

  // ====================================================
  // COLOR DEL ICONO SEGÚN TIPO
  // ====================================================
  Color _getColor(String type) {
    switch (type) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      case "completed":
        return Colors.blue;
      default:
        return Colors.deepPurple;
    }
  }
}
