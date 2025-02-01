import 'dart:io';
import 'dart:convert';

Future<void> ensureDirectoryExists(String directoryPath) async {
  final directory = Directory(directoryPath);
  if (!directory.existsSync()) {
    await directory.create(recursive: true);
  }
}

Future<Map<String, dynamic>> readMetadata(String filePath) async {
  try {
    final file = File(filePath);
    if (!file.existsSync()) return {};
    final content = await file.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  } catch (e) {
    return {}; // Return an empty map if the file cannot be read
  }
}

Future<void> writeMetadata(String filePath, Map<String, dynamic> metadata) async {
  final file = File(filePath);
  await file.writeAsString(jsonEncode(metadata));
}

Future<void> writeFile(String filePath, String content) async {
  final file = File(filePath);
  await file.writeAsString(content);
}

String getFilePath(String underscoredClassName, String fallbackDirectory) {
  return '$fallbackDirectory/$underscoredClassName.dart';
}