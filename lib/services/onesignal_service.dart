import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class OneSignalService {
  // 🔥 RELLENA ESTOS DOS DATOS
  static const String appId = "4090aba0-2976-454d-b762-d8f0e5d6cee6";
  static const String restApiKey = "os_v2_app_icikxibjozcu3n3c3dyolvwo42fn3cwkz7beh5n3m6ks5aupmgjtyau5pl6bx5njo7k5gmxcjdrsab4npg7me5od4ge2ma63aidzrdi";

  // ============================================================
  // 🔥 ENVIAR NOTIFICACIÓN A UN USUARIO
  // ============================================================
  static Future<void> sendNotification({
    required String playerId,
    required String title,
    required String message,
  }) async {
    final url = Uri.parse("https://api.onesignal.com/notifications");

    final body = {
      "app_id": appId,
      "include_player_ids": [playerId],
      "headings": {"en": title},
      "contents": {"en": message},
    };

    final headers = {
      "Content-Type": "application/json; charset=utf-8",
      "Authorization": "Basic $restApiKey"
    };

    await http.post(url, headers: headers, body: jsonEncode(body));
  }

  // ============================================================
  // 🔥 GUARDAR NOTIFICACIÓN EN FIRESTORE
  // ============================================================
  static Future<void> saveNotificationFirestore({
    required String uid,
    required String title,
    required String message,
  }) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("notifications")
        .add({
      "title": title,
      "body": message,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }
}
