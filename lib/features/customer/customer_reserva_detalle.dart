import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationDetailPage extends StatelessWidget {
  const ReservationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reservationId = ModalRoute.of(context)!.settings.arguments as String;

    final docRef = FirebaseFirestore.instance
        .collection("reservations")
        .doc(reservationId);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6A5AE0),
        elevation: 2,
        centerTitle: true,
        title: const Text(
          "Detalle de Reserva",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: docRef.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (!snapshot.data!.exists) return const Center(child: Text("Reserva no encontrada"));

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final room = data["roomId"] ?? "Sin nombre";
          final status = data["status"] ?? "---";
          final resources = data["resourcesText"] ?? "Sin recursos";
          final start = (data["start"] as Timestamp).toDate();
          final end = (data["end"] as Timestamp).toDate();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionCard(
                  icon: Icons.meeting_room,
                  title: "Salón",
                  value: room,
                ),

                _sectionCard(
                  icon: Icons.check_circle,
                  title: "Estado",
                  value: _statusLabel(status),
                ),

                _sectionCard(
                  icon: Icons.date_range,
                  title: "Fecha",
                  value: "${start.day}/${start.month}/${start.year}",
                ),

                _sectionCard(
                  icon: Icons.access_time,
                  title: "Hora inicio",
                  value:
                      "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}",
                ),

                _sectionCard(
                  icon: Icons.timer_off_rounded,
                  title: "Hora fin",
                  value:
                      "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}",
                ),

                _sectionCard(
                  icon: Icons.inventory_2_rounded,
                  title: "Recursos solicitados",
                  value: resources,
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🌟 Tarjeta bonita
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFE8E0FF),
            child: Icon(icon, color: Color(0xFF6A5AE0), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔵 Estados
  String _statusLabel(String status) {
    switch (status) {
      case "Pendiente":
        return "Pendiente";
      case "Aprobado":
        return "Aprobada";
      case "Rechazado":
        return "Rechazada";
      case "ready":
        return "Preparada por técnico";
      default:
        return status;
    }
  }
}
