import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:resersala/widgets/logout_button.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    saveDeviceToken();
    setupForegroundNotifications();
  }

  // =====================================
  // 🔥 GUARDAR TOKEN DEL CELULAR (FCM)
  // =====================================
  Future<void> saveDeviceToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();
    final token = await fcm.getToken();

    if (token != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({"fcmToken": token}, SetOptions(merge: true));
    }
  }

  // =====================================
  // 🔔 NOTIFICACIONES EN PRIMER PLANO
  // =====================================
  void setupForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("notifications")
          .add({
        "title": message.notification?.title ?? "Notificación",
        "body": message.notification?.body ?? "",
        "timestamp": FieldValue.serverTimestamp(),
        "read": false,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${message.notification?.title ?? ""}\n${message.notification?.body ?? ""}",
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final pages = [
      _HomeMainSection(user),
      _MyReservationsPage(user),
      _ProfilePage(user),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF6A5AE0),
        elevation: 2,
        centerTitle: true,
        title: const Text(
          "ReserSala - Cliente",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          _NotificationButton(),
          const LogoutButton(),
        ],
      ),

      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: pages[_currentIndex],
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: const Color(0xFF6A5AE0),
      unselectedItemColor: Colors.grey,
      onTap: (i) => setState(() => _currentIndex = i),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: "Inicio",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_rounded),
          label: "Reservas",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: "Perfil",
        ),
      ],
    );
  }
}

// ----------------------------------------------------------
// 🔔 BOTÓN DE NOTIFICACIONES (SIN FLECHA FEa)
// ----------------------------------------------------------
class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return IconButton(
      onPressed: () => Navigator.pushNamed(context, "/notifications"),
      icon: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("notifications")
            .where("read", isEqualTo: false)
            .snapshots(),
        builder: (_, snapshot) {
          final unread = snapshot.data?.docs.length ?? 0;

          return Stack(
            children: [
              const Icon(Icons.notifications_rounded, size: 30),
              if (unread > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ----------------------------------------------------------
// 🏠 HOME PRINCIPAL (Saludo profesional)
// ----------------------------------------------------------
class _HomeMainSection extends StatelessWidget {
  final User? user;
  const _HomeMainSection(this.user);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: ListView(
        children: [
          const Text(
            "Bienvenido",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          // 🟣 NOMBRE DESDE FIRESTORE
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection("users")
                .doc(user?.uid)
                .get(),
            builder: (_, snap) {
              if (!snap.hasData) return const SizedBox();

              final data = snap.data!.data() as Map<String, dynamic>;
              final name = data["name"] ?? "Cliente";

              return Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              );
            },
          ),

          const SizedBox(height: 30),

          _purpleButton(
            context,
            icon: Icons.add_circle_outline,
            text: "Crear nueva reserva",
            route: "/new_reservation",
          ),

          const SizedBox(height: 16),

          _purpleButton(
            context,
            icon: Icons.calendar_month_rounded,
            text: "Ver calendario",
            route: "/calendar",
          ),

          const SizedBox(height: 30),
          const Text(
            "Reservas recientes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          SizedBox(
            height: 220,
            child: _RecentReservationsList(user),
          ),
        ],
      ),
    );
  }

  Widget _purpleButton(BuildContext context,
      {required IconData icon, required String text, required String route}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6A5AE0),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 26),
      label: Text(text, style: const TextStyle(fontSize: 18)),
      onPressed: () => Navigator.pushNamed(context, route),
    );
  }
}

// ----------------------------------------------------------
// 📅 RESERVAS RECIENTES
// ----------------------------------------------------------
class _RecentReservationsList extends StatelessWidget {
  final User? user;
  const _RecentReservationsList(this.user);

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox();

    final query = FirebaseFirestore.instance
        .collection("reservations")
        .where("userId", isEqualTo: user!.uid)
        .orderBy("start", descending: true)
        .limit(3);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("No tienes reservas recientes"));
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final room = data["roomId"];
            final status = data["status"];
            final date = (data["start"] as Timestamp).toDate();

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEDE7FF),
                  child: Icon(Icons.meeting_room, color: Color(0xFF6A5AE0)),
                ),
                title: Text("Salón $room",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  "${date.day}/${date.month}/${date.year} — $status",
                  style: const TextStyle(color: Colors.black54),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/reservation_detail",
                    arguments: docs[i].id,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ----------------------------------------------------------
// 📄 MIS RESERVAS
// ----------------------------------------------------------
class _MyReservationsPage extends StatelessWidget {
  final User? user;
  const _MyReservationsPage(this.user);

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox();

    final query = FirebaseFirestore.instance
        .collection("reservations")
        .where("userId", isEqualTo: user!.uid)
        .orderBy("start", descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(child: Text("No tienes reservas"));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final room = data["roomId"];
            final status = data["status"];
            final date = (data["start"] as Timestamp).toDate();

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEDE7FF),
                  child: Icon(Icons.meeting_room, color: Color(0xFF6A5AE0)),
                ),
                title: Text(
                  "Salón $room",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${date.day}/${date.month}/${date.year} — $status",
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/reservation_detail",
                    arguments: docs[i].id,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ----------------------------------------------------------
// 👤 PERFIL
// ----------------------------------------------------------
class _ProfilePage extends StatelessWidget {
  final User? user;
  const _ProfilePage(this.user);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .get(),
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data["name"] ?? "Cliente";
        final email = user?.email ?? "Sin email";

        return Container(
          color: const Color(0xFFF6F2FF),
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              const SizedBox(height: 10),

              // -------------------------------------------
              // TARJETA SUPERIOR (FOTO + NOMBRE + ROL)
              // -------------------------------------------
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFFEDE7FF),
                      child: Icon(
                        Icons.person_rounded,
                        size: 40,
                        color: const Color(0xFF6A5AE0),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A3A3A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // -------------------------------------------
              // TITULO DE SECCION
              // -------------------------------------------
              const Text(
                "Configuración",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A3A3A),
                ),
              ),
              const SizedBox(height: 16),

              // -------------------------------------------
              // OPCIONES
              // -------------------------------------------

              _optionTile(
                icon: Icons.lock_reset_rounded,
                title: "Cambiar contraseña",
                onTap: () {
                  final email = user?.email ?? "";
                  FirebaseAuth.instance
                      .sendPasswordResetEmail(email: email);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Correo enviado para restablecer contraseña."),
                    ),
                  );
                },
              ),

              _optionTile(
                icon: Icons.help_outline_rounded,
                title: "Soporte técnico",
                subtitle: "resersala.soporte@gmail.com",
                onTap: () {},
              ),

              const SizedBox(height: 35),

              // -------------------------------------------
              // BOTÓN DE CERRAR SESIÓN — ESTILO BONITO
              // -------------------------------------------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                      context, "/login", (_) => false);
                  },
                  icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  label: const Text(
                    "Cerrar sesión",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------
  // WIDGET REUTILIZABLE PARA OPCIONES
  // -------------------------------------------
  Widget _optionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFEDE7FF),
        child: Icon(icon, color: Color(0xFF6A5AE0)),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle:
          subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 13)) : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
