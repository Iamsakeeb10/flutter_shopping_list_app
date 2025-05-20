import 'package:logger/logger.dart';

// Customize your logger format if needed
Logger logger = Logger(
  printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
);
