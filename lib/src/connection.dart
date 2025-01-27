

import 'package:postgres/postgres.dart';

class SQLConnection {

  final String host;
  final String port;
  final String user;
  final String password;
  final ConnectionSettings settings;

  SQLConnection(
    {
    required this.host, 
    required this.port, 
    required this.user, 
    required this.password, 
    this.settings = const ConnectionSettings(sslMode: SslMode.disable),
    }
    
    );

    
    Future<Connection> open() async {
      // The postgres server hosted locally doesn't have SSL by default. If you're
      // accessing a postgres server over the Internet, the server should support
      // SSL and you should swap out the mode with `SslMode.verifyFull`.
      
      final conn = await Connection.open(
            Endpoint(
              host: 'localhost',
              database: 'postgres',
              username: 'user',
              password: 'pass',
            ),
            settings: settings,
          );

      return conn;

    }




}