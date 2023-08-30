import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:askaide/helper/logger.dart';
import 'package:askaide/lang/lang.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

String randomId() {
  return const Uuid().v4();
}

/// 将 base64 转换为图片，存储到临时文件
Future<String> writeImageFromBase64(String base64, String ext) async {
  final directory = await getApplicationDocumentsDirectory();
  // 确保目录存在
  await Directory('${directory.path}/cache').create(recursive: true);

  final file = File('${directory.path}/cache/temp_${randomId()}.$ext');
  await file.writeAsBytes(base64Decode(base64));
  return file.path.substring(directory.path.length + 1);
}

String filenameWithoutExt(String filePath) {
  int slashIndex = filePath.lastIndexOf('/');
  int dotIndex = filePath.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex < slashIndex) {
    return filePath.substring(slashIndex + 1);
  } else {
    return filePath.substring(slashIndex + 1, dotIndex);
  }
}

Future<File> writeTempFile(String path, Uint8List bytes) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$path');
  return await file.writeAsBytes(bytes);
}

Future<Uint8List> readTempFile(String path) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$path');
  return await file.readAsBytes();
}

Future<void> writeStringFileToDocumentsDirectory(
    String path, String content) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$path');
    Logger.instance.e('${directory.path}/$path');
    await file.writeAsString(content);
  } catch (e) {
    Logger.instance.e('写入文件失败: $e');
  }
}

Future<String> readStringFileFromDocumentsDirectory(String path) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$path');
    return await file.readAsString();
  } catch (e) {
    return '';
  }
}

Future<void> removeExternalFile(String externalFilepath) async {
  // Get the external file
  final File externalFile = File(externalFilepath);

  // Check if the external file exists
  if (!await externalFile.exists()) {
    return;
  }

  await externalFile.delete();
}

Future<String> copyExternalFileToAppDocs(String externalFilePath) async {
  // Get the external file
  final File externalFile = File(externalFilePath);

  // Check if the external file exists
  if (!await externalFile.exists()) {
    throw Exception('External file not found at: $externalFilePath');
  }

  // Get the ApplicationDocumentsDirectory
  final Directory appDocsDir = await getApplicationDocumentsDirectory();

  // Generate a UUID for the new file name
  final String uuid = const Uuid().v4();

  // Get the file extension
  final String fileExtension = externalFile.path.split('.').last;

  // Create a new file in the ApplicationDocumentsDirectory with the UUID as its name
  final File newFile = File('${appDocsDir.path}/$uuid.$fileExtension');

  // Copy the external file to the new file in the ApplicationDocumentsDirectory
  await externalFile.copy(newFile.path);

  // print('File copied to: ${newFile.path}');
  return newFile.path;
}

/// 将时间转换为友好的时间
String humanTime(DateTime? ts, {bool withTime = false}) {
  if (ts == null || ts.millisecondsSinceEpoch == 0) {
    return '';
  }

  var now = DateTime.now();
  var diff = now.difference(ts);
  if (diff.inDays > 0) {
    if (withTime) {
      return DateFormat('yyyy/MM/dd HH:mm').format(ts.toLocal());
    }

    return DateFormat('yyyy/MM/dd').format(ts.toLocal());
  }

  if (diff.inHours > 0) {
    return '${diff.inHours}小时前';
  }

  if (diff.inMinutes > 0) {
    return '${diff.inMinutes}分钟前';
  }

  return '刚刚';
}

/// 解析错误信息
String resolveError(BuildContext context, Object error) {
  if (error is LanguageText) {
    return error.message.getString(context);
  }

  return error.toString();
}
