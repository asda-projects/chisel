import 'package:chisel/src/logger.dart';
import 'package:chisel/src/map_types.dart';

class QueryBuilder {
  static String insert({
    required String tableName,
    required Map<String, dynamic> fields,
    bool useExtendedQuery = false,
  }) {
    final columns = fields.keys.join(', ');

    // Handle named parameters or direct values
    final values = _useExtendedQuery(fields, useExtendedQuery); // Direct values

    Logger.debug(
        'Insert query generated for $tableName: Columns=[$columns], Values=[$values]',
        context: getCallerContext());
    return "INSERT INTO $tableName ($columns) VALUES ($values);";
  }

  static String _useExtendedQuery(
      Map<String, dynamic> fields, bool useExtendedQuery) {
    Logger.debug('Using Named Params: $useExtendedQuery',
        context: getCallerContext());
    final values = useExtendedQuery
        ? fields.keys.map((key) => '@$key').join(', ') // Named placeholders
        : fields.values.map(TypeSwitcher.dartToSqlValue).join(', ');

    return values;
  }

  static String selectBy({
    required String tableName,
    required String fieldName,
    required dynamic fieldValue,
  }) {
    final formattedValue = fieldValue is String ? "'$fieldValue'" : fieldValue;
    return 'SELECT * FROM $tableName WHERE $fieldName = $formattedValue;';
  }

  static String selectAll({
    required String tableName,
    Map<String, dynamic>? filters,
  }) {
    if (filters == null || filters.isEmpty) {
      return 'SELECT * FROM $tableName;';
    }
    final conditions = filters.entries.map((entry) {
      final formattedValue =
          entry.value is String ? "'${entry.value}'" : entry.value;
      return '${entry.key} = $formattedValue';
    }).join(' AND ');
    return 'SELECT * FROM $tableName WHERE $conditions;';
  }

  static String update({
    required String tableName,
    required String fieldName,
    required dynamic fieldValue,
    required Map<String, dynamic> fields,
  }) {
    final updates = fields.entries.map((entry) {
      final formattedValue =
          entry.value is String ? "'${entry.value}'" : entry.value;
      return '${entry.key} = $formattedValue';
    }).join(', ');
    final formattedFieldValue =
        fieldValue is String ? "'$fieldValue'" : fieldValue;
    return 'UPDATE $tableName SET $updates WHERE $fieldName = $formattedFieldValue;';
  }

  static String deleteBy({
    required String tableName,
    required String fieldName,
    required dynamic fieldValue,
  }) {
    final formattedValue = fieldValue is String ? "'$fieldValue'" : fieldValue;
    return 'DELETE FROM $tableName WHERE $fieldName = $formattedValue;';
  }

  static String deleteAll({required String tableName}) {
    return 'DELETE FROM $tableName;';
  }

  static String fetchDependencies(String tableName) {
    return '''
      SELECT
        tc.table_name AS source_table,
        kcu.column_name AS source_column,
        ccu.table_name AS target_table,
        ccu.column_name AS target_column
      FROM
        information_schema.table_constraints AS tc
      JOIN
        information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
      JOIN
        information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
      WHERE
        tc.constraint_type = 'FOREIGN KEY'
        AND ccu.table_name = '$tableName';
    ''';
  }

  static String deleteDependentRecords({
    required String sourceTable,
    required String sourceColumn,
    required String primaryTable,
  }) {
    return '''
      DELETE FROM $sourceTable
      WHERE $sourceColumn IN (SELECT id FROM $primaryTable);
    ''';
  }

  static String deleteDependentRecordsByValue({
    required String sourceTable,
    required String sourceColumn,
    required String targetTable,
    required String targetFieldName,
    required dynamic targetFieldValue,
  }) {
    final formattedValue =
        targetFieldValue is String ? "'$targetFieldValue'" : targetFieldValue;
    return '''
    DELETE FROM $sourceTable
    WHERE $sourceColumn IN (
      SELECT id FROM $targetTable WHERE $targetFieldName = $formattedValue
    );
  ''';
  }
}
