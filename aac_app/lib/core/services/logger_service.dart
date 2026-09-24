import 'dart:developer' as developer;

/// All caught exceptions funnel through here instead of `print` or being
/// shown in the UI. In a real release build this is also where you'd wire a
/// crash-reporting SDK — kept as a single seam so that's a one-file change.
class AppLogger {
  AppLogger._();

  static void error(String context, Object error, [StackTrace? stackTrace]) {
    developer.log(
      context,
      name: 'voicepath.error',
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
  }

  static void warning(String message) {
    developer.log(message, name: 'voicepath.warning', level: 900);
  }

  static void info(String message) {
    developer.log(message, name: 'voicepath.info', level: 800);
  }
}
