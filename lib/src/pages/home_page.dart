import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';

import '../../main.dart';
import 'widgets/clock.dart';
import '../utils/firestore.dart';
import '../utils/notification_utils.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
    );
  }
}

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  tz.TZDateTime _dateTime = tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'));

  static Future<void> callback(dateTime, docId, notificationId, remarks) async {
    await singleNotification(
      flutterLocalNotificationsPlugin,
      dateTime,
      "Alarm Clock",
      remarks,
      notificationId,
      docId,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void _update(tz.TZDateTime time) {
      setState(() {
        _dateTime = time;
      });
    }

    final String formattedTime =
        DateFormat('kk:mm').format(_dateTime).toString();

    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Spacer(),
            Clock(
              update: _update,
              dateTime: tz.TZDateTime.now(tz.getLocation('Asia/Jakarta')),
            ),
            const Spacer(),
            Text(
              formattedTime,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 36,
                color: NeumorphicTheme.defaultTextColor(context),
              ),
            ),
            Text(
              "Jakarta, Indonesia",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: NeumorphicTheme.variantColor(context),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 300,
              child: Row(
                children: [
                  NeumorphicButton(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 24,
                    ),
                    style: NeumorphicStyle(
                      intensity: 0.86,
                      depth: 5,
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "+ Add Alarm",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: NeumorphicTheme.defaultTextColor(context),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      int notificationId = Random().nextInt(1000);

                      final alarmName = await showTextInputDialog(
                        context: context,
                        title: 'Alarm Name',
                        message: 'Please input alarm name',
                        textFields: [
                          DialogTextField(
                            hintText: 'Coffee break',
                            validator: (value) => value!.isEmpty
                                ? 'Input more than one character'
                                : null,
                          ),
                        ],
                      );
                      if (alarmName!.isNotEmpty) {
                        var docId = await Storage.addAlarm({
                          'notificationId': notificationId,
                          'time': _dateTime,
                          'title': alarmName.first,
                        });
                        callback(
                          _dateTime,
                          docId,
                          notificationId,
                          alarmName.first,
                        );
                        Fluttertoast.showToast(msg: "Alarm added!");
                      } else {
                        var docId = await Storage.addAlarm({
                          'notificationId': notificationId,
                          'time': _dateTime,
                          'title': 'Untitled alarm',
                        });
                        callback(
                          _dateTime,
                          docId,
                          notificationId,
                          alarmName.first,
                        );
                        Fluttertoast.showToast(msg: "Alarm added!");
                      }
                    },
                  ),
                  const Spacer(),
                  NeumorphicButton(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 24,
                    ),
                    style: NeumorphicStyle(
                      intensity: 0.86,
                      depth: 5,
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.circular(12),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Active Alarm",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: NeumorphicTheme.defaultTextColor(context),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/alarmlist');
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
