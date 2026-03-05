import 'package:gen_art/gen_art.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

void main() {
  img.Image? loaded =
      img.decodeImage(File('gen-art_Test.png').readAsBytesSync());

  Bitmap bmp = Bitmap.fromImage(loaded!);

  bmp.savePng('result.png');
}
