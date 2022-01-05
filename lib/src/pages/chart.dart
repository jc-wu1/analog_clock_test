import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ReportWidget extends StatefulWidget {
  final List<DocumentSnapshot> document;
  final List<Color> availableColors = const [
    Colors.purpleAccent,
    Colors.yellow,
    Colors.lightBlue,
    Colors.orange,
    Colors.pink,
    Colors.redAccent,
  ];

  const ReportWidget({Key? key, required this.document}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ReportWidgetState();
}

class ReportWidgetState extends State<ReportWidget> {
  final Color barBackgroundColor = const Color(0xff72d8bf);
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.blueAccent,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  const Text(
                    'Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Time difference between alarm time and notification click',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  const SizedBox(
                    height: 38,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: BarChart(
                        mainBarData(),
                        swapAnimationDuration: animDuration,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          colors: isTouched ? [Colors.yellow] : [barColor],
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Colors.yellowAccent, width: 1)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 50,
            colors: [barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(
        widget.document.length,
        (i) {
          return makeGroupData(
            i,
            widget.document[i].get('timeDiff') + .0,
            isTouched: i == touchedIndex,
          );
        },
      );

  // List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
  //       switch (i) {
  //         case 0:
  //           return makeGroupData(i, 5, isTouched: i == touchedIndex);
  //         case 1:
  //           return makeGroupData(i, 6.5, isTouched: i == touchedIndex);
  //         case 2:
  //           return makeGroupData(i, 5, isTouched: i == touchedIndex);
  //         case 3:
  //           return makeGroupData(i, 7.5, isTouched: i == touchedIndex);
  //         case 4:
  //           return makeGroupData(i, 9, isTouched: i == touchedIndex);
  //         case 5:
  //           return makeGroupData(i, 11.5, isTouched: i == touchedIndex);
  //         case 6:
  //           return makeGroupData(i, 6.5, isTouched: i == touchedIndex);
  //         default:
  //           return throw Error();
  //       }
  //     });

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                "Time difference (in second)\n",
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.y - 1).toString(),
                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return DateFormat('kk:mm')
                    .format(widget.document[0].get('time').toDate())
                    .toString();
              case 1:
                return DateFormat('kk:mm')
                    .format(widget.document[1].get('time').toDate())
                    .toString();
              case 2:
                return DateFormat('kk:mm')
                    .format(widget.document[2].get('time').toDate())
                    .toString();
              case 3:
                return DateFormat('kk:mm')
                    .format(widget.document[3].get('time').toDate())
                    .toString();
              case 4:
                return DateFormat('kk:mm')
                    .format(widget.document[4].get('time').toDate())
                    .toString();
              case 5:
                return DateFormat('kk:mm')
                    .format(widget.document[5].get('time').toDate())
                    .toString();
              case 6:
                return DateFormat('kk:mm')
                    .format(widget.document[6].get('time').toDate())
                    .toString();
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(show: false),
    );
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
        animDuration + const Duration(milliseconds: 50));
    if (isPlaying) {
      await refreshState();
    }
  }
}
