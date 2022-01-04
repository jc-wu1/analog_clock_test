import 'dart:math';

import 'package:analog_clock_test/src/utils/firestore.dart';
import 'package:analog_clock_test/src/utils/notification_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:intl/intl.dart';

class AlarmListPage extends StatefulWidget {
  const AlarmListPage({Key? key}) : super(key: key);

  @override
  _AlarmListPageState createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<AlarmListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Alarm List', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white10,
        elevation: 0,
        centerTitle: true,
      ),
      body: const Center(
        child: AlarmListBody(),
      ),
    );
  }
}

class AlarmListBody extends StatefulWidget {
  const AlarmListBody({Key? key}) : super(key: key);

  @override
  _AlarmListBodyState createState() => _AlarmListBodyState();
}

class _AlarmListBodyState extends State<AlarmListBody> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: StreamBuilder(
        stream: Storage.getStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return snapshot.data!.docs.isEmpty
                ? const Center(
                    child: Text('No alarm'),
                  )
                : ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot item = snapshot.data!.docs[index];
                      return AlarmList(document: item);
                    },
                  );
          } else if (snapshot.hasError) {
            return const Text('Error');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class AlarmList extends StatefulWidget {
  final DocumentSnapshot document;
  const AlarmList({Key? key, required this.document}) : super(key: key);

  @override
  _AlarmListState createState() => _AlarmListState();
}

class _AlarmListState extends State<AlarmList> {
  @override
  Widget build(BuildContext context) {
    var document = widget.document;
    bool isAfterSix = document.get('time').toDate().hour > 17;
    // bool isActive = document.get('active');
    int notifId = document.get('notificationId');

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: ListTile(
        leading: isAfterSix
            ? Transform.rotate(
                angle: 180 * pi / 180,
                child: const Icon(
                  Icons.brightness_2_outlined,
                  size: 22,
                  color: Color(0xffA771DE),
                ),
              )
            : const Icon(
                Icons.brightness_low_outlined,
                size: 22,
                color: Color(0xffFB81D1),
              ),
        title: Text(
          DateFormat('kk:mm').format(document.get('time').toDate()).toString(),
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300),
        ),
        subtitle: Text(
          document.get('title'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.delete_outline,
            size: 24,
          ),
          color: Colors.red[700],
          highlightColor: Colors.amberAccent,
          onPressed: () {
            cancelAlarm(notifId);
            Storage.deleteAlarm(document.id);
          },
        ),
        onTap: () {},
      ),
    );
  }
}
