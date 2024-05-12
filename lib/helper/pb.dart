import 'dart:io';

import 'package:askaide/helper/path.dart';
import 'package:askaide/helper/platform.dart';
import 'package:logger/logger.dart' as logger;
import 'package:pocketbase/pocketbase.dart';

class PB {
  static final instance = PocketBase('https://outfit.gptgo.top');
}
