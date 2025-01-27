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
}
