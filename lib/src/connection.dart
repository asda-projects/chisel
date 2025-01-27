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
    // Process the parameters (named or positional)
    final processedParameters = _processQueryParameters(parameters);

    final result = await _connection.execute(
      sql,
      parameters: processedParameters,
      ignoreRows: ignoreRows,
      queryMode: queryMode,
      timeout: timeout,
    );

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