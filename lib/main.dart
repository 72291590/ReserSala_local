import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// OneSignal
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:resersala/features/admin/add_room.dart';
import 'package:resersala/features/admin/admin_calendar_page.dart';
import 'package:resersala/features/admin/admin_dashboard.dart';
import 'package:resersala/features/admin/admin_settings.dart';
import 'package:resersala/features/admin/edit_room.dart';
import 'package:resersala/features/admin/rooms_list.dart';
import 'package:resersala/features/customer/customer_notificaciones.dart';
import 'package:resersala/features/admin/gestion_usuario.dart';
import 'package:resersala/features/tecnico/ajustes.dart';
import 'package:resersala/features/tecnico/calendario_tecnico.dart';
import 'package:resersala/features/tecnico/panel_usuarios.dart';
import 'package:resersala/features/tecnico/salones.dart';
import 'package:resersala/features/tecnico/ver_reservas.dart';

// Services
import 'core/services/auth_service.dart';

// ViewModels
import 'viewmodels/auth_viewmodel.dart';



// Screens
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/customer/customer_home_screen.dart';

import 'features/admin/commission_panel_screen.dart';

// Reservas
import 'features/customer/calendar_page.dart';
import 'features/customer/customer_nuevareserva.dart';
import 'features/customer/customer_reserva_detalle.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // -------------------------------
  // 🔥 INICIALIZAR ONE SIGNAL
  // -------------------------------
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  // TU APP ID DE ONESIGNAL
  OneSignal.initialize("4090aba0-2976-454d-b762-d8f0e5d6cee6");

  // pedir permisos de notificación
  OneSignal.Notifications.requestPermission(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),


     
      ],
      child: MaterialApp(
        title: 'FoodHubLocal',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.deepOrange),
        home: const LoginScreen(),

        routes: {
          // Auth
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),

          // Customer
          '/home_customer': (_) => const CustomerHomeScreen(),



          // Restaurante

          // Admin Home
          '/home_admin': (_) => const AdminAllReservationsScreen(),
          "/admin_dashboard": (_) => const AdminDashboard(),
          "/admin_reservations": (_) => const AdminAllReservationsScreen(),
          "/users": (_) => const UsersManagementPage(),
          "/admin_calendar": (_) => const AdminCalendarPage(),


          "/admin_settings": (_) => const AdminSettingsPage(),



          // Gestor

          // Reservas
          '/calendar': (_) => const CalendarPage(),
          '/new_reservation': (_) => const NewReservationPage(),
          '/reservation_detail': (_) => const ReservationDetailPage(),
          "/notifications": (context) => const NotificationsPage(),

          //Tecnico
          "/tech_reservations": (_) => const TechReservationsPage(),
          "/tech_users": (_) => const TechUsersPage(),
          "/tech_rooms": (_) => const TechRoomsPage(),
          "/tech_settings": (_) => const TechSettingsPage(),
          "/tech_calendar": (_) => const TechCalendarPage(),


          // DATA
           "/rooms": (context) => const RoomsListPage(),
            "/add_room": (context) => const AddRoomPage(),
            "/edit_room": (context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
              return EditRoomPage(id: args["id"], room: args["data"]);
            },

        },
      ),
    );
  }
}
