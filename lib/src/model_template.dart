class ModelGeneratorTemplates {
  /// Template for generating a Dart class representing a database table.
  static String classTemplate({
    required String className,
    required String fields,
    required String constructorParams,
    required String tableName,
  }) {
    return '''
// ignore_for_file: non_constant_identifier_names
import 'package:chisel/src/annotations.dart';
import 'package:chisel/src/model_adapter.dart';

class $className extends ModelAdapter<$className> {
  ${_removeFinalFromRequiredStringFields(fields)}

  $className({$constructorParams});

  @override
  String get tableName => '$tableName';

  @override
  $className fromMap(Map<String, dynamic> map) {
    return $className(
      ${_generateConstructorParams(fields)}
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      ${_generateToMapFields(fields)}
    };
  }
}
''';
  }

  /// Helper to remove the `final` keyword from field definitions.
  static String _removeFinalFromRequiredStringFields(String fields) {
    return fields.replaceAll(RegExp(r'\bfinal\b\s*'), '');
  }

  /// Helper to generate the constructor parameters from field definitions.
  static String _generateConstructorParams(String fields) {
    return fields
        .split('\n')
        .where((line) => line.contains('final')) // Filter out only final field definitions
        .map((line) {
          final name = line.split(' ').last.replaceAll(';', '').trim();
          return '$name: map["$name"]';
        })
        .join(',\n');
  }

  /// Helper to generate the fields for the `toMap` method.
  static String _generateToMapFields(String fields) {
    return fields
        .split('\n')
        .where((line) => line.contains('final')) // Filter out only final field definitions
        .map((line) {
          final name = line.split(' ').last.replaceAll(';', '').trim();
          return '"$name": $name';
        })
        .join(',\n');
  }

  /// Template for generating a field with annotations.
  static String fieldTemplate({
    required List<String> annotations,
    required String? type,
    required String name,
  }) {
    return '''
        ${annotations.join('\n')}
        final $type? $name;
    ''';
  }

  /// Template for generating the @Column annotation.
  static String columnAnnotation({
    required String columnName,
    required String? columnType,
  }) {
    return columnType != null
        ? '@Column(name: "$columnName", type: "$columnType")'
        : '@Column(name: "$columnName")';
  }

  /// Template for generating the @ForeignKey annotation.
  static String foreignKeyAnnotation({
    required String foreignTable,
    required String foreignColumn,
  }) {
    return '@ForeignKey(table: "$foreignTable", column: "$foreignColumn")';
  }
}