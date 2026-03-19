import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prm_smart_task/app/app.dart';

void main() {
  runApp(
    const ProviderScope(
      child: SmartTaskApp(),
    ),
  );
}
