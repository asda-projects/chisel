import 'package:chisel/chisel.dart';
import 'package:chisel/src/logger.dart';

import 'package:chisel/src/query_builder.dart';

abstract class ModelAdapter<T> {
  /// Table name in the database
  String get tableName;

  /// Maps raw database rows to the model instance
  T fromMap(Map<String, dynamic> map);

  Chisel get _chisel => Chisel.instance; // Use global Chisel instance

  void _validateFields(dynamic fields) {
    final schema = _chisel.getTableSchema(tableName);
    if (schema == null) {
      throw Exception('Table schema for "$tableName" not found in cache.');
    }

    final fieldNames = fields is String ? [fields] : fields.keys;
    for (var field in fieldNames) {
      if (!schema.hasColumn(field)) {
        throw ArgumentError(
            'Field "$field" does not exist in table "$tableName".');
      }
    }
  }

  Map<String, dynamic> _filterAutoGeneratedFields(
      Map<String, dynamic> parameters) {
    Logger.debug('Filtering auto-generated fields for table "$tableName"',
        context: getCallerContext());

    final schema = _chisel.getTableSchema(tableName);
    if (schema == null) {
      Logger.error('Table schema for "$tableName" not found in cache.',
          context: getCallerContext());
      throw Exception('Table schema for "$tableName" not found in cache.');
    }

    Logger.debug(
        'Schema found for table "$tableName": ${schema.columns.map((col) => col.name).toList()}',
        context: getCallerContext());

    final filteredParameters = Map<String, dynamic>.from(parameters)
      ..removeWhere((key, _) {
        final column = schema.columns.firstWhere((col) => col.name == key,
            orElse: () => throw ArgumentError(
                'Field "$key" does not exist in table "$tableName".'));

        if (column.isAutoGenerated) {
          Logger.debug('Field "$key" is auto-generated and will be excluded.',
              context: getCallerContext());
          return true;
        }
        return false;
      });

    Logger.debug('Filtered parameters: $filteredParameters',
        context: getCallerContext());
    return filteredParameters;
  }

  Future<T> create(
      Map<String, dynamic> parameters, String fieldIfcreated) async {
    try {
      Logger.info('Starting record creation in $tableName',
          context: getCallerContext());
      final filteredParams = _filterAutoGeneratedFields(parameters);

      final query = QueryBuilder.insert(
        tableName: tableName,
        fields: filteredParams,
        useExtendedQuery: false,
      );

      await _chisel.instanceDBConnection.query(
        query,
        // queryMode: QueryMode.simple,
      );

      final result = await read(fieldIfcreated, filteredParams[fieldIfcreated]);

      if (result != null) {
        Logger.info('Record created successfully in $tableName',
            context: getCallerContext());
        return result;
      } else {
        throw Exception('No rows returned after insertion.');
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to create record in $tableName',
          context: getCallerContext());
      Logger.debug('Stack trace: $stackTrace', context: getCallerContext());
      throw Exception('Failed to create entry in $tableName.');
    }
  }

  Future<T?> read(String fieldName, dynamic fieldValue) async {
    _validateFields(fieldName);
    final query = QueryBuilder.selectBy(
      tableName: tableName,
      fieldName: fieldName,
      fieldValue: fieldValue,
    );
    final result = await _chisel.instanceDBConnection.query(query);
    if (result.isNotEmpty) {
      return fromMap(result.first);
    }
    return null;
  }

  Future<List<T>> readAll({Map<String, dynamic>? filters}) async {
    if (filters != null) {
      _validateFields(filters);
    }
    final query =
        QueryBuilder.selectAll(tableName: tableName, filters: filters);
    final result = await _chisel.instanceDBConnection.query(query);
    return result.map((row) => fromMap(row)).toList();
  }

  Future<T> update(String fieldName, dynamic fieldValue,
      Map<String, dynamic> parameters) async {
    _validateFields(fieldName);
    _validateFields(parameters);
    final query = QueryBuilder.update(
      tableName: tableName,
      fieldName: fieldName,
      fieldValue: fieldValue,
      fields: parameters,
    );
    await _chisel.instanceDBConnection.query(
      query,
      // queryMode: QueryMode.simple,
    );

    final result = await read(fieldName, fieldValue);

    if (result != null) {
      Logger.info('update successfully in $tableName',
          context: getCallerContext());
      return result;
    }

    throw Exception('No rows returned after insertion.');
  }

  Future<void> delete(String fieldName, dynamic fieldValue) async {
    _validateFields(fieldName);

    try {
      // Step 1: Fetch dependent tables and relationships
      final dependenciesQuery = QueryBuilder.fetchDependencies(tableName);
      final dependencies =
          await _chisel.instanceDBConnection.query(dependenciesQuery);

      // Step 2: Delete dependent records
      for (var dependency in dependencies) {
        final sourceTable = dependency['source_table'];
        final sourceColumn = dependency['source_column'];

        final deleteDependentQuery = QueryBuilder.deleteDependentRecordsByValue(
          sourceTable: sourceTable,
          sourceColumn: sourceColumn,
          targetTable: tableName,
          targetFieldName: fieldName,
          targetFieldValue: fieldValue,
        );
        await _chisel.instanceDBConnection.query(deleteDependentQuery);
      }

      // Step 3: Delete the primary record
      final deletePrimaryQuery = QueryBuilder.deleteBy(
        tableName: tableName,
        fieldName: fieldName,
        fieldValue: fieldValue,
      );
      await _chisel.instanceDBConnection.query(deletePrimaryQuery);
    } catch (e) {
      throw Exception('Failed to delete record from $tableName.');
    }
  }

  Future<void> deleteAll() async {
    try {
      // Step 1: Fetch dependent tables
      final dependenciesQuery = QueryBuilder.fetchDependencies(tableName);
      final dependencies =
          await _chisel.instanceDBConnection.query(dependenciesQuery);

      // Step 2: Delete records from dependent tables
      for (var dependency in dependencies) {
        final sourceTable = dependency['source_table'];
        final sourceColumn = dependency['source_column'];

        final deleteDependentQuery = QueryBuilder.deleteDependentRecords(
          sourceTable: sourceTable,
          sourceColumn: sourceColumn,
          primaryTable: tableName,
        );
        await _chisel.instanceDBConnection.query(deleteDependentQuery);
      }

      // Step 3: Delete all records from the primary table
      final deletePrimaryQuery = QueryBuilder.deleteAll(tableName: tableName);
      await _chisel.instanceDBConnection.query(deletePrimaryQuery);
    } catch (e) {
      throw Exception('Failed to delete all records from $tableName.');
    }
  }
}
