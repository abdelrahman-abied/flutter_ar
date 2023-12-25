import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Log {
  static final logger = Logger(printer: PrettyPrinter(colors: true));

  static void d(String message) {
    if (kDebugMode) logger.d(message);
  }

  static void e(String message) {
    if (kDebugMode) logger.e(message);
  }

  static void i(String message) {
    if (kDebugMode) logger.i(message);
  }

  static void w(String message) {
    if (kDebugMode) logger.w(message);
  }
}
