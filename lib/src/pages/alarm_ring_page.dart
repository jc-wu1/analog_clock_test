import 'package:analog_clock_test/src/pages/chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

class AlarmRingPage extends StatefulWidget {
  const AlarmRingPage({Key? key, this.payload}) : super(key: key);

  final String? payload;

  @override
  _AlarmRingPageState createState() => _AlarmRingPageState();
}

class _AlarmRingPageState extends State<AlarmRingPage> {
  final player = AudioCache();
  AudioPlayer? advancedPlayer;
  String? _title, _timeString;
  int? _timeDifference;

  void initializeDetails() async {
    await Storage.getAlarmDetails(widget.payload!).then((document) {
      DateTime fromFirebase = document.get('time').toDate();
      setState(() {
        _title = document.get('title');
        _timeString = DateFormat('kk:mm:ss').format(fromFirebase).toString();
        _timeDifference = DateTime.now().difference(fromFirebase).inSeconds;
      });
      Storage.updateAlarm(document.id, {'timeDiff': _timeDifference});
    });
    startAudioAndVibrate();
  }

  void startAudioAndVibrate() async {
    await Vibration.vibrate(duration: 10000);
    // https://samplefocus.com/collections/smooth-mixed-melodies
    await player.load('notification_sound.wav');
    advancedPlayer = await player.loop('notification_sound.wav');
  }

  void stopAudioAndVibration() async {
    await Vibration.cancel();
    await advancedPlayer!.stop();
    player.clearAll();
  }

  @override
  void initState() {
    super.initState();
    initializeDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder(
                  stream: Storage.getStream(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasData) {
                      return snapshot.data!.docs.isEmpty
                          ? const Center(
                              child: Text('No Data'),
                            )
                          : BarChartSample1(
                              document: snapshot.data!.docs,
                            );
                    } else if (snapshot.hasError) {
                      return const Text('Error');
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                const SizedBox(
                  height: 70,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromRGBO(92, 184, 92, 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    stopAudioAndVibration();
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
