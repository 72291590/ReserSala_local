import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'admin_navbar.dart';

class AdminCalendarPage extends StatefulWidget {
  const AdminCalendarPage({super.key});

  @override
  State<AdminCalendarPage> createState() => _AdminCalendarPageState();
}

class _AdminCalendarPageState extends State<AdminCalendarPage> {
  int _selectedIndex = 4; // Puedes cambiar la pestaña seleccionada
  CalendarFormat _formato = CalendarFormat.month;
  DateTime _diaEnfocado = DateTime.now();
  DateTime? _diaSeleccionado;

  Map<DateTime, List<Map<String, dynamic>>> _eventos = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _cargarReservas();
  }

  // ================================
  // 🔽 NAVBAR
  // ================================
  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);

   if (index == 0) Navigator.pushReplacementNamed(context, "/admin_reservations");
    if (index == 1) Navigator.pushReplacementNamed(context, "/admin_dashboard");
    if (index == 2) Navigator.pushReplacementNamed(context, "/rooms");
    if (index == 3) Navigator.pushReplacementNamed(context, "/users");
    if (index == 4) Navigator.pushReplacementNamed(context, "/admin_calendar");
    if (index == 5) Navigator.pushReplacementNamed(context, "/admin_settings");
  }

  // ================================
  // 🔽 Funciones de calendario
  // ================================
  DateTime _normalizarDia(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _cargarReservas() async {
    final snap = await FirebaseFirestore.instance
        .collection("reservations")
        .get();

    Map<DateTime, List<Map<String, dynamic>>> data = {};

    for (var doc in snap.docs) {
      final reserva = doc.data();
      final DateTime inicio = (reserva["start"] as Timestamp).toDate();
      final dia = _normalizarDia(inicio);

      data.putIfAbsent(dia, () => []);
      data[dia]!.add(reserva);
    }

    setState(() => _eventos = data);
  }

  List<Map<String, dynamic>> _obtenerEventosDelDia(DateTime dia) {
    return _eventos[_normalizarDia(dia)] ?? [];
  }

  Color _colorPorEstado(String estado) {
    switch (estado) {
      case "Aprobado":
        return Colors.green;
      case "Pendiente":
        return Colors.orange;
      case "Rechazado":
        return Colors.red;
      case "completed":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // ================================
  // 🔽 UI
  // ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,  // ❌ Sin flecha
        title: const Text("Calendario General"),
        centerTitle: true,
      ),

      // ⭐ NAVBAR
      bottomNavigationBar: AdminNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),

      body: Column(
        children: [
          // ================================
          // 📅 CALENDARIO
          // ================================
          TableCalendar(
            locale: 'es_ES',
            firstDay: DateTime(2020),
            lastDay: DateTime(2050),
            focusedDay: _diaEnfocado,
            calendarFormat: _formato,

            selectedDayPredicate: (dia) => isSameDay(_diaSeleccionado, dia),

            eventLoader: _obtenerEventosDelDia,

            onDaySelected: (seleccionado, enfocado) {
              setState(() {
                _diaSeleccionado = seleccionado;
                _diaEnfocado = enfocado;
              });
            },

            onFormatChanged: (formato) {
              setState(() => _formato = formato);
            },

            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonTextStyle: TextStyle(color: Colors.black),
              formatButtonDecoration: BoxDecoration(
                color: Color(0xFFE8E8E8),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),

            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ================================
          // 📋 LISTA DE RESERVAS DEL DÍA
          // ================================
          Expanded(
            child: _diaSeleccionado == null ||
                    _obtenerEventosDelDia(_diaSeleccionado!).isEmpty
                ? const Center(
                    child: Text(
                      "No hay reservas para este día",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView(
                    children: _obtenerEventosDelDia(_diaSeleccionado!)
                        .map((evento) {
                      final inicio =
                          (evento["start"] as Timestamp).toDate();
                      final fin =
                          (evento["end"] as Timestamp).toDate();

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _colorPorEstado(evento["status"]),
                          ),
                          title: Text(evento["roomId"]),
                          subtitle: Text(
                            "${inicio.hour}:00 - ${fin.hour}:00\n"
                            "Estado: ${evento["status"]}",
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
