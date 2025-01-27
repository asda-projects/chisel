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

  Future<List<Map<String, dynamic>>>  query(String sql, {
      Object? parameters,
      bool ignoreRows = false,
      QueryMode? queryMode,
      Duration? timeout,
    }) async {

     final result = await _connection.execute(sql, 
     parameters: parameters, 
     ignoreRows: ignoreRows, queryMode: queryMode, timeout: timeout
     
     );
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<void> close() async {
    await _connection.close();
  }
}