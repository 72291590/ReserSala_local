import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tech_navbar.dart';

class TechReservationsPage extends StatefulWidget {
  const TechReservationsPage({super.key});

  @override
  State<TechReservationsPage> createState() => _TechReservationsPageState();
}

class _TechReservationsPageState extends State<TechReservationsPage> {
  int _selectedIndex = 0;

  void _onTap(int index) {
    if (index == _selectedIndex) return;

    setState(() => _selectedIndex = index);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6A5AE0),
        title: const Text("Reservas Aprobadas"),
        centerTitle: true,
        elevation: 2,
      ),

      bottomNavigationBar: TechNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reservations")
            .where("status", isEqualTo: "Aprobado")
            .orderBy("start", descending: false)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No hay reservas aprobadas",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;

              final start = (data["start"] as Timestamp).toDate();
              final end = (data["end"] as Timestamp).toDate();
              final room = data["roomId"] ?? "Sin sala";

              String formatTime(DateTime dt) {
                final hh = dt.hour.toString().padLeft(2, '0');
                final mm = dt.minute.toString().padLeft(2, '0');
                return "$hh:$mm";
              }

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/reservation_detail",
                    arguments: docs[i].id, // 🔥 Enviamos ID real
                  );
                },

                child: Card(
                  elevation: 3,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Salón: $room",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color(0xFF3A3D98),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "${start.day}/${start.month}/${start.year}",
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(Icons.alarm, size: 18, color: Colors.red),
                            const SizedBox(width: 6),
                            Text(
                              "${formatTime(start)} - ${formatTime(end)}",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "Estado: Aprobado",
                          style: TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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
}
