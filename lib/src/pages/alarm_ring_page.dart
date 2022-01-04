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

  void initializeDetails() async {
    await Storage.getAlarmDetails(widget.payload!).then((document) {
      setState(() {
        _title = document.get('title');
        _timeString = DateFormat('kk:mm:ss')
            .format(document.get('time').toDate())
            .toString();
      });
    });
    startAudioAndVibrate();
  }

  void startAudioAndVibrate() async {
    await Vibration.vibrate(duration: 10000);
    await player.load('sound1.wav');
    advancedPlayer = await player.loop('sound1.wav');
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
      backgroundColor: const Color(0xffddd3ee),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  " $_timeString ",
                  style: const TextStyle(
                    fontSize: 30,
                  ),
                ),
                Text(
                  " $_title ",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
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
                    'Submit',
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
