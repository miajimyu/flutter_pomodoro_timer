import 'package:flutter/material.dart';

import 'pomodoro_timer_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String title = 'Flutter Pomodoro Timer';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
        ),
        body: PomodoroTimerPage(),
      ),
    );
  }
}
