import 'package:uuid/uuid.dart';

/// Central place for generating primary keys so every table uses the same
/// ID shape (useful when merging imported backups without collisions).
class IdGenerator {
  IdGenerator._();

  static const Uuid _uuid = Uuid();

  static String newId() => _uuid.v4();
}
