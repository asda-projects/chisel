import 'dart:io';

import 'package:chisel/chisel.dart';
import 'package:chisel/src/annotations.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import 'context.dart';

void main() {
  group('Chisel Database Integration Tests', () {
     late Chisel chisel;

    setUp(() async {
      // Initialize Chisel with a test database connection
      chisel = Chisel(
        host: LocalVariables.host,
        port: LocalVariables.port,
        database: LocalVariables.database,
        user: LocalVariables.user,
        password: LocalVariables.password,
        settings: ConnectionSettings(sslMode: SslMode.require)
      );

      // Connect to the database
      await chisel.connect();
    });

    tearDown(() async {
      // Disconnect from the database after each test
      await chisel.close();
    });

    test('Test getTables - Fetch all tables in the database', () async {
      // Act: Fetch tables
      final tables = await chisel.getTables();

      
      expect(tables, isA<List<String>>());
      expect(tables, isNotEmpty); // 
    });

    test('Test getColumns - Fetch columns for a specific table', () async {
      // Arrange: Ensure the table exists
      final tableName = 'auth_user'; // Replace with a table that exists in your test database

      // Act: Fetch columns
      final columns = await chisel.getColumns(tableName);

      // Assert: Verify the result
      expect(columns, isA<List<Map<String, dynamic>>>());
      expect(columns, isNotEmpty); // Ensure the table has columns
      expect(columns[0]['column_name'], isA<String>()); // Verify column metadata
    });

    test('Test introspectSchema - Introspect the entire database schema', () async {
      // Act: Introspect the schema
      final schema = await chisel.introspectSchema();

      // Assert: Verify the result
      expect(schema, isA<List<Table>>());
      expect(schema, isNotEmpty); // Ensure the schema has tables
      expect(schema[0].columns, isNotEmpty); // Ensure tables have columns
    });

    test('Test generateModels - Generate Dart models for the database schema', () async {
      // Arrange: Set up the output directory
      

      // Act: Generate models
      await chisel.generateModels();

      // Assert: Verify that the models were generated
      final outputDir = Directory(chisel.defaultOutputDirectory);
      expect(outputDir.existsSync(), isTrue); // Ensure the directory exists
      expect(outputDir.listSync(), isNotEmpty); // Ensure files were generated
    });


  });


}
