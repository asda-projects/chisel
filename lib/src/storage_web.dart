import 'secure_storage.dart';

Future<void> ensureDirectoryExists(String directoryPath) async {
  // No-op for Web
}

Future<Map<String, dynamic>> readMetadata(String key) async {
  return await SecureStorage.loadMetadata();
}

Future<void> writeMetadata(String key, Map<String, dynamic> metadata) async {
  await SecureStorage.saveMetadata(metadata);
}


Future<void> writeFile(String filePath, String content) async {
  throw UnsupportedError("File writing is not supported on Web. Run `generateModels` in a separate Dart script.");
}

String getFilePath(String underscoredClassName, String fallbackDirectory) {
  throw UnsupportedError("File paths are not used on Web. Run `generateModels` externally.");
}
