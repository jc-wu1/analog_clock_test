import 'src/app.dart';
import 'src/pages/alarm_ring_page.dart';
import 'src/utils/notification_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

onSelectNotification(String? payload) async {
  await Navigator.push(
    MyApp.navigatorKey.currentState!.context,
    MaterialPageRoute<void>(
      builder: (BuildContext context) => AlarmRingPage(payload: payload!),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeNotifications();
  tz.initializeTimeZones();
  runApp(const MyApp());
}
