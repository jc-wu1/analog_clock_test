import 'dart:async';
import 'dart:math';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:timezone/timezone.dart' as tz;

class Clock extends StatefulWidget {
  const Clock({
    Key? key,
    required this.update,
    required this.dateTime,
  }) : super(key: key);
  final ValueChanged<tz.TZDateTime> update;
  final tz.TZDateTime dateTime;

  @override
  _ClockState createState() => _ClockState(dateTime);
}

class _ClockState extends State<Clock> {
  tz.TZDateTime _dateTime;
  final tz.TZDateTime _initialDateTime;
  late Timer _timer;
  Duration duration = const Duration(seconds: 1);

  _ClockState(_dateTime)
      : _dateTime =
            _dateTime ?? tz.TZDateTime.now(tz.getLocation('Asia/Jakarta')),
        _initialDateTime =
            _dateTime ?? tz.TZDateTime.now(tz.getLocation('Asia/Jakarta'));

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(duration, update);
  }

  update(Timer timer) {
    if (mounted) {
      _dateTime = _initialDateTime.add(duration * timer.tick);
      setState(() {});
      widget.update(_dateTime);
    }
  }

  void startTimer() {
    _timer = Timer.periodic(duration, update);
  }

  void _stopTimer() {
    _timer.cancel();
  }

  void _increaseMinute() {
    setState(() {
      _dateTime = _dateTime.add(const Duration(minutes: 1));
    });
    widget.update(_dateTime);
  }

  void _decreaseMinute() {
    setState(() {
      _dateTime = _dateTime.subtract(const Duration(minutes: 1));
    });
    widget.update(_dateTime);
  }

  void _increaseHour() {
    setState(() {
      _dateTime = _dateTime.add(const Duration(hours: 1));
    });
    widget.update(_dateTime);
  }

  void _decreaseHour() {
    setState(() {
      _dateTime = _dateTime.subtract(const Duration(hours: 1));
    });
    widget.update(_dateTime);
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
          //swipe right
          _increaseMinute();
        }
        if (details.delta.dx < -sensitivity) {
          //swipe left
          _decreaseMinute();
        }
      },
      onVerticalDragUpdate: (details) {
        int sensitivity = 1;
        if (details.delta.dy > sensitivity) {
          // swipe down
          _decreaseHour();
        }
        if (details.delta.dy < -sensitivity) {
          // swipe up
          _increaseHour();
        }
      },
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AspectRatio(
              aspectRatio: 1,
              child: Neumorphic(
                margin: const EdgeInsets.all(14),
                style: const NeumorphicStyle(
                  boxShape: NeumorphicBoxShape.circle(),
                ),
                child: Neumorphic(
                  style: const NeumorphicStyle(
                    depth: 14,
                    boxShape: NeumorphicBoxShape.circle(),
                  ),
                  margin: const EdgeInsets.all(20),
                  child: Neumorphic(
                    style: const NeumorphicStyle(
                      depth: -8,
                      boxShape: NeumorphicBoxShape.circle(),
                    ),
                    margin: const EdgeInsets.all(10),
                    child: Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: [
                        Neumorphic(
                          style: const NeumorphicStyle(
                            depth: -2,
                            boxShape: NeumorphicBoxShape.circle(),
                          ),
                          margin: const EdgeInsets.all(65),
                        ),
                        Transform.rotate(
                          angle: -pi / 2,
                          child: CustomPaint(
                            painter: ClockPainter(context, _dateTime),
                          ),
                        ),
                      ],
                    ),
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

  ClockPainter(this.context, this.dateTime);
  @override
  void paint(Canvas canvas, Size size) {
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
        ..color = Colors.grey.shade300
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
        ..color = Colors.grey[350] as Color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );

    double secondX =
        centerX + size.width * 0.4 * cos((dateTime.second * 6) * pi / 180);
    double secondY =
        centerY + size.width * 0.4 * sin((dateTime.second * 6) * pi / 180);

    canvas.drawLine(
      center,
      Offset(secondX, secondY),
      Paint()..color = Colors.grey,
    );

    Paint dotPainter = Paint()..color = Colors.grey[350] as Color;
    canvas.drawCircle(center, 5, dotPainter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
