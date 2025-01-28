import 'dart:io';

enum LogLevel { debug, info, warning, error, none }

class Logger {
  static LogLevel _currentLevel = LogLevel.debug;
  static bool _isEnabled = true;

  // ANSI color codes for terminal output
  static const _colorReset = '\x1B[0m';
  static const _colorDebug = '\x1B[36m'; // Cyan
  static const _colorInfo = '\x1B[32m'; // Green
  static const _colorWarning = '\x1B[33m'; // Yellow
  static const _colorError = '\x1B[31m'; // Red

  /// Set the global log level
  static void setLevel(LogLevel level) {
    _currentLevel = level;
  }

  /// Enable or disable logging globally
  static void enableLogging(bool enable) {
    _isEnabled = enable;
  }

  /// Log a debug message
  static void debug(String message, {String? context}) {
    _log(LogLevel.debug, 'DEBUG', message, _colorDebug, context: context);
  }

  /// Log an info message
  static void info(String message, {String? context}) {
    _log(LogLevel.info, 'INFO', message, _colorInfo, context: context);
  }

  /// Log a warning message
  static void warning(String message, {String? context}) {
    _log(LogLevel.warning, 'WARNING', message, _colorWarning, context: context);
  }

  /// Log an error message
  static void error(String message, {Object? error, String? context}) {
    final errorDetails = error != null ? ' | Error: $error' : '';
    _log(LogLevel.error, 'ERROR', '$message$errorDetails', _colorError, context: context);
  }

  /// Internal method to log messages with automatic context
  static void _log(LogLevel level, String levelName, String message, String color, {String? context}) {
    if (!_isEnabled || _currentLevel.index > level.index) return;

    final timestamp = DateTime.now().toIso8601String();

    String context_ = context ?? "Unknown";  

    final formattedMessage = '[$timestamp] [$levelName] [$context_] $message\n\n';

    if (stdout.hasTerminal) {
      print('$color$formattedMessage$_colorReset');
    } else {
      print(formattedMessage); // Fallback for non-terminal environments
    }
  }

  
  
}

String getCallerContext() {
  final stackTrace = StackTrace.current.toString().split('\n');
  
  if (stackTrace.length > 2) {
    final frame = stackTrace[2]; // Get the caller frame
    final match = RegExp(r'#\d+\s+(.+)\s\((.+):(\d+):(\d+)\)').firstMatch(frame);
    if (match != null) {
      final method = match.group(1); // Method name
      final file = match.group(2);   // File name
      final line = match.group(3);   // Line number
      return '$method ($file:$line)';
    }
  }

  return 'Unknown';
}
