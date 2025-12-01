import 'package:flutter/material.dart';

class TechNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const TechNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: "Reservas",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: "Usuarios",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.meeting_room),
          label: "Salones",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: "Calendario",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Ajustes",
        ),
      ],
    );
  }
}
