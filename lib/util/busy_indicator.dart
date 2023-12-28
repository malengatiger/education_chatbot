import 'package:flutter/material.dart';

import 'functions.dart';

class BusyIndicator extends StatelessWidget {
  final String? caption;
  final Color? color;
  final double?  elevation;

  const BusyIndicator({
    super.key,
    this.caption,
    this.color = Colors.blue,
    this.elevation = 8.0
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      child: Center(
        child: SizedBox(height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(
                   backgroundColor: Colors.red,
                    strokeWidth: 6.0,
                  ),
                ),
                gapH8,
                caption == null
                    ? gapW8
                    : Text(
                        caption!,
                        style: myTextStyleSmall(context)
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
