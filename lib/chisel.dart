/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'package:chisel/src/connection.dart';
import 'package:chisel/src/schema_information.dart';
import 'package:postgres/postgres.dart';

export 'src/chisel_base.dart';





class Chisel {
  final String? databaseUrl;
  final String? host;
  final int? port;
  final String? database;
  final String? user;
  final String? password;

  late SQLConnection _connection;

  Chisel({
    this.databaseUrl,
    this.host,
    this.port,
    this.database,
    this.user,
    this.password,
  }) {
    // Validate input to ensure either `databaseUrl` or connection parameters are provided
    if (databaseUrl == null &&
        (host == null || port == null || database == null || user == null || password == null)) {
      throw ArgumentError(
          'You must provide either a valid databaseUrl or all connection parameters (host, port, database, user, password).');
    }
  }

  Future<void> connect() async {
    if (databaseUrl != null) {
      // Parse databaseUrl and initialize SQLConnection
      final uri = Uri.parse(databaseUrl!);
      _connection = SQLConnection(
        host: uri.host,
        port: uri.port,
        database: uri.path.substring(1), // Remove leading '/'
        user: uri.userInfo.split(':')[0],
        password: uri.userInfo.split(':')[1],
      );
    } else {
      // Use the provided connection parameters to initialize SQLConnection
      _connection = SQLConnection(
        host: host!,
        port: port!,
        database: database!,
        user: user!,
        password: password!,
      );
    }

    // Open the connection
    await _connection.open(); // This establishes the connection
  }

  Future<void> generateModels({String outputDirectory = 'lib/models/'}) async {
    // Implement schema introspection and model generation here
    // Use _connection to interact with the database
  }

  Future<List<String>> getTables({String schema = 'public'}) async {
  final query = InformationSchemaQueryBuilder.selectTables(schema: schema);
  final result = await _connection.query(query);
  return result.map((row) => row['table_name'] as String).toList();
}

Future<List<Map<String, dynamic>>> getColumns(String table) async {
  final query = InformationSchemaQueryBuilder.selectColumns(tableName: table);
  final result = await _connection.query(query);
  return result;
}

Future<List<Table>> introspectSchema({String schema = 'public'}) async {
    final tables = await getTables(schema: schema);
    List<Table> schemaTables = [];

    for (var tableName in tables) {
      final columnsData = await getColumns(tableName);
      final columns = columnsData.map((col) {
        final dartType = _mapSqlTypeToDart(col['data_type']);
        return Column(name: col['column_name'], type: dartType);
      }).toList();

      schemaTables.add(Table(name: tableName, columns: columns));
    }

    return schemaTables;
  }




  String _mapSqlTypeToDart(String sqlType) {
      switch (sqlType) {
        case 'integer':
          return 'int';
        case 'text':
        case 'varchar':
        case 'char':
          return 'String';
        case 'boolean':
          return 'bool';
        case 'timestamp':
        case 'date':
          return 'DateTime';
        default:
          return 'dynamic';
      }
  }

  String _toPascalCase(String input) {
      return input.split('_').map((part) => part[0].toUpperCase() + part.substring(1)).join();
  }

  Future<void> close() async {
    await _connection.close();
  }




}


class Table {
  final String name;
  final List<Column> columns;

  Table({required this.name, required this.columns});
}

class Column {
  final String name;
  final String type;

  Column({required this.name, required this.type});
}
