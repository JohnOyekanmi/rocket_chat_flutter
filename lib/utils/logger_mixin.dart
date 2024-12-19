import 'package:logger/logger.dart';

mixin LoggerMixin on Object {
  String module = '';

  Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: null,
      errorMethodCount: null,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
    level: Level.off,
  );

  void setLogModule(String module) {
    this.module = module;
  }

  void log(String component, String message) {
    if (module.isEmpty) {
      logger.i('$component: $message');
    } else {
      logger.i('Logging Message for $module ===============================>');
      logger.i('$component: $message');
      logger.i('============================================================');
    }
  }

  void logE(String component, String message) {
    if (module.isEmpty) {
      logger.e('$component: $message');
    } else {
      logger.e('Logging Error for $module ===============================>');
      logger.e('$component: $message');
      logger.e('============================================================');
    }
  }
}
