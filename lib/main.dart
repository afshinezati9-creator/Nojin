import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/di/service_container.dart';
import 'core/logging/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error(
      'Flutter framework error',
      details.exception,
      details.stack,
    );
  };

  final container = ServiceContainer.create();
  runZonedGuarded(
    () => runApp(
      ProviderScope(
        overrides: [
          serviceContainerProvider.overrideWithValue(container),
        ],
        child: const NojinApp(),
      ),
    ),
    (error, stack) => AppLogger.error(
      'Unhandled application error',
      error,
      stack,
    ),
  );
}
