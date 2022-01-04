import 'package:analog_clock_test/src/pages/alarm_list_page.dart';

import 'pages/home_page.dart';
import 'pages/alarm_ring_page.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      title: 'Flutter Demo',
      theme: const NeumorphicThemeData(
        defaultTextColor: Color(0xFF303E57),
        accentColor: Color(0xFF7B79FC),
        variantColor: Colors.black38,
        baseColor: Color(0xFFF8F9FC),
        depth: 8,
        intensity: 0.5,
        lightSource: LightSource.topLeft,
      ),
      initialRoute: '/',
      routes: {
        '/ring': (context) => const AlarmRingPage(),
        '/alarmlist': (context) => const AlarmListPage(),
      },
      navigatorKey: navigatorKey,
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Analog Alarm'),
    );
  }
}
