import 'package:gen_art/gen_art.dart';

void main() {
  Bitmap bmp = Bitmap(512, 512);

  for (int y = 0; y < 512; y++) {
    for (int x = 0; x < 512; x++) {
      bmp.setColor(Vec2(x, y), Color(1.0, 0.0, 0.0, 1.0));
    }
  }

  Bitmap mask = Bitmap(512, 512);
  mask.drawLine(Vec2(70, 97), Vec2(145, 487), 2, Color(1.0, 1.0, 1.0, 1.0));

  bmp.savePng('output.png');
  mask.savePng('mask.png');
  bmp.erase(mask);
  bmp.savePng('result.png');
}
