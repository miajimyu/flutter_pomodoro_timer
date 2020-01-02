import 'dart:async';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

const Duration workTime = Duration(minutes: 25);
const Duration shortBreakTime = Duration(minutes: 5);
const Duration longBreakTime = Duration(minutes: 15);
const int longBreakAfter = 3;
const int targetInterval = 6;

enum Status {
  work,
  shortBreak,
  longBreak,
}

class Pomodoro {
  Pomodoro({
    this.targetTime,
    this.status,
    this.count,
  });

  Duration targetTime;
  Status status;
  int count;

  void setParam({Duration time, Status status}) {
    targetTime = time;
    status = status;
  }
}

class PomodoroTimerPage extends StatefulWidget {
  @override
  _PomodoroTimerPageState createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  Stopwatch _sw;
  Timer _timer;
  Duration _timeLeft = const Duration();

  final Pomodoro _pomodoro = Pomodoro(
    targetTime: workTime,
    status: Status.work,
    count: 0,
  );

  @override
  void initState() {
    _pomodoro.targetTime = workTime;
    _sw = Stopwatch();
    _timer = Timer.periodic(const Duration(milliseconds: 50), _callback);
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  void _callback(Timer timer) {
    if (_sw.elapsed > _pomodoro.targetTime) {
      setState(() {
        _changeNextStatus();
      });
      return;
    }

    final Duration _newTimeLeft = _pomodoro.targetTime - _sw.elapsed;
    if (_newTimeLeft.inSeconds != _timeLeft.inSeconds) {
      setState(() {
        _timeLeft = _newTimeLeft;
      });
    }
  }

  void _changeNextStatus() {
    _sw.stop();
    _sw.reset();
    if (_pomodoro.status == Status.work) {
      _pomodoro.count++;
      if (_pomodoro.count % longBreakAfter == 0) {
        _pomodoro.setParam(time: longBreakTime, status: Status.longBreak);
      } else {
        _pomodoro.setParam(time: shortBreakTime, status: Status.shortBreak);
      }
    } else {
      _pomodoro.setParam(time: workTime, status: Status.work);
    }
  }

  void _resetButtonPressed() {
    if (!_sw.isRunning) {
      setState(() {
        _sw.reset();
      });
    }
  }

  void _buttonPressed() {
    setState(() {
      if (_sw.isRunning) {
        _sw.stop();
      } else {
        _sw.start();
      }
    });
  }

  Widget displayTimeString() {
    final String minutes =
        (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    final String seconds =
        (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');
    return Text('$minutes:$seconds', style: const TextStyle(fontSize: 90.0));
  }

  Widget displayPomodoroStatus() {
    String text;
    if (_pomodoro.status == Status.work) {
      text = 'Work';
    } else if (_pomodoro.status == Status.shortBreak) {
      text = 'Short Break';
    } else {
      text = 'Long Break';
    }
    return Text(text, style: const TextStyle(fontSize: 30.0));
  }

  Color _getColor() {
    if (_pomodoro.status == Status.work) {
      return Colors.blue;
    } else if (_pomodoro.status == Status.shortBreak) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        displayPomodoroStatus(),
        CircularPercentIndicator(
          radius: 300.0,
          lineWidth: 10.0,
          percent: _timeLeft.inSeconds / _pomodoro.targetTime.inSeconds,
          center: displayTimeString(),
          progressColor: _getColor(),
        ),
        Text(
          '${_pomodoro.count.toString()}/$targetInterval',
          style: const TextStyle(fontSize: 40.0),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Ink(
              decoration: ShapeDecoration(
                color: _getColor(),
                shape: const CircleBorder(),
              ),
              child: IconButton(
                icon: Icon(_sw.isRunning ? null : Icons.refresh),
                color: Colors.white,
                iconSize: 72,
                onPressed: () => _resetButtonPressed(),
              ),
            ),
            Ink(
              decoration: ShapeDecoration(
                color: _getColor(),
                shape: const CircleBorder(),
              ),
              child: IconButton(
                icon: Icon(_sw.isRunning ? Icons.pause : Icons.play_arrow),
                color: Colors.white,
                iconSize: 72,
                onPressed: () => _buttonPressed(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
