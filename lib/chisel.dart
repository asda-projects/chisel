/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'dart:io';

import 'package:chisel/src/annotations.dart';
import 'package:chisel/src/connection.dart';
import 'package:chisel/src/model_template.dart';
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
  final ConnectionSettings settings;

  late SQLConnection _connection;
  final String defaultOutputDirectory = 'lib/models';

  Chisel({
    this.databaseUrl,
    this.host,
    this.port,
    this.database,
    this.user,
    this.password,
    required this.settings
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
        settings: settings
      );
    } else {
      // Use the provided connection parameters to initialize SQLConnection
      _connection = SQLConnection(
        host: host!,
        port: port!,
        database: database!,
        user: user!,
        password: password!,
        settings: settings
      );
    }

    // Open the connection
    await _connection.open(); // This establishes the connection
  }

  Future<void> _ensureDirectoryExists(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
  }

  Future<void> generateModels({String? outputDirectory}) async {
  String fallbackDirectory = outputDirectory ?? defaultOutputDirectory;
  await _ensureDirectoryExists(fallbackDirectory);

  final tables = await introspectSchema();

  for (final table in tables) {
    final className = _toPascalCase(table.name);
    final fields = table.columns.map((col) {
      final annotations = <String>[];

      // Add @Column annotation
      annotations.add(ModelGeneratorTemplates.columnAnnotation(columnName:  col.name, columnType: col.type));

      // Add @ForeignKey annotation if applicable
      if (col.foreignTable != null && col.foreignColumn != null) {
        annotations.add(
          ModelGeneratorTemplates.foreignKeyAnnotation(
            foreignTable: col.foreignTable!,
            foreignColumn: col.foreignColumn!,
          ),
        );
      }

      return ModelGeneratorTemplates.fieldTemplate(
        annotations: annotations,
        type: col.type,
        name: col.name,
      );
    }).join('\n');

    final classContent = ModelGeneratorTemplates.classTemplate(
      className: className,
      fields: fields,
      constructorParams: table.columns
          .map((col) => 'required this.${col.name}')
          .join(', '),
    );

    final filePath = '$fallbackDirectory/$className.dart';
    await File(filePath).writeAsString(classContent);
  }
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

Future<List<Map<String, dynamic>>> getForeignKeys(String table) async {

  final query = InformationSchemaQueryBuilder.selectFK(tableName: table);
  final result = await _connection.query(query);
  return result;
}

Future<List<Table>> introspectSchema({String schema = 'public'}) async {
    final tables = await getTables(schema: schema);
    List<Table> schemaTables = [];

    for (var tableName in tables) {
      final columnsData = await getColumns(tableName);
      final foreignKeys = await getForeignKeys(tableName);

      final columns = columnsData.map((col) {
        final foreignKey = foreignKeys.firstWhere(
          (fk) => fk['column_name'] == col['column_name'],
          orElse: () => <String, dynamic>{}, // Return an empty map instead of null
        );

        return Column(
          name: col['column_name'],
          type: _mapSqlTypeToDart(col['data_type']),
          foreignTable: foreignKey.isNotEmpty ? foreignKey['foreign_table'] : null,
          foreignColumn: foreignKey.isNotEmpty ? foreignKey['foreign_column'] : null,
        );
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



