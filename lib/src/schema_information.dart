class InformationSchemaQueryBuilder {
  static String selectTables({required String schema}) {
    return '''
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = '$schema';
    ''';
  }

  static String selectColumns({required String tableName}) {
    return '''
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns
      WHERE table_name = '$tableName';
    ''';
  }

  static String selectFK({required String tableName}) {
    return '''
    SELECT
      kcu.column_name AS column_name,
      ccu.table_name AS foreign_table,
      ccu.column_name AS foreign_column
    FROM
      information_schema.table_constraints AS tc
    JOIN
      information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
    JOIN
      information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
    WHERE
      tc.table_name = '$tableName'
      AND tc.constraint_type = 'FOREIGN KEY';
  ''';
  }
}
