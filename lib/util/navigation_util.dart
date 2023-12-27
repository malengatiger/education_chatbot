import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class NavigationUtils {
  static void navigateToPage({
    required BuildContext context,
    required Widget widget,
    PageTransitionType transitionType = PageTransitionType.fade,
    Duration transitionDuration = const Duration(milliseconds: 300)
  }) {
    Navigator.push(
      context,
      PageTransition(
        type: transitionType,
        duration: transitionDuration,
        child: widget,
      ),
    );
  }
}
