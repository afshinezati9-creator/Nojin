import 'dart:developer' as developer;

class AppLogger {
  const AppLogger._();

  static final AppLogger instance = const AppLogger._();

  static void debug(String message, [Object? data]) {
    _write('DEBUG', message, data);
  }

  static void info(String message, [Object? data]) {
    _write('INFO', message, data);
  }

  static void warning(String message, [Object? data]) {
    _write('WARNING', message, data);
  }

  static void error(String message, [Object? error, StackTrace? stack]) {
    developer.log(
      message,
      name: 'NOJIN',
      level: 1000,
      error: error,
      stackTrace: stack,
    );
  }

  static void _write(String level, String message, Object? data) {
    developer.log(
      data == null ? '[$level] $message' : '[$level] $message | $data',
      name: 'NOJIN',
    );
  }
}
