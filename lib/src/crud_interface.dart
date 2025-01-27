import 'package:chisel/src/connection.dart';

abstract class BaseModel<T> {
  Future<T> create(SQLConnection connection);
  Future<T?> read(SQLConnection connection, dynamic id);
  Future<List<T>> readAll(SQLConnection connection, {Map<String, dynamic>? filters});
  Future<T> update(SQLConnection connection, dynamic id);
  Future<void> delete(SQLConnection connection, dynamic id);
}