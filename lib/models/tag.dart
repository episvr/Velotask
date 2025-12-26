import 'package:isar/isar.dart';
import 'package:velotask/utils/logger.dart';

part 'tag.g.dart';

@collection
class Tag {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  String? color; // Hex string, e.g., "#FF0000"

  static final Logger _logger = AppLogger.getLogger('Tag');

  Tag({required this.name, this.color}) {
    _logger.fine('Tag instance created: name=$name, color=$color');
  }
}
