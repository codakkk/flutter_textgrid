import 'package:flutter_textgrid/flutter_textgrid.dart';

abstract class ITextGridSerializer {
  TextGrid deserialize(List<String> lines);
  String toText(TextGrid tg);
}
