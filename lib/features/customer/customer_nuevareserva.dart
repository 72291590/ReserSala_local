import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:resersala/features/customer/calendar_page.dart'; // 🔥 IMPORTANTE

class NewReservationPage extends StatefulWidget {
  const NewReservationPage({super.key});

  @override
  State<NewReservationPage> createState() => _NewReservationPageState();
}

class _NewReservationPageState extends State<NewReservationPage> {
  final _formKey = GlobalKey<FormState>();

  String? _room;
  DateTime? _date;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final TextEditingController _resourcesController = TextEditingController();

  // ==========================================================
  // 📅 Selección de fecha (CORREGIDA)
  // ==========================================================
  Future<void> _selectDate() async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CalendarPage(selectMode: true), // 🔥 MODO SELECCIÓN
      ),
    );

    if (selected != null && selected is DateTime) {
      setState(() => _date = selected);
      print("📅 Fecha seleccionada: $_date");
    }
  }

  // ==========================================================
  // ⏰ Selección de hora
  // ==========================================================
  Future<void> _pickTime(bool start) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      setState(() {
        if (start) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  // ==========================================================
  // 💾 Guardar reserva con validación de horarios
  // ==========================================================
  Future<void> _saveReservation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_date == null || _startTime == null || _endTime == null) {
      _msg("Completa fecha y horarios");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final start = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _startTime!.hour,
      _startTime!.minute,
    );

    final end = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _endTime!.hour,
      _endTime!.minute,
    );

    if (end.isBefore(start)) {
      _msg("La hora final debe ser mayor a la inicial");
      return;
    }

    // ==========================================================
    // 🔥 Validación de cruce de horarios
    // ==========================================================
    final query = await FirebaseFirestore.instance
        .collection("reservations")
        .where("roomId", isEqualTo: _room)
        .where("start",
            isGreaterThanOrEqualTo: DateTime(_date!.year, _date!.month, _date!.day))
        .where("start",
            isLessThanOrEqualTo:
                DateTime(_date!.year, _date!.month, _date!.day, 23, 59))
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final existingStart = (data["start"] as Timestamp).toDate();
      final existingEnd = (data["end"] as Timestamp).toDate();

      final overlap =
          start.isBefore(existingEnd) && end.isAfter(existingStart);

      if (overlap) {
        _msg("Este salón ya está ocupado en ese horario");
        return;
      }
    }

    // ==========================================================
    // 🟢 Reserva válida → Guardar
    // ==========================================================
    await FirebaseFirestore.instance.collection("reservations").add({
      "userId": user.uid,
      "roomId": _room,
      "start": start,
      "end": end,
      "resourcesText": _resourcesController.text.trim(),
      "status": "Pendiente",
      "createdAt": FieldValue.serverTimestamp(),
    });

    _msg("Reserva enviada correctamente");
    Navigator.pop(context);
  }

  // ==========================================================
  // 🔔 SnackBar helper
  // ==========================================================
  void _msg(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  // ==========================================================
  // 🖼️ UI
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Reserva")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Completa los datos de tu reserva:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Salón
              StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                .collection("rooms")
                .where("active", isEqualTo: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Text(
                    "No hay salones disponibles",
                    style: TextStyle(color: Colors.red),
                  );
                }

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Seleccionar salón",
                    border: OutlineInputBorder(),
                  ),
                  value: _room,
                  items: docs.map((QueryDocumentSnapshot doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return DropdownMenuItem<String>(
                      value: data["name"],
                      child: Text(data["name"]),
                    );
                  }).toList(),
                  validator: (v) => v == null ? "Debe seleccionar un salón" : null,
                  onChanged: (v) => setState(() => _room = v),
                );
              },
            ),


              // Fecha
              ListTile(
                title: Text(
                  _date == null
                      ? "Seleccione una fecha"
                      : "${_date!.day}/${_date!.month}/${_date!.year}",
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: _selectDate,
              ),
              const SizedBox(height: 20),

              // Horas
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text(_startTime == null
                          ? "Hora inicio"
                          : _startTime!.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text(_endTime == null
                          ? "Hora fin"
                          : _endTime!.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Recursos adicionales
              const Text(
                "Recursos adicionales solicitados",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _resourcesController,
                decoration: const InputDecoration(
                  hintText: "Ejemplo: 20 sillas, proyector, laptop...",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text("Enviar solicitud"),
                onPressed: _saveReservation,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
