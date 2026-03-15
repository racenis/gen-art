import 'package:gen_art/gen_art.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

// class ShiftLeft5 implements Mapping {
//   final Bitmap _source;
//   ShiftLeft5(this._source);

//   @override
//   Color getValueAt(Vec2 pos) {
//     return _source.getColor(Vec2(pos.x + 5, pos.y));
//   }
// }

void main() {
  img.Image? loaded =
      img.decodeImage(File('gen-art_Test.png').readAsBytesSync());
  Bitmap bmp = Bitmap.fromImage(loaded!);

  Bitmap kernel = Bitmap.fromList2([
    [1, 1, 1],
    [1, 1, 1],
    [1, 1, 1],
  ]);

  kernel.normalize();

  Bitmap blurred = bmp.convolve(kernel);
  blurred.savePng('output2.png');

  bmp.drawLine(Vec2(0, 0), Vec2(511, 511), 5, Color.fromB(1.0));

  bmp.savePng('output1.png');
}
