import 'package:test/test.dart';
import 'package:gen_art/gen_art.dart';

void main() {
  group('Bitmap - basic set/get', () {
    test('initial pixels are transparent black', () {
      final bmp = Bitmap(2, 2);
      final c = bmp.getColor(Vec2(0, 0));
      expect(c.r, equals(0.0));
      expect(c.g, equals(0.0));
      expect(c.b, equals(0.0));
      expect(c.a, equals(0.0));
    });

    test('setColor then getColor returns same color', () {
      final bmp = Bitmap(4, 4);
      final color = Color(0.1, 0.5, 0.9, 1.0);
      bmp.setColor(Vec2(2, 3), color);
      final result = bmp.getColor(Vec2(2, 3));
      expect(result.r, closeTo(0.1, 1e-9));
      expect(result.g, closeTo(0.5, 1e-9));
      expect(result.b, closeTo(0.9, 1e-9));
      expect(result.a, closeTo(1.0, 1e-9));
    });

    test('writing to one pixel does not affect neighbors', () {
      final bmp = Bitmap(4, 4);
      bmp.setColor(Vec2(2, 2), Color(1.0, 0.0, 0.0, 1.0));
      expect(bmp.getColor(Vec2(1, 2)).r, equals(0.0));
      expect(bmp.getColor(Vec2(3, 2)).r, equals(0.0));
      expect(bmp.getColor(Vec2(2, 1)).r, equals(0.0));
      expect(bmp.getColor(Vec2(2, 3)).r, equals(0.0));
    });

    test('setColor overwrites previous value', () {
      final bmp = Bitmap(4, 4);
      bmp.setColor(Vec2(1, 1), Color(1.0, 0.0, 0.0, 1.0));
      bmp.setColor(Vec2(1, 1), Color(0.0, 1.0, 0.0, 1.0));
      final result = bmp.getColor(Vec2(1, 1));
      expect(result.r, equals(0.0));
      expect(result.g, equals(1.0));
    });
  });

  group('Bitmap - clip mode (default)', () {
    late Bitmap bmp;
    final red = Color(1.0, 0.0, 0.0, 1.0);

    setUp(() {
      bmp = Bitmap(4, 4);
      for (int x = 0; x < 4; x++) {
        bmp.setColor(Vec2(x, 0), red);
        bmp.setColor(Vec2(x, 3), red);
      }
      for (int y = 0; y < 4; y++) {
        bmp.setColor(Vec2(0, y), red);
        bmp.setColor(Vec2(3, y), red);
      }
    });

    test('x < 0 clamps to x=0', () {
      expect(bmp.getColor(Vec2(-5, 1)).r, equals(1.0));
    });

    test('x >= width clamps to x=width-1', () {
      expect(bmp.getColor(Vec2(100, 1)).r, equals(1.0));
    });

    test('y < 0 clamps to y=0', () {
      expect(bmp.getColor(Vec2(1, -5)).r, equals(1.0));
    });

    test('y >= height clamps to y=height-1', () {
      expect(bmp.getColor(Vec2(1, 100)).r, equals(1.0));
    });

    test('setColor out of bounds does nothing', () {
      bmp.setColor(Vec2(-1, 0), Color(0.5, 0.5, 0.5, 1.0));
      bmp.setColor(Vec2(0, -1), Color(0.5, 0.5, 0.5, 1.0));
      bmp.setColor(Vec2(4, 0), Color(0.5, 0.5, 0.5, 1.0));
      bmp.setColor(Vec2(0, 4), Color(0.5, 0.5, 0.5, 1.0));
      expect(bmp.getColor(Vec2(0, 0)).r, equals(1.0));
    });
  });

  group('Bitmap - wrap mode', () {
    late Bitmap bmp;

    setUp(() {
      bmp = Bitmap(4, 4, mode: BitmapMode.wrap);
      bmp.setColor(Vec2(0, 0), Color(1.0, 0.0, 0.0, 1.0));
      bmp.setColor(Vec2(3, 3), Color(0.0, 1.0, 0.0, 1.0));
    });

    test('x = width wraps to x=0', () {
      expect(bmp.getColor(Vec2(4, 0)).r, equals(1.0));
    });

    test('x = -1 wraps to x=width-1', () {
      expect(bmp.getColor(Vec2(-1, 3)).g, equals(1.0));
    });

    test('y = height wraps to y=0', () {
      expect(bmp.getColor(Vec2(0, 4)).r, equals(1.0));
    });

    test('y = -1 wraps to y=height-1', () {
      expect(bmp.getColor(Vec2(3, -1)).g, equals(1.0));
    });

    test('large negative x wraps correctly', () {
      expect(bmp.getColor(Vec2(-8, 0)).r, equals(1.0));
    });

    test('large positive x wraps correctly', () {
      expect(bmp.getColor(Vec2(8, 0)).r, equals(1.0));
    });
  });

  group('Bitmap - fromList1 constructor', () {
    test('reads colors correctly from 2D list', () {
      final red = Color(1.0, 0.0, 0.0, 1.0);
      final blue = Color(0.0, 0.0, 1.0, 1.0);
      final bmp = Bitmap.fromList1([
        [red, blue],
        [blue, red],
      ]);
      expect(bmp.getColor(Vec2(0, 0)).r, equals(1.0));
      expect(bmp.getColor(Vec2(1, 0)).b, equals(1.0));
      expect(bmp.getColor(Vec2(0, 1)).b, equals(1.0));
      expect(bmp.getColor(Vec2(1, 1)).r, equals(1.0));
    });
  });

  group('Bitmap - fromList2 constructor', () {
    test('grayscale values map to r=g=b with alpha=1', () {
      final bmp = Bitmap.fromList2([
        [0.0, 1.0],
        [0.5, 0.25],
      ]);
      final c = bmp.getColor(Vec2(1, 0));
      expect(c.r, equals(1.0));
      expect(c.g, equals(1.0));
      expect(c.b, equals(1.0));
      expect(c.a, equals(1.0));

      final c2 = bmp.getColor(Vec2(0, 1));
      expect(c2.r, closeTo(0.5, 1e-9));
    });
  });

  group('Bitmap - clip()', () {
    test('clipBelow on R channel replaces pixels below threshold', () {
      final bmp = Bitmap(2, 1);
      bmp.setColor(Vec2(0, 0), Color(0.1, 0.5, 0.5, 1.0));
      bmp.setColor(Vec2(1, 0), Color(0.8, 0.5, 0.5, 1.0));

      bmp.clip(colorR, ClipMode.clipBelow, 0.5, Color(0.0, 0.0, 0.0, 1.0));

      expect(bmp.getColor(Vec2(0, 0)).r, equals(0.0));
      expect(bmp.getColor(Vec2(1, 0)).r, closeTo(0.8, 1e-9));
    });

    test('clipAbove on R channel replaces pixels above threshold', () {
      final bmp = Bitmap(2, 1);
      bmp.setColor(Vec2(0, 0), Color(0.9, 0.0, 0.0, 1.0));
      bmp.setColor(Vec2(1, 0), Color(0.3, 0.0, 0.0, 1.0));

      bmp.clip(colorR, ClipMode.clipAbove, 0.5, Color(1.0, 1.0, 1.0, 1.0));

      expect(bmp.getColor(Vec2(0, 0)).r, equals(1.0));
      expect(bmp.getColor(Vec2(1, 0)).r, closeTo(0.3, 1e-9));
    });

    test('clipBelow on G channel replaces whole pixel with replacement', () {
      final bmp = Bitmap(1, 1);
      bmp.setColor(Vec2(0, 0), Color(0.9, 0.1, 0.9, 1.0));
      bmp.clip(colorG, ClipMode.clipBelow, 0.5, Color(0.9, 0.0, 0.9, 1.0));

      expect(bmp.getColor(Vec2(0, 0)).r, closeTo(0.9, 1e-9));
      expect(bmp.getColor(Vec2(0, 0)).g, equals(0.0));
      expect(bmp.getColor(Vec2(0, 0)).b, closeTo(0.9, 1e-9));
    });

    test('clipBelow on B channel replaces whole pixel with replacement', () {
      final bmp = Bitmap(1, 1);
      bmp.setColor(Vec2(0, 0), Color(0.9, 0.9, 0.1, 1.0));
      bmp.clip(colorB, ClipMode.clipBelow, 0.5, Color(0.9, 0.9, 0.0, 1.0));

      expect(bmp.getColor(Vec2(0, 0)).r, closeTo(0.9, 1e-9));
      expect(bmp.getColor(Vec2(0, 0)).g, closeTo(0.9, 1e-9));
      expect(bmp.getColor(Vec2(0, 0)).b, equals(0.0));
    });

    test('pixel above threshold is not replaced', () {
      final bmp = Bitmap(1, 1);
      bmp.setColor(Vec2(0, 0), Color(0.1, 0.9, 0.1, 1.0));
      bmp.clip(colorG, ClipMode.clipBelow, 0.5, Color(0.0, 0.0, 0.0, 1.0));

      expect(bmp.getColor(Vec2(0, 0)).r, closeTo(0.1, 1e-9));
      expect(bmp.getColor(Vec2(0, 0)).g, closeTo(0.9, 1e-9));
    });

    test(
        'clip with multiple channels replaces when any matching channel triggers',
        () {
      final bmp = Bitmap(1, 1);
      bmp.setColor(Vec2(0, 0), Color(0.1, 0.1, 0.9, 1.0));
      bmp.clip(
          colorR | colorG, ClipMode.clipBelow, 0.5, Color(0.0, 0.0, 0.0, 1.0));

      expect(bmp.getColor(Vec2(0, 0)).r, equals(0.0));
      expect(bmp.getColor(Vec2(0, 0)).g, equals(0.0));
      expect(bmp.getColor(Vec2(0, 0)).b, equals(0.0));
    });
  });

  group('Bitmap - erase()', () {
    test('subtracts mask from image', () {
      final bmp = Bitmap(1, 1);
      bmp.setColor(Vec2(0, 0), Color(0.8, 0.6, 0.4, 1.0));

      final mask = Bitmap(1, 1);
      mask.setColor(Vec2(0, 0), Color(0.3, 0.2, 0.1, 1.0));

      bmp.erase(mask);

      final result = bmp.getColor(Vec2(0, 0));
      expect(result.r, closeTo(0.5, 1e-9));
      expect(result.g, closeTo(0.4, 1e-9));
      expect(result.b, closeTo(0.3, 1e-9));
    });

    test('result clamps to 0.0 when subtraction goes negative', () {
      final bmp = Bitmap(1, 1);
      bmp.setColor(Vec2(0, 0), Color(0.1, 0.1, 0.1, 1.0));

      final mask = Bitmap(1, 1);
      mask.setColor(Vec2(0, 0), Color(0.9, 0.9, 0.9, 1.0));

      bmp.erase(mask);

      final result = bmp.getColor(Vec2(0, 0));
      expect(result.r, equals(0.0));
      expect(result.g, equals(0.0));
      expect(result.b, equals(0.0));
    });
  });

  group('Bitmap - mix()', () {
    test('normal mode: fully opaque other fully replaces base color', () {
      final base = Bitmap(1, 1);
      base.setColor(Vec2(0, 0), Color(1.0, 0.0, 0.0, 1.0));

      final other = Bitmap(1, 1);
      other.setColor(Vec2(0, 0), Color(0.0, 1.0, 0.0, 1.0));

      base.mix(other, MixMode.normal);

      expect(base.getColor(Vec2(0, 0)).r, closeTo(0.0, 1e-9));
      expect(base.getColor(Vec2(0, 0)).g, closeTo(1.0, 1e-9));
    });

    test('normal mode: fully transparent other leaves base unchanged', () {
      final base = Bitmap(1, 1);
      base.setColor(Vec2(0, 0), Color(1.0, 0.0, 0.0, 1.0));

      final other = Bitmap(1, 1);
      other.setColor(Vec2(0, 0), Color(0.0, 1.0, 0.0, 0.0));

      base.mix(other, MixMode.normal);

      expect(base.getColor(Vec2(0, 0)).r, closeTo(1.0, 1e-9));
      expect(base.getColor(Vec2(0, 0)).g, closeTo(0.0, 1e-9));
    });

    test('normal mode: 50% alpha blends halfway', () {
      final base = Bitmap(1, 1);
      base.setColor(Vec2(0, 0), Color(1.0, 0.0, 0.0, 1.0));

      final other = Bitmap(1, 1);
      other.setColor(Vec2(0, 0), Color(0.0, 0.0, 0.0, 0.5));

      base.mix(other, MixMode.normal);

      expect(base.getColor(Vec2(0, 0)).r, closeTo(0.5, 1e-9));
    });
  });

  group('Bitmap - colorTransfer()', () {
    test('transfers R value to G channel', () {
      final bmp = Bitmap(1, 1);
      bmp.setColor(Vec2(0, 0), Color(0.8, 0.0, 0.0, 1.0));

      bmp.colorTransfer(colorR, colorG);

      expect(bmp.getColor(Vec2(0, 0)).r, closeTo(0.8, 1e-9));
      expect(bmp.getColor(Vec2(0, 0)).g, closeTo(0.8, 1e-9));
    });

    test('transfers average of R and G to B', () {
      final bmp = Bitmap(1, 1);
      bmp.setColor(Vec2(0, 0), Color(0.4, 0.8, 0.0, 1.0));

      bmp.colorTransfer(colorR | colorG, colorB);

      expect(bmp.getColor(Vec2(0, 0)).b, closeTo(0.6, 1e-9));
    });

    test('transfers R to A channel', () {
      final bmp = Bitmap(1, 1);
      bmp.setColor(Vec2(0, 0), Color(0.5, 0.0, 0.0, 0.0));

      bmp.colorTransfer(colorR, colorA);

      expect(bmp.getColor(Vec2(0, 0)).a, closeTo(0.5, 1e-9));
    });
  });

  group('Bitmap - normalize()', () {
    test('scales values so R channel sums to 1.0', () {
      final bmp = Bitmap(1, 2);
      bmp.setColor(Vec2(0, 0), Color(1.0, 0.0, 0.0, 1.0));
      bmp.setColor(Vec2(0, 1), Color(3.0, 0.0, 0.0, 1.0));

      bmp.normalize();

      expect(bmp.getColor(Vec2(0, 0)).r, closeTo(0.25, 1e-9));
      expect(bmp.getColor(Vec2(0, 1)).r, closeTo(0.75, 1e-9));
    });

    test('does nothing when all pixels are zero', () {
      final bmp = Bitmap(2, 2);
      bmp.normalize();

      expect(bmp.getColor(Vec2(0, 0)).r, equals(0.0));
    });
  });

  group('Bitmap - drawPoint()', () {
    test('draws a single pixel when width=1', () {
      final bmp = Bitmap(5, 5);
      bmp.drawPoint(Vec2(2, 2), 1, Color(1.0, 0.0, 0.0, 1.0));

      expect(bmp.getColor(Vec2(2, 2)).r, equals(1.0));
      expect(bmp.getColor(Vec2(1, 2)).r, equals(0.0));
      expect(bmp.getColor(Vec2(3, 2)).r, equals(0.0));
    });

    test('draws a 3x3 block when width=3', () {
      final bmp = Bitmap(5, 5);
      bmp.drawPoint(Vec2(2, 2), 3, Color(1.0, 0.0, 0.0, 1.0));

      for (int y = 1; y <= 3; y++) {
        for (int x = 1; x <= 3; x++) {
          expect(bmp.getColor(Vec2(x, y)).r, equals(1.0));
        }
      }
    });
  });

  group('Bitmap - drawLine()', () {
    test('draws a horizontal line', () {
      final bmp = Bitmap(10, 10);
      bmp.drawLine(Vec2(1, 5), Vec2(8, 5), 1, Color(1.0, 0.0, 0.0, 1.0));

      for (int x = 1; x <= 8; x++) {
        expect(bmp.getColor(Vec2(x, 5)).r, equals(1.0));
      }
    });

    test('draws a vertical line', () {
      final bmp = Bitmap(10, 10);
      bmp.drawLine(Vec2(5, 1), Vec2(5, 8), 1, Color(0.0, 1.0, 0.0, 1.0));

      for (int y = 1; y <= 8; y++) {
        expect(bmp.getColor(Vec2(5, y)).g, equals(1.0));
      }
    });

    test('draws a single point when from == to', () {
      final bmp = Bitmap(5, 5);
      bmp.drawLine(Vec2(2, 2), Vec2(2, 2), 1, Color(0.0, 0.0, 1.0, 1.0));

      expect(bmp.getColor(Vec2(2, 2)).b, equals(1.0));
    });
  });
}
