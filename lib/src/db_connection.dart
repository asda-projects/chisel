import 'package:chisel/src/logger.dart';
import 'package:postgres/postgres.dart';

class SQLConnection {
  final String host;
  final int port;
  final String database;
  final String user;
  final String password;
  final ConnectionSettings settings;

  SQLConnection({
    required this.host,
    required this.port,
    required this.database,
    required this.user,
    required this.password,
    this.settings = const ConnectionSettings(sslMode: SslMode.disable),
  });

  late Connection _connection;

  Future<void> open() async {
    final endpoint = Endpoint(
      host: host,
      port: port,
      database: database,
      username: user,
      password: password,
    );

    _connection = await Connection.open(endpoint, settings: settings);
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? parameters,
    bool ignoreRows = false,
    QueryMode? queryMode,
    Duration? timeout,
  }) async {
    final processedParameters = _processQueryParameters(parameters);

    Logger.debug('${'=' * 20} NEW QUERY ${'=' * 20}', context: '');

    final sqlQuery = parameters != null ? Sql.named(sql) : sql;

    Logger.debug('SQL Query: $sql', context: getCallerContext());
    Logger.debug('Query Mode: $queryMode', context: getCallerContext());
    Logger.debug('Processed Parameters: $processedParameters',
        context: getCallerContext());

    final result = await _connection.execute(
      sqlQuery,
      parameters: processedParameters,
      ignoreRows: ignoreRows,
      queryMode: queryMode,
      timeout: timeout,
    );

    Logger.debug('Raw Result: $result', context: getCallerContext());

    return result.map((row) => row.toColumnMap()).toList();
  }

  Object? _processQueryParameters(Map<String, dynamic>? parameters) {
    if (parameters == null) return null;

    // Check if the map contains named parameters (keys start with '@')
    final isNamed = parameters.keys.any((key) => key.startsWith('@'));

    if (isNamed) {
      // Return the parameters as a map for named parameters
      return parameters;
    } else {
      // Convert to a list for positional parameters
      return parameters.values.toList();
    }
  }

  Future<void> close() async {
    await _connection.close();
  }
}
