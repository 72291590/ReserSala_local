import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'admin_navbar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 1;

  void _onTabTapped(int index) {
    if (index == _selectedIndex) return; // evita recargar misma pantalla

    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacementNamed(context, "/admin_reservations");
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, "/admin_dashboard");
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, "/rooms");
    } else if (index == 3) {
      Navigator.pushReplacementNamed(context, "/users");
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, "/admin_calendar");
    } else if (index == 5) {
      Navigator.pushReplacementNamed(context, "/admin_settings");
    } 
  }


  // ==========================================
  // 🔥 OBTENER TODAS LAS RESERVAS
  // ==========================================
  Future<List<QueryDocumentSnapshot>> getReservations() async {
    final snapshot =
        await FirebaseFirestore.instance.collection("reservations").get();
    return snapshot.docs;
  }

  // Contadores simples
  int countByStatus(List docs, String status) =>
      docs.where((d) => (d["status"] ?? "") == status).length;

  int countToday(List docs) {
    final today = DateTime.now();
    return docs.where((d) {
      final date = (d["start"] as Timestamp).toDate();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    }).length;
  }

  int countThisMonth(List docs) {
    final now = DateTime.now();
    return docs.where((d) {
      final date = (d["start"] as Timestamp).toDate();
      return date.year == now.year && date.month == now.month;
    }).length;
  }

  int countActiveNow(List docs) {
    final now = DateTime.now();
    return docs.where((d) {
      final start = (d["start"] as Timestamp).toDate();
      final end = (d["end"] as Timestamp).toDate();
      return now.isAfter(start) && now.isBefore(end);
    }).length;
  }

  // ==========================================
  // 📊 DATOS PARA EL GRÁFICO DE BARRAS (7 días)
  // ==========================================
  Map<String, int> getWeeklyChartData(List docs) {
    Map<String, int> results = {};
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = "${day.day}/${day.month}";
      results[key] = docs.where((d) {
        final date = (d["start"] as Timestamp).toDate();
        return date.year == day.year &&
            date.month == day.month &&
            date.day == day.day;
      }).length;
    }

    return results;
  }

  // ============================================================
  // 📌 WIDGET PRINCIPAL
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Administrativo"),
        centerTitle: true,
      ),

      bottomNavigationBar: AdminNavbar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),

      body: FutureBuilder(
        future: getReservations(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!;
          final weeklyData = getWeeklyChartData(docs);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ============================================================
              // ⭐ TARJETAS RESUMEN
              // ============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statCard("Hoy", countToday(docs), Colors.deepPurple),
                  _statCard("Este mes", countThisMonth(docs),
                      Colors.indigoAccent),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _statCard(
                      "Ocupados ahora", countActiveNow(docs), Colors.orange),
                  _statCard("Pendientes", countByStatus(docs, "Pendiente"),
                      Colors.redAccent),
                ],
              ),

              const SizedBox(height: 30),

              // ============================================================
              // 📊 GRÁFICO BARRAS — Últimos 7 días
              // ============================================================
              const Text(
                "Reservas por día (últimos 7 días)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    borderData: FlBorderData(show: false),

                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final keys = weeklyData.keys.toList();
                            if (value.toInt() >= keys.length) {
                              return const SizedBox();
                            }
                            return Text(
                              keys[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),

                    barGroups: List.generate(weeklyData.length, (index) {
                      final key = weeklyData.keys.toList()[index];
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: weeklyData[key]!.toDouble(),
                            color: Colors.deepPurple,
                            width: 18,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ============================================================
              // 🥧 GRÁFICO PIE — Estados
              // ============================================================
              const Text(
                "Porcentaje de estados",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 45,
                    sectionsSpace: 2,
                    sections: [
                      _pie("Pendientes", countByStatus(docs, "Pendiente"),
                          Colors.orange),
                      _pie("Aprobadas", countByStatus(docs, "Aprobado"),
                          Colors.green),
                      _pie("Rechazadas", countByStatus(docs, "Rechazado"),
                          Colors.red),
                      _pie("Finalizadas", countByStatus(docs, "completed"),
                          Colors.blue),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ============================================================
              // 📅 PRÓXIMAS RESERVAS DE HOY
              // ============================================================
              const Text(
                "Próximas reservas de hoy",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...docs.where((d) {
                final start = (d["start"] as Timestamp).toDate();
                final now = DateTime.now();
                return start.year == now.year &&
                    start.month == now.month &&
                    start.day == now.day;
              }).map((d) {
                final Map<String, dynamic> item = d.data() as Map<String, dynamic>; 
                final DateTime start = (item["start"] as Timestamp).toDate();

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.event),
                    title: Text("${item["roomId"]}"),
                    subtitle: Text(
                        "${start.hour}:00 • ${(item["status"] ?? "").toString().toUpperCase()}"),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // 🔹 TARJETA ESTADÍSTICAS
  // ============================================================
  Widget _statCard(String label, int value, Color color) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            "$value",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔹 PIE CHART SECTIONS
  // ============================================================
  PieChartSectionData _pie(String label, int value, Color color) {
    if (value == 0) {
      return PieChartSectionData(
        showTitle: false,
        value: 0.01,
        color: color.withOpacity(0.05),
      );
    }

    return PieChartSectionData(
      value: value.toDouble(),
      color: color,
      radius: 70,
      title: "$label\n$value",
      titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
    );
  }
}
