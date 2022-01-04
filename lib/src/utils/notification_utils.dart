import '../models/received_notification.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../main.dart';

String currentTimezone = 'Unknown';

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

initializeNotifications() async {
  var initialiseAndroid =
      const AndroidInitializationSettings('@mipmap/launcher_icon');
  final IOSInitializationSettings initialiseIOS = IOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification: (
      int? id,
      String? title,
      String? body,
      String? payload,
    ) {
      didReceiveLocalNotificationSubject.add(
        ReceivedNotification(
          id: id!,
          title: title!,
          body: body!,
          payload: payload!,
        ),
      );
    },
  );
  var initSettings = InitializationSettings(
    android: initialiseAndroid,
    iOS: initialiseIOS,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onSelectNotification: onSelectNotification,
  );

  currentTimezone = await FlutterNativeTimezone.getLocalTimezone();
}

Future singleNotification(
  FlutterLocalNotificationsPlugin localNotificationsPlugin,
  tz.TZDateTime dateTime,
  String title,
  String subtext,
  int hashcode,
  String docId, {
  String? sound,
}) async {
  var androidChannel = const AndroidNotificationDetails(
    'channel-id',
    'Alarm Clock',
    channelDescription: 'To send an alarm notification',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  var platformChannel = NotificationDetails(android: androidChannel);
  localNotificationsPlugin.zonedSchedule(
    hashcode,
    title,
    subtext,
    dateTime,
    platformChannel,
    payload: docId,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}

Future<void> cancelAlarm(int id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}

void requestPermissions() {
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}
