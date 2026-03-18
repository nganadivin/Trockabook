import 'package:flutter/material.dart';

/// A tiny helper class to display toast-like messages using a styled
/// `SnackBar`.  It is used throughout the app whenever the user needs a
/// quick feedback (error, success, warning etc.).
///
/// The snackbar floats, has a rounded shape and disappears automatically
/// after a short duration (default 4 seconds) so it behaves like a
/// notification box.
class AppSnackbar {
  /// Show a message using the scaffold messenger.
  ///
  /// - [error] switches the background colour (red for errors, green for
  ///   success by default).  You can pass a custom colour using
  ///   [backgroundColor].
  /// - [duration] controls how long the bar stays visible before
  ///   disappearing.  The default is four seconds as requested by the
  ///   user.
  static void show(
    BuildContext context,
    String message, {
    bool error = true,
    Duration duration = const Duration(seconds: 4),
    Color? backgroundColor,
  }) {
    final snack = SnackBar(
      content: Text(message),
      backgroundColor:
          backgroundColor ?? (error ? Colors.redAccent : Colors.green),
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snack);
  }
}
