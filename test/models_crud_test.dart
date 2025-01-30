import 'package:chisel/chisel.dart';
import 'package:chisel/models/defaultdb/auth_user.dart';
import 'package:postgres/postgres.dart';
import 'context.dart';

import 'package:test/test.dart';

void main() {
  group('Chisel Database Integration Tests', () {
    late Chisel chisel;
    final String userNickname = "wilson";
    late AuthUser user;
    setUp(() async {
      // Initialize Chisel with a test database connection
      chisel = Chisel(
        host: LocalVariables.host,
        port: LocalVariables.port,
        database: LocalVariables.database,
        user: LocalVariables.user,
        password: LocalVariables.password,
        settings: ConnectionSettings(sslMode: SslMode.require),
      );

      // Connect to the database
      await chisel.initialize();
      chisel.configureLogging();
      
      user = await AuthUser().create({
        'last_login': DateTime.now().toIso8601String(),
        'date_joined': DateTime.now().toIso8601String(),
        'is_superuser': false,
        'is_staff': false,
        'is_active': true,
        'password': 'se234uds_epa#3r2sd',
        'last_name': 'Doe',
        'email': '$userNickname@example.com',
        'username': userNickname,
        'first_name': 'John',
      }, "email");

      await AuthUser().create({
        'last_login': DateTime.now().toIso8601String(),
        'date_joined': DateTime.now().toIso8601String(),
        'is_superuser': false,
        'is_staff': false,
        'is_active': true,
        'password': 'qwer#x13049d',
        'last_name': 'Umpa',
        'email': '${userNickname}_2@example.com',
        'username': '${userNickname}_2',
        'first_name': 'Lumpa',
      }, "email");
    });

    tearDown(() async {
      // Disconnect from the database after each test
      await AuthUser().deleteAll();
      await chisel.close();
    });

    test('Create - Insert a new user', () async {
      try {
        expect(user.id, isNotNull);
        expect(user.username, equals(userNickname));
      } catch (e) {
        fail('Failed to create user: $e');
      }
    }, tags: 'create');

    test('Read - Fetch a user by username', () async {
      try {
        // Create a user for this test

        final fetchedUser = await AuthUser().read('username', userNickname);

        expect(fetchedUser, isNotNull);
        expect(fetchedUser?.last_name, equals('Doe'));
        expect(fetchedUser?.username, equals(userNickname));
      } catch (e) {
        fail('Failed to fetch user by ID: $e');
      }
    }, tags: 'read');

    test('Fetch all users', () async {
      try {
        final users = await AuthUser().readAll();

        expect(users, isA<List<AuthUser>>());
        expect(users, isNotEmpty);
        expect(users[0].username, equals(userNickname));
        expect(users[1].is_staff, equals(false));
      } catch (e) {
        fail('Failed to fetch all users: $e');
      }
    }, tags: 'readAll');

    test('Update - Modify a user', () async {
      try {
        // Create a user for this test

        // Update the user's last name
        final updatedUser = await AuthUser().update('username', userNickname, {
          'last_name': 'Smith',
        });

        expect(updatedUser.last_name, equals('Smith'));
      } catch (e) {
        fail('Failed to update user: $e');
      }
    }, tags: 'update');

    test('Delete - Remove a user', () async {
      try {
        // Create a user for this test

        final tempuserNickname = 'todelete';

        await AuthUser().create({
          'last_login': DateTime.now().toIso8601String(),
          'date_joined': DateTime.now().toIso8601String(),
          'is_superuser': false,
          'is_staff': false,
          'is_active': true,
          'password': 'se234uds_epa#3r2sd',
          'last_name': 'Doe',
          'email': '$tempuserNickname@example.com',
          'username': tempuserNickname,
          'first_name': 'John',
        }, "email");

        // Delete the user
        await AuthUser().delete('username', tempuserNickname);

        // Attempt to fetch the deleted user
        final deletedUser = await AuthUser().read('username', tempuserNickname);
        expect(deletedUser, isNull);
      } catch (e) {
        fail('Failed to delete user: $e');
      }
    }, tags: 'delete');
  });
}
