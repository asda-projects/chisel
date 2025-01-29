/// Support for doing something awesome.
///
/// More dartdocs go here.
library;

import 'dart:convert';
import 'dart:io';

import 'package:chisel/src/annotations.dart';
import 'package:chisel/src/db_connection.dart';
import 'package:chisel/src/logger.dart';
import 'package:chisel/src/map_types.dart';
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

  static late Chisel instance;
  late SQLConnection instanceDBConnection;
  final String defaultOutputDirectory = 'lib/models';
  final String _metadataFilePath = '.chisel_generated';
  final Map<String, Table> schemaCache = {};

  Chisel(
      {this.databaseUrl,
      this.host,
      this.port,
      this.database,
      this.user,
      this.password,
      required this.settings}) {
    // Validate input to ensure either `databaseUrl` or connection parameters are provided
    if (databaseUrl == null &&
        (host == null ||
            port == null ||
            database == null ||
            user == null ||
            password == null)) {
      throw ArgumentError(
          'You must provide either a valid databaseUrl or all connection parameters (host, port, database, user, password).');
    }
  }

  Future<void> initialize() async {
    await connect();
    await introspectSchema();
    instance = this; // Assign the singleton instance
  }

  Future<void> connect() async {
    if (databaseUrl != null) {
      // Parse databaseUrl and initialize SQLConnection
      final uri = Uri.parse(databaseUrl!);
      instanceDBConnection = SQLConnection(
          host: uri.host,
          port: uri.port,
          database: uri.path.substring(1), // Remove leading '/'
          user: uri.userInfo.split(':')[0],
          password: uri.userInfo.split(':')[1],
          settings: settings);
    } else {
      // Use the provided connection parameters to initialize SQLConnection
      instanceDBConnection = SQLConnection(
          host: host!,
          port: port!,
          database: database!,
          user: user!,
          password: password!,
          settings: settings);
    }

    // Open the connection
    await instanceDBConnection.open(); // This establishes the connection
  }

  void configureLogging({LogLevel level = LogLevel.info, bool enable = true}) {
    Logger.setLevel(level);
    Logger.enableLogging(enable);
  }

  Future<void> _ensureDirectoryExists(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
  }

  Future<Map<String, dynamic>> _readMetadata(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return {};
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      return {}; // Return an empty map if the file cannot be read
    }
  }

// Helper to write metadata
  Future<void> _writeMetadata(
      String filePath, Map<String, dynamic> metadata) async {
    final file = File(filePath);
    await file.writeAsString(jsonEncode(metadata));
  }

  Future<void> generateModels({bool forceUpdate = false}) async {
    final metadata = await _readMetadata(_metadataFilePath);

    if (!forceUpdate && metadata['modelsGenerated'] == true) {
      Logger.info(
          "Models are up-to-date. Use 'forceUpdate: true' in 'generateModels' to regenerate.",
          context: getCallerContext());
      return;
    }
    String fallbackDirectory = "$defaultOutputDirectory/$database";
    await _ensureDirectoryExists(fallbackDirectory);

    final tables = await introspectSchema();

    for (final table in tables) {
      final className = _toPascalCase(table.name);
      final fields = table.columns.map((col) {
        final annotations = <String>[];

        // Add @Column annotation
        annotations.add(ModelGeneratorTemplates.columnAnnotation(
            columnName: col.name, columnType: col.type));

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
        tableName: table.name,
        className: className,
        fields: fields,
        constructorParams: table.columns.map((col) {
          return 'this.${col.name}';
          //final isAutoGenerated = col.isAutoGenerated; // Check if the field is auto-generated

          //return isAutoGenerated ? 'this.${col.name}' : 'required this.${col.name}';
        }).join(', '),
      );
      final filePath =
          '$fallbackDirectory/${_convertToUnderscoreCase(className)}.dart';
      await File(filePath).writeAsString(classContent);
    }

    metadata['modelsGenerated'] = true;
    await _writeMetadata(_metadataFilePath, metadata);
  }

  String _convertToUnderscoreCase(String className) {
    String result = "";
    for (int i = 0; i < className.length; i++) {
      String char = className[i];
      if (i > 0 && char == char.toUpperCase()) {
        result += "_";
      }
      result += char.toLowerCase();
    }
    return result;
  }

  Future<List<String>> getTables({String schema = 'public'}) async {
    final query = InformationSchemaQueryBuilder.selectTables(schema: schema);
    final result = await instanceDBConnection.query(query);
    return result.map((row) => row['table_name'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> getColumns(String table) async {
    final query = InformationSchemaQueryBuilder.selectColumns(tableName: table);
    final result = await instanceDBConnection.query(query);
    return result;
  }

  Future<List<Map<String, dynamic>>> getForeignKeys(String table) async {
    final query = InformationSchemaQueryBuilder.selectFK(tableName: table);
    final result = await instanceDBConnection.query(query);
    return result;
  }

  Future<List<Table>> introspectSchema({String schema = 'public'}) async {
    final tables = await getTables(schema: schema);
    List<Table> schemaTables = [];

    for (var tableName in tables) {
      final columnsData = await getColumns(tableName);
      final foreignKeys = await getForeignKeys(tableName);

      final columns = columnsData.map((col) {
        final isAutoGenerated = col['column_default']
                ?.contains('generated by default as identity') ??
            false;
        final foreignKey = foreignKeys.firstWhere(
          (fk) => fk['column_name'] == col['column_name'],
          orElse: () =>
              <String, dynamic>{}, // Return an empty map instead of null
        );

        return Column(
            name: col['column_name'],
            type: _mapSqlTypeToDart(col['data_type']),
            foreignTable:
                foreignKey.isNotEmpty ? foreignKey['foreign_table'] : null,
            foreignColumn:
                foreignKey.isNotEmpty ? foreignKey['foreign_column'] : null,
            isAutoGenerated: isAutoGenerated);
      }).toList();

      final table = Table(name: tableName, columns: columns);
      schemaTables.add(table);

      schemaCache[tableName] = table;
    }

    return schemaTables;
  }

  Table? getTableSchema(String tableName) {
    return schemaCache[tableName];
  }

  String _mapSqlTypeToDart(String sqlType) {
    return TypeSwitcher.sqlToDart(sqlType);
  }

  String _toPascalCase(String input) {
    return input
        .split('_')
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join();
  }

  Future<void> close() async {
    await instanceDBConnection.close();
  }
}
