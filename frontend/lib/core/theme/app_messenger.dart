import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showAppSnack(String message) {
    final messenger = appScaffoldMessengerKey.currentState;
    if (messenger == null) return;
    messenger.showSnackBar(
        SnackBar(content: Text(message)),
    );
}
