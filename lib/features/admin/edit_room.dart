import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditRoomPage extends StatefulWidget {
  final String id;
  final Map<String, dynamic> room;

  const EditRoomPage({super.key, required this.id, required this.room});

  @override
  State<EditRoomPage> createState() => _EditRoomPageState();
}

class _EditRoomPageState extends State<EditRoomPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _name;
  late TextEditingController _capacity;
  late TextEditingController _desc;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.room["name"]);
    _capacity = TextEditingController(text: widget.room["capacity"].toString());
    _desc = TextEditingController(text: widget.room["description"]);
  }

  Future<void> updateRoom() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection("rooms")
        .doc(widget.id)
        .update({
      "name": _name.text.trim(),
      "capacity": int.tryParse(_capacity.text) ?? 0,
      "description": _desc.text.trim(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Salón")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _capacity,
                decoration: const InputDecoration(labelText: "Capacidad"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: "Descripción"),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: updateRoom,
                child: const Text("Guardar Cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
