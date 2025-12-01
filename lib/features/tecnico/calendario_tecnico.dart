import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tech_navbar.dart';

class TechCalendarPage extends StatefulWidget {
  const TechCalendarPage({super.key});

  @override
  State<TechCalendarPage> createState() => _TechCalendarPageState();
}

class _TechCalendarPageState extends State<TechCalendarPage> {
  int _selectedIndex = 3; // pestaña calendario
  DateTime _selectedDate = DateTime.now();

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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6A5AE0),
        title: const Text(
          "Calendario de Reservas",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          // Filtramos las reservas del día seleccionado
          final dayReservations = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final start = (data["start"] as Timestamp).toDate();
            return _isSameDay(start, _selectedDate);
          }).toList();

          return Column(
            children: [
              // 📅 Calendario
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CalendarDatePicker(
                  initialDate: _selectedDate,
                  firstDate: DateTime(DateTime.now().year - 1),
                  lastDate: DateTime(DateTime.now().year + 2),
                  onDateChanged: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
              ),

              // 📝 Título del día seleccionado
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Reservas aprobadas para "
                    "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A4EB7),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // 📋 Lista de reservas del día
              Expanded(
                child: dayReservations.isEmpty
                    ? const Center(
                        child: Text(
                          "No hay reservas aprobadas para esta fecha",
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: dayReservations.length,
                        itemBuilder: (_, i) {
                          final doc = dayReservations[i];
                          final data =
                              doc.data() as Map<String, dynamic>;

                          final start =
                              (data["start"] as Timestamp).toDate();
                          final end =
                              (data["end"] as Timestamp).toDate();
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
                                arguments: doc.id,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Ícono
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8E0FF),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.meeting_room,
                                      color: Color(0xFF6A5AE0),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Información
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Salón: $room",
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF3A3D98),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.schedule,
                                              size: 16,
                                              color: Colors.redAccent,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${formatTime(start)} - ${formatTime(end)}",
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "Estado: Aprobado",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
