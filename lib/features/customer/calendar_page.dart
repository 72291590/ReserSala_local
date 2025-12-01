import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarPage extends StatefulWidget {
  final bool selectMode; // 🔥 NUEVO: modo selector

  const CalendarPage({super.key, this.selectMode = false});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Map<DateTime, List<Map<String, dynamic>>> events = {};

  @override
  void initState() {
    super.initState();
    loadReservations();
  }

  /// Cargar reservas desde Firestore
  Future<void> loadReservations() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("reservations").get();

    Map<DateTime, List<Map<String, dynamic>>> temp = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = (data["start"] as Timestamp).toDate();
      final day = DateTime(date.year, date.month, date.day);

      temp.putIfAbsent(day, () => []);
      temp[day]!.add({
        "room": data["roomId"],
        "start": date,
        "end": (data["end"] as Timestamp).toDate(),
        "status": data["status"],
      });
    }

    setState(() => events = temp);
  }

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  final List<Map<String, dynamic>> horarios = [
    {"inicio": 8, "fin": 10},
    {"inicio": 10, "fin": 12},
    {"inicio": 12, "fin": 14},
    {"inicio": 14, "fin": 16},
    {"inicio": 16, "fin": 18},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectMode
            ? "Selecciona una fecha"
            : "Calendario de Reservas"),
        centerTitle: true,
      ),

      // 🔥 SOLO aparece en modo normal
      floatingActionButton: (!widget.selectMode && _selectedDay != null)
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, "/new_reservation", arguments: {
                  "selectedDay": _selectedDay,
                });
              },
              label: const Text("Crear reserva"),
              icon: const Icon(Icons.add),
            )
          : null,

      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarFormat: _calendarFormat,

            eventLoader: getEventsForDay,

            availableCalendarFormats: const {
              CalendarFormat.month: "Mes",
              CalendarFormat.twoWeeks: "2 semanas",
              CalendarFormat.week: "Semana",
            },

            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              // 🔥 SI ES MODO SELECCIÓN → DEVUELVE LA FECHA Y CIERRA
              if (widget.selectMode) {
                Navigator.pop(context, selectedDay);
              }
            },

            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),

            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonDecoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              formatButtonTextStyle: const TextStyle(color: Colors.white),
            ),
          ),

          const SizedBox(height: 10),

          // 🔥 En modo selección NO mostramos detalles
          if (!widget.selectMode)
            Expanded(
              child: _selectedDay == null
                  ? const Center(child: Text("Selecciona un día"))
                  : _buildDayDetails(),
            ),
        ],
      ),
    );
  }

  Widget _buildDayDetails() {
    final reservas = getEventsForDay(_selectedDay!);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView(
        children: [
          const Text(
            "Reservas del día",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (reservas.isEmpty)
            const Text("No hay reservas en este día"),

          ...reservas.map((res) => Card(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text("Salón ${res["room"]}"),
                  subtitle: Text(
                    "${res["start"].hour}:00 - ${res["end"].hour}:00 | Estado: ${res["status"]}",
                  ),
                ),
              )),
          const SizedBox(height: 20),

          const Text(
            "Disponibilidad",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          ...horarios.map((h) {
            bool ocupado = reservas.any((r) =>
                r["start"].hour == h["inicio"] &&
                r["end"].hour == h["fin"]);

            return Card(
              color: ocupado ? Colors.red.shade100 : Colors.green.shade100,
              child: ListTile(
                leading: Icon(
                  ocupado ? Icons.lock : Icons.lock_open,
                  color: ocupado ? Colors.red : Colors.green,
                ),
                title: Text("${h["inicio"]}:00 - ${h["fin"]}:00"),
                subtitle:
                    Text(ocupado ? "No disponible" : "Disponible"),
              ),
            );
          }),
        ],
      ),
    );
  }
}
