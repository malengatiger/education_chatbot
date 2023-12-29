import 'dart:async';

import 'package:flutter/material.dart';

import '../util/functions.dart';

class BusyIndicator extends StatefulWidget {
  final String? caption;
  final Color? color;
  final double? elevation;
  final bool? showElapsedTime;

  const BusyIndicator(
      {super.key,
      this.caption,
      this.color = Colors.blue,
      this.elevation = 8.0,
      this.showElapsedTime = true});

  @override
  State<BusyIndicator> createState() => _BusyIndicatorState();
}

class _BusyIndicatorState extends State<BusyIndicator> {
  String elapsedTime = '';

  @override
  void initState() {
    super.initState();
    _runTimer();
  }

  late Timer timer;

  void _runTimer() {
    int milliseconds = 0;
    timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      milliseconds += 1000;
      int seconds = (milliseconds / 1000).truncate();
      int minutes = (seconds / 60).truncate();
      seconds %= 60;

      String minutesStr = minutes.toString().padLeft(2, '0');
      String secondsStr = seconds.toString().padLeft(2, '0');

      setState(() {
        elapsedTime = '$minutesStr:$secondsStr';
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.elevation,
      child: Center(
        child: SizedBox(
          height: 160,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.red,
                    strokeWidth: 6.0,
                  ),
                ),
                gapH8,
                widget.caption == null
                    ? gapW8
                    : Text(widget.caption!, style: myTextStyleSmall(context)),
                gapH8,
                Row(
                  children: [
                    const Text('Elapsed Time: '),
                    gapW16,
                    Text(elapsedTime,
                        style: myTextStyle(
                            context, Colors.pink, 18, FontWeight.bold)),
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
