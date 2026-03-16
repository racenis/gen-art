import 'color.dart';
import 'vec2.dart';

abstract class Mapping {
  Color getValueAt(Vec2 pos);
}
