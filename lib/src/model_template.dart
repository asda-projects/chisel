class ModelGeneratorTemplates {
  /// Template for an entire Dart class
  static String classTemplate({
    required String className,
    required String fields,
    required String constructorParams,
  }) {
    return '''
import 'package:chisel/src/annotations.dart';

class $className {
  $fields

  $className({$constructorParams});

  // Add CRUD and serialization methods here
 }
''';
  }

  /// Template for a field with annotations
  static String fieldTemplate({
    required List<String> annotations,
    required String? type,
    required String name,
  }) {
    return '''
        ${annotations.join('\n')}
        final $type $name;
    ''';
  }

  /// Template for the @Column annotation
static String columnAnnotation({required String columnName, required String? columnType}) {
  return columnType != null
      ? '@Column(name: "$columnName", type: "$columnType")'
      : '@Column(name: "$columnName")';
}

  /// Template for the @ForeignKey annotation
  static String foreignKeyAnnotation({
    required String foreignTable,
    required String foreignColumn,
  }) {
    return '@ForeignKey(table: "$foreignTable", column: "$foreignColumn")';
  }
}
