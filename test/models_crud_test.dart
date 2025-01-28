import 'package:chisel/chisel.dart';
import 'package:chisel/models/defaultdb/auth_user.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';
import 'context.dart';

void main() {
  group('Chisel Database Integration Tests', () {
    late Chisel chisel;
    final String userNickname = "wilson";
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

    });

    tearDown(() async {
      // Disconnect from the database after each test
      await AuthUser().deleteAll();
      await chisel.close();
    });


    test('Create - Insert a new user', () async {
      try {
        final user = await AuthUser().create({
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
        });

        
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
        expect(fetchedUser?.username, equals('johndoe'));
      } catch (e) {
        fail('Failed to fetch user by ID: $e');
      }
    }, tags: 'read');

    test('Fetch all users', () async {
      try {


        final users = await AuthUser().readAll();
        

        expect(users, isA<List<AuthUser>>());
        expect(users, isNotEmpty);
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
        print('Updated user: ${updatedUser.id}');

        expect(updatedUser.last_name, equals('Smith'));
      } catch (e) {
        fail('Failed to update user: $e');
      }
    }, tags: 'update');

    test('Delete - Remove a user', () async {
      try {
        // Create a user for this test


        // Delete the user
        await AuthUser().delete('username', userNickname);
        

        // Attempt to fetch the deleted user
        final deletedUser = await AuthUser().read('username', userNickname);
        expect(deletedUser, isNull);
      } catch (e) {
        fail('Failed to delete user: $e');
      }
    }, tags: 'delete');


  });
}
