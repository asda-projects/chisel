import 'package:postgres/postgres.dart' show ConnectionSettings;

class ChiselConnectionSettings extends ConnectionSettings {
  const ChiselConnectionSettings({
    super.applicationName,
    super.timeZone,
    super.encoding,
    super.sslMode,
    super.transformer,
    super.replicationMode,
    super.typeRegistry,
    super.securityContext,
    super.onOpen,
    super.connectTimeout,
    super.queryTimeout,
    super.queryMode,
    super.ignoreSuperfluousParameters,
  });
}