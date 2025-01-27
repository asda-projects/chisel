class Table {
  final String name;
  final List<Column> columns;

  Table({required this.name, required this.columns});
}

class Column {
  final String name;
  final String type;
  final String? foreignTable;
  final String? foreignColumn;

  Column({
    required this.name,
    required this.type,
    this.foreignTable,
    this.foreignColumn,
  });
}