import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingDialog {
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissal by tapping outside the dialog
      builder: (BuildContext context) {
        return LoadingIndicator(
            indicatorType: Indicator.ballPulse,

            /// Required, The loading type of the widget
            colors: const [Colors.white, Colors.yellowAccent],

            /// Optional, The color collections
            strokeWidth: 2,

            /// Optional, The stroke of the line, only applicable to widget which contains line
            backgroundColor: Colors.black,

            /// Optional, Background of the widget
            pathBackgroundColor: Colors.black

            /// Optional, the stroke backgroundColor
            );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop(); // Close the dialog
  }
}
