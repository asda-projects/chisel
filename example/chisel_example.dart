import 'package:chisel/chisel.dart';
import 'package:chisel/models/defaultdb/auth_user.dart';

void main() async {
  // Initialize Chisel with PostgreSQL connection details
  final chisel = Chisel(
    host: 'localhost', // Replace with your database host
    port: 5432, // Replace with your database port
    database: 'example_db', // Replace with your database name
    user: 'user', // Replace with your username
    password: 'password', // Replace with your password
    settings: ConnectionSettings(
        sslMode: SslMode.require), // Adjust SSL settings as needed
  );

  // Connect to the database and introspect the schema
  print('Connecting to the database...');
  await chisel.initialize();
  print('Connected successfully.');

  // Generate models based on the database schema
  print('Generating models...');
  await chisel.generateModels();

  // Example of using a generated model (e.g., `AuthUser`)
  // Ensure you import the generated model in your application
  final userNickname = 'johndoe';

  // IMPORTANT:
  // - After provide the "Map<String, dynamic> parameters" field,
  //    you need provide a field "String fieldIfcreated" to validate
  //    if it was really created, preferably a unique field.
  // - Due to lib dependencies problems it was a temporary workaround.
  // - The example below used "email".

  try {
    // Create a new user
    final newUser = await AuthUser().create({
      'username': userNickname,
      'email': '$userNickname@example.com',
      'first_name': 'John',
      'last_name': 'Doe',
      'password': 'secure_password',
      'is_active': true,
      'is_staff': false,
      'is_superuser': false,
      'date_joined': DateTime.now().toIso8601String(),
      'last_login': null,
    }, 'email');
    print('User created successfully: ${newUser.username}');

    // Read the created user by username
    final fetchedUser = await AuthUser().read('username', userNickname);
    if (fetchedUser != null) {
      print('Fetched user: ${fetchedUser.first_name} ${fetchedUser.last_name}');
    }

    // Update the user's last name
    final updatedUser = await AuthUser().update(
      'username',
      userNickname,
      {'last_name': 'Smith'},
    );
    print('Updated user last name to: ${updatedUser.last_name}');

    // Fetch all users
    final allUsers = await AuthUser().readAll();
    print('All users in the database:');
    for (var user in allUsers) {
      print(' - ${user.username}');
    }

    // Delete the user
    await AuthUser().delete('username', userNickname);
    print('User deleted successfully.');
  } catch (e) {
    print('Error during CRUD operations: $e');
  } finally {
    // Close the database connection
    await chisel.close();
    print('Database connection closed.');
  }
}
