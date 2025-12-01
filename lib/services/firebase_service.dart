import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Instancias de Firebase
   FirebaseAuth get auth => FirebaseAuth.instance;
   FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Inicializar Firebase
  Future<void> initialize() async {
     await Firebase.initializeApp();
    print('Firebase Service initialized (mock mode)');
  }

  // Verificar conexión
  bool isInitialized() {
     return Firebase.apps.isNotEmpty;
    return true; // Mock
  }
}
