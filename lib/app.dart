import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:math';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Analog Alarm'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Body(),
    );
  }
}

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final DateTime _dateTime = DateTime.now();
  DateTime _session = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void _update(DateTime time) {
      setState(() {
        _session = time;
      });
    }

    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Spacer(),
            Clock(
              update: _update,
            ),
            const Spacer(),
            CountryCard(
              country: "Jakarta, Indonesia",
              timeZone: "GMT +7",
              time: _dateTime,
            ),
            Text("${_session.hour} : ${_session.minute}"),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class Clock extends StatefulWidget {
  const Clock({Key? key, required this.update}) : super(key: key);
  final ValueChanged<DateTime> update;

  @override
  _ClockState createState() => _ClockState();
}

class _ClockState extends State<Clock> {
  DateTime _dateTime = DateTime.now();
  DateTime _newTime = DateTime.now();
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _dateTime = DateTime.now();
      });
    });
  }

  void _stopTimer() {
    timer.cancel();
  }

  void _increaseMinute() {
    setState(() {
      _dateTime = _dateTime.add(const Duration(minutes: 1));
      _newTime = _newTime.add(const Duration(minutes: 1));
      widget.update(_newTime);
    });
  }

  void _decreaseMinute() {
    setState(() {
      _dateTime = _dateTime.subtract(const Duration(minutes: 1));
      _newTime = _newTime.subtract(const Duration(minutes: 1));
      widget.update(_newTime);
    });
  }

  void _increaseHour() {
    setState(() {
      _dateTime = _dateTime.add(const Duration(hours: 1));
      _newTime = _newTime.add(const Duration(hours: 1));
      widget.update(_newTime);
    });
  }

  void _decreaseHour() {
    setState(() {
      _dateTime = _dateTime.subtract(const Duration(hours: 1));
      _newTime = _newTime.subtract(const Duration(hours: 1));
      widget.update(_newTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        _stopTimer();
      },
      onVerticalDragStart: (details) {
        _stopTimer();
      },
      onHorizontalDragUpdate: (details) {
        int sensitivity = 1;
        if (details.delta.dx > sensitivity) {
          _increaseMinute();
        }
        if (details.delta.dx < -sensitivity) {
          _decreaseMinute();
        }
      },
      onVerticalDragUpdate: (details) {
        int sensitivity = 1;
        if (details.delta.dy > sensitivity) {
          // Down Swipe
          _decreaseHour();
        }
        if (details.delta.dy < -sensitivity) {
          // Up Swipe
          _increaseHour();
        }
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 0),
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 64,
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: -pi / 2,
                  child: CustomPaint(
                    painter: ClockPainter(context, _dateTime),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final BuildContext context;
  final DateTime dateTime;

  // void _drawIndicators(Canvas canvas, Size size, double scaleFactor) {

  // }

  ClockPainter(this.context, this.dateTime);
  @override
  void paint(Canvas canvas, Size size) {
    // _drawIndicators(canvas, size, 1000);
    double scaleFactor = size.shortestSide / 320.0;

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    Offset center = Offset(centerX, centerY);

    double minX =
        centerX + size.width * 0.35 * cos((dateTime.minute * 6) * pi / 180);
    double minY =
        centerY + size.width * 0.35 * sin((dateTime.minute * 6) * pi / 180);

    canvas.drawLine(
      center,
      Offset(minX, minY),
      Paint()
        ..color = Theme.of(context).colorScheme.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    double hourX = centerX +
        size.width *
            0.3 *
            cos((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);
    double hourY = centerY +
        size.width *
            0.3 *
            sin((dateTime.hour * 30 + dateTime.minute * 0.5) * pi / 180);

    canvas.drawLine(
      center,
      Offset(hourX, hourY),
      Paint()
        ..color = Theme.of(context).colorScheme.secondary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    double secondX =
        centerX + size.width * 0.4 * cos((dateTime.second * 6) * pi / 180);
    double secondY =
        centerY + size.width * 0.4 * sin((dateTime.second * 6) * pi / 180);

    canvas.drawLine(center, Offset(secondX, secondY),
        Paint()..color = Theme.of(context).primaryColor);

    Paint dotPainter = Paint()..color = Colors.blue;
    canvas.drawCircle(center, 24, dotPainter);
    canvas.drawCircle(
        center, 23, Paint()..color = Theme.of(context).backgroundColor);
    canvas.drawCircle(center, 10, dotPainter);

//text
    TextStyle style = const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    );
    // double p = 4.0;
    // p += 24.0;
    Offset paddingX = Offset(28 * scaleFactor, 0.0);
    Offset paddingY = Offset(0.0, 28 * scaleFactor);

    TextSpan span9 = TextSpan(style: style, text: "9");
    TextPainter tp9 = TextPainter(
      text: span9,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp9.layout();
    tp9.paint(canvas, size.topCenter(-tp9.size.topCenter(-paddingY)));

    TextSpan span3 = TextSpan(style: style, text: "3");
    TextPainter tp3 = TextPainter(
      text: span3,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp3.layout();
    tp3.paint(canvas, size.bottomCenter(-tp3.size.bottomCenter(paddingY)));

    TextSpan span12 = TextSpan(style: style, text: "12");
    TextPainter tp12 = TextPainter(
        text: span12,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp12.layout();
    tp12.paint(canvas, size.centerRight(-tp12.size.centerRight(paddingX)));

    TextSpan span6 = TextSpan(style: style, text: "6");
    TextPainter tp6 = TextPainter(
        text: span6,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp6.layout();
    tp6.paint(canvas, size.centerLeft(-tp6.size.centerLeft(-paddingX)));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class CountryCard extends StatelessWidget {
  const CountryCard({
    Key? key,
    required this.country,
    required this.timeZone,
    required this.time,
  }) : super(key: key);

  final String country, timeZone;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: SizedBox(
        width: 233,
        child: AspectRatio(
          aspectRatio: 1.32,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country,
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(timeZone),
                const Spacer(),
                Row(
                  children: [
                    const Spacer(),
                    Text(
                      "${time.hour} : ${time.minute}",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
