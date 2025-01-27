class Table {
  final String name;
  final List<Column> columns;

  Table({required this.name, required this.columns});
}

class Column {
  final String name;
  final String? type;
  final String? foreignTable;
  final String? foreignColumn;

  const Column({
    required this.name,
    required this.type,
    this.foreignTable,
    this.foreignColumn,
  });
}

class ForeignKey {
  final String table;
  final String column;

  const ForeignKey({
    required this.table,
    required this.column,
  });
}
