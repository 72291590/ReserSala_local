import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRoomPage extends StatefulWidget {
  const AddRoomPage({super.key});

  @override
  State<AddRoomPage> createState() => _AddRoomPageState();
}

class _AddRoomPageState extends State<AddRoomPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _name = TextEditingController();
  final TextEditingController _capacity = TextEditingController();
  final TextEditingController _desc = TextEditingController();

  Future<void> saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance.collection("rooms").add({
      "name": _name.text.trim(),
      "capacity": int.tryParse(_capacity.text) ?? 0,
      "description": _desc.text.trim(),
      "createdAt": Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Salón")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: "Nombre del salón"),
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
                onPressed: saveRoom,
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
