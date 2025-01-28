import 'dart:typed_data';

/// A utility class to map SQL types to Dart types.
class TypeSwitcher {
  /// Maps a given SQL type to its corresponding Dart type.
  static String sqlToDart(String sqlType) {
    switch (sqlType.toLowerCase()) {
      case 'integer':
      case 'int':
      case 'smallint':
      case 'bigint':
        return 'int';
      case 'real':
      case 'double precision':
      case 'float':
      case 'numeric':
      case 'decimal':
        return 'double';
      case 'text':
      case 'varchar':
      case 'character varying':
      case 'char':
      case 'character':
        return 'String';
      case 'boolean':
      case 'bool':
        return 'bool';
      case 'timestamp':
      case 'timestamp without time zone':
      case 'timestamp with time zone':
      case 'date':
        return 'DateTime';
      case 'json':
      case 'jsonb':
        return 'Map<String, dynamic>';
      case 'bytea':
        return 'Uint8List';
      default:
        return 'dynamic'; // Fallback for unknown types
    }
  }

  /// Checks if the given SQL type is nullable.
  static bool isNullable(String isNullableValue) {
    return isNullableValue.toLowerCase() == 'yes';
  }

/// Converts Dart values to SQL-compatible strings for queries.
  static String dartToSqlValue(dynamic value) {
  if (value == null) return 'NULL'; 
  if (value is String) return "'${value.replaceAll("'", "''")}'"; 
  if (value is DateTime) return "'${value.toIso8601String()}'";
  if (value is bool) return '$value'; //? 'TRUE' : 'FALSE';
  if (value is num) return value.toString();
  if (value is Map) return "'${value.toString().replaceAll("'", "''")}'";
  if (value is Uint8List) return "E'\\\\x${value.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}'";
  return "'${value.toString().replaceAll("'", "''")}'"; 
  }

  /// Converts a map of Dart field values to SQL-compatible values.
  static String dartToSql(Map<String, dynamic> fields) {
    return fields.entries.map((entry) {
      final value = dartToSqlValue(entry.value);
      return value; // Format as column = value
    }).join(', ');
  }
}
