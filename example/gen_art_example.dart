import 'package:gen_art/gen_art.dart';

void main() {
  // Bitmap bmp = Bitmap(512, 512);

  // for (int y = 0; y < 512; y++) {
  //   for (int x = 0; x < 512; x++) {
  //     bmp.setColor(Vec2(x, y), Color(x / 512, y / 512, 0.5, 1.0));
  //   }
  // }

  // bmp.savePng('output1.png');
  // bmp.clip(colorR, ClipMode.clipBelow, 0.5, Color.fromR(1.0));

  // bmp.savePng('output2.png');

  Bitmap bmp = Bitmap.fromList1([
    [Color(0.0, 0.0, 1.0, 1.0), Color(0.0, 0.0, 0.5, 1.0)],
    [Color(0.0, 1.0, 0.0, 1.0), Color(0.0, 0.0, 0.5, 1.0)]
  ]);

  bmp.savePng('output.png');
}
