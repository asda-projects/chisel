import 'dart:io' show Platform; 
import 'package:test/test.dart'; 
import 'package:chisel/chisel.dart'; 

void main() {
  group('Chisel Web Compatibility', () {
    setUp(() {
      
      if (_isNotWeb()) {
        fail("This test is intended for Web environments only.");
      }
    });

    test('Confirm test is running in Web environment', () {
      expect(_isNotWeb(), isFalse, reason: "Test should run only on Web.");
    });

    test('Calling generateModels() should throw an error on Web', () async {
      final chisel = Chisel(
        host: "localhost",
        port: 5432,
        database: "test_db",
        user: "test_user",
        password: "test_password", settings: ChiselConnectionSettings(
          sslMode: SslMode.require
        ),
      );

      expect(
        () async => await chisel.generateModels(),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}

/// **Custom Web Environment Detection**
bool _isNotWeb() {
  try {
    // If `dart:io` is available, it's NOT Web.
    return Platform.isAndroid || Platform.isIOS || Platform.isLinux || Platform.isMacOS || Platform.isWindows;
  } catch (_) {
    // If `Platform` is not available, we're in Web.
    return false;
  }
}

