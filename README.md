<p align="center">
  <a href="https://pub.dev/packages/chisel">
    <img src="https://raw.githubusercontent.com/asda-projects/chisel/main/lib/assets/chisel.png" alt="Chisel Logo" width="100"/>
  </a>
</p>

<h1 align="center">Chisel</h1>


<p align="center">
  <a href="https://pub.dev/packages/chisel"><img src="https://img.shields.io/pub/v/chisel?style=for-the-badge" alt="Pub Version"></a>
  <a href="https://github.com/asda-project/chisel"><img src="https://img.shields.io/github/stars/asda-projects/chisel?style=for-the-badge" alt="GitHub Stars"></a>
  <a href="https://github.com/your-repo/chisel/issues"><img src="https://img.shields.io/github/issues/asda-projects/chisel?style=for-the-badge" alt="GitHub Issues"></a>
</p>



**Chisel is a Dart library that simplifies database interaction by providing dynamic schema introspection, robust query generation, and model management. This library enables seamless CRUD operations while keeping your database models synchronized and easy to use.**

## Features

- Dynamic model generation from database schemas.
- Parameterized and direct query support.
- Comprehensive CRUD operations.
- Flexible logging with contextual information.
- Integration tests for database interactions.

---

## Getting Started

### Installation

Add Chisel to your `pubspec.yaml`:

```yaml
dependencies:
  chisel: ^1.0.0
```

Install the package:

```bash
dart pub get
```

---

## Usage

### Initialize Chisel

Before interacting with your database, initialize the Chisel instance with your database credentials:

```dart
import 'package:chisel/chisel.dart';
import 'package:postgres/postgres.dart';

void main() async {
  final chisel = Chisel(
    host: 'localhost',
    port: 5432,
    database: 'my_database',
    user: 'my_user',
    password: 'my_password',
    settings: ConnectionSettings(sslMode: SslMode.require),
  );

  await chisel.initialize();
  print('Chisel initialized successfully!');

  // Close the connection when done
  await chisel.close();
}
```

---
### Generating Models

Chisel can introspect your database schema and generate models for each table. These models are placed in a directory under `lib/models/[database_name]`.

```dart
await chisel.generateModels();
```

By default, Chisel checks if models have already been generated to avoid unnecessary regeneration. If you need to force regeneration (e.g., after schema changes), you can use the `forceUpdate` parameter:

```dart
await chisel.generateModels(forceUpdate: true);
```

- **Default Behavior**: If models are already up-to-date, the generation process is skipped.
- **Force Update**: Setting `forceUpdate` to `true` will regenerate models, even if they already exist.




For example, if your database contains a table `auth_user`, Chisel generates a corresponding Dart model `AuthUser`. You can then import and use the model as follows:

```dart
import 'package:chisel/models/[database_name]/auth_user.dart';
```

---

### Example Workflow

Below is a comprehensive example showcasing Chisel’s key functionalities.

#### Fetch Tables and Schema

```dart
final tables = await chisel.getTables();
print('Tables: $tables');

final schema = await chisel.introspectSchema();
print('Schema: $schema');
```

#### Use Generated Models

Once models are generated, you can perform CRUD operations using these models.

* **IMPORTANT**:
  - _**After provide the "Map<String, dynamic> parameters" field, you need provide a field "String fieldIfcreated" to validate if it was really created, preferably a unique field.**_
  - Due to lib dependencies problems it was a temporary workaround.
  - The example below used "email".
   

##### Create a Record

```dart
final user = await AuthUser().create({
  'username': 'johndoe',
  'email': 'johndoe@example.com',
  'password': 'securepassword',
  'is_active': true,
  'date_joined': DateTime.now().toIso8601String(),
}, "email");

print('Created user: ${user.username}');
```

##### Read a Record

```dart
final fetchedUser = await AuthUser().read('username', 'johndoe');
print('Fetched user: ${fetchedUser?.email}');
```

##### Update a Record

```dart
final updatedUser = await AuthUser().update('username', 'johndoe', {
  'email': 'newemail@example.com',
});

print('Updated user email: ${updatedUser.email}');
```

##### Delete a Record

```dart
await AuthUser().delete('username', 'johndoe');
print('User deleted successfully!');
```

---

## Logging

Chisel provides robust logging for debugging SQL queries and operations. You can enable or disable logging and set the log level:

```dart
chisel.configureLogging(level: LogLevel.info, enable: true);
```

---

## Limitations and Improvements

- **Insert/Update Without Direct Result**: Due to limitations in the Postgres library, the `create` and `update` methods first execute the query and then retrieve the result by re-reading the table.
- **Future Enhancements**:
  - Provide an option for external model generation: Allow users to generate models into their own project directory via `generateModels(outputDirectory: ...)`.

---

## Testing

Chisel includes integration tests to ensure correct functionality.

```dart
void main() {
  group('Chisel Database Integration Tests', () {
    late Chisel chisel;

    setUp(() async {
      chisel = Chisel(
        host: 'localhost',
        port: 5432,
        database: 'test_db',
        user: 'test_user',
        password: 'test_password',
        settings: ConnectionSettings(sslMode: SslMode.require),
      );
      await chisel.initialize();
    });

    tearDown(() async {
      await chisel.close();
    });

    test('Fetch tables', () async {
      final tables = await chisel.getTables();
      expect(tables, isNotEmpty);
    });
  });
}
```

---

## Future Plans

- Provide external model generation to allow users to manage their models independently.
- Enhance support for complex query operations and transactions.
- Introduce support for advanced schema migrations.

---

## Contributions

Contributions are welcome! Please open an issue or create a pull request on [GitHub Repo](http://github.com/asda-projects/chisel).

---

## License

Chisel is open-source and licensed under the MIT License.

