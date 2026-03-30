import 'bitmap.dart';
import 'color.dart';
import 'vec2.dart';
import 'dart:math';

Color _pick(bool primary, double hue1, double hue2, double sat) {
  return primary
      ? Color.fromHSV(hue1, sat, 0.9)
      : Color.fromHSV(hue2, sat, 0.75);
}

/// Generates a hexagonal grid pattern.
/// params[0] - color 1 hue (0.0-1.0)
/// params[1] - color 2 hue (0.0-1.0)
/// params[2] - cell size (0.0-1.0)
/// params[3] - border thickness (0.0-1.0)
/// params[4] - saturation (0.0-1.0)
Bitmap generateHexagons(List<double> params, int width, int height) {
  Bitmap bmp = Bitmap(width, height);

  double hue1 = params[0] * 360.0;
  double hue2 = params[1] * 360.0;
  double scale = params[2] * 60.0 + 10.0;
  double border = params[3] * 0.3 + 0.05;
  double sat = params[4];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      double row = y / (scale * sqrt(3) / 2);
      double col = x / scale;
      bool offset = row.floor() % 2 == 1;
      double nx = (col + (offset ? 0.5 : 0.0)) % 1.0;
      double ny = row % 1.0;

      double dx = (nx - 0.5).abs();
      double dy = (ny - 0.5).abs();
      double dist = max(dx, dx * 0.5 + dy * sqrt(3) / 2);

      bmp.setColor(Vec2(x, y), _pick(dist <= 0.5 - border, hue1, hue2, sat));
    }
  }
  return bmp;
}

/// Generates a herringbone pattern.
/// params[0] - color 1 hue (0.0-1.0)
/// params[1] - color 2 hue (0.0-1.0)
/// params[2] - brick size (0.0-1.0)
/// params[3] - color ratio (0.0-1.0)
/// params[4] - saturation (0.0-1.0)
Bitmap generateHerringbone(List<double> params, int width, int height) {
  Bitmap bmp = Bitmap(width, height);

  double hue1 = params[0] * 360.0;
  double hue2 = params[1] * 360.0;
  double scale = params[2] * 40.0 + 8.0;
  double ratio = params[3] * 0.4 + 0.3;
  double sat = params[4];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int brickX = x ~/ scale.toInt();
      int brickY = y ~/ (scale / 2).toInt();

      bool horizontal = brickY % 2 == 0;
      double local =
          horizontal ? (x % scale) / scale : (y % (scale / 2)) / (scale / 2);

      if (horizontal && brickX % 2 == 1) local = 1.0 - local;

      bmp.setColor(Vec2(x, y), _pick(local < ratio, hue1, hue2, sat));
    }
  }
  return bmp;
}

/// Generates a chevron pattern.
/// params[0] - color 1 hue (0.0-1.0)
/// params[1] - color 2 hue (0.0-1.0)
/// params[2] - scale (0.0-1.0)
/// params[3] - saturation (0.0-1.0)
Bitmap generateChevron(List<double> params, int width, int height) {
  Bitmap bmp = Bitmap(width, height);

  double hue1 = params[0] * 360.0;
  double hue2 = params[1] * 360.0;
  double scale = (params[2] * 40.0 + 8.0).roundToDouble();
  double sat = params[3];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int row = (y / scale).floor();
      double localY = (y % scale) / scale;
      double localX = (x % scale) / scale;

      double zigzag = row % 2 == 0 ? localX : 1.0 - localX;

      bmp.setColor(Vec2(x, y), _pick(localY < zigzag, hue1, hue2, sat));
    }
  }
  return bmp;
}

/// Generates a brick pattern.
/// params[0] - brick color hue (0.0-1.0)
/// params[1] - mortar color hue (0.0-1.0)
/// params[2] - brick width (0.0-1.0)
/// params[3] - brick height (0.0-1.0)
/// params[4] - mortar size (0.0-1.0)
/// params[5] - saturation (0.0-1.0)
Bitmap generateBricks(List<double> params, int width, int height) {
  Bitmap bmp = Bitmap(width, height);

  double hue1 = params[0] * 360.0;
  double hue2 = params[1] * 360.0;
  double brickWidth = params[2] * 60.0 + 20.0;
  double brickHeight = params[3] * 30.0 + 10.0;
  double mortarSize = params[4] * 4.0 + 1.0;
  double sat = params[5];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int row = (y / brickHeight).floor();
      double offsetX = row % 2 == 0 ? 0.0 : brickWidth / 2;

      double localX = (x + offsetX) % brickWidth;
      double localY = y % brickHeight;

      bool isBrick = localX >= mortarSize && localY >= mortarSize;

      bmp.setColor(Vec2(x, y), _pick(isBrick, hue1, hue2, sat));
    }
  }
  return bmp;
}

/// Generates a crossstitch pattern.
/// params[0] - cross color hue (0.0-1.0)
/// params[1] - background color hue (0.0-1.0)
/// params[2] - scale (0.0-1.0)
/// params[3] - cross thickness (0.0-1.0)
/// params[4] - saturation (0.0-1.0)
Bitmap generateCrossstitch(List<double> params, int width, int height) {
  Bitmap bmp = Bitmap(width, height);

  double hue1 = params[0] * 360.0;
  double hue2 = params[1] * 360.0;
  double scale = (params[2] * 20.0 + 6.0).roundToDouble();
  double thickness = params[3] * 0.3 + 0.1;
  double sat = params[4];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      double nx = (x % scale) / scale - 0.5;
      double ny = (y % scale) / scale - 0.5;

      bmp.setColor(
        Vec2(x, y),
        _pick(nx.abs() < thickness || ny.abs() < thickness, hue1, hue2, sat),
      );
    }
  }
  return bmp;
}

/// Generates a Greek meander pattern.
/// params[0] - color 1 hue (0.0-1.0)
/// params[1] - color 2 hue (0.0-1.0)
/// params[2] - tile size (0.0-1.0)
/// params[3] - saturation (0.0-1.0)
Bitmap generateMeander(List<double> params, int width, int height) {
  Bitmap bmp = Bitmap(width, height);

  double hue1 = params[0] * 360.0;
  double hue2 = params[1] * 360.0;
  int scale = (params[2] * 16.0 + 4.0).toInt();
  double sat = params[3];

  const List<String> tile = [
    '11111111',
    '10000001',
    '10111101',
    '10100001',
    '10101111',
    '10100000',
    '10111110',
    '00000010',
  ];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int tx = (x ~/ scale) % 8;
      int ty = (y ~/ scale) % 8;

      bmp.setColor(
        Vec2(x, y),
        _pick(tile[ty][tx] == '1', hue1, hue2, sat),
      );
    }
  }
  return bmp;
}

/// Generates a checkerboard pattern.
/// params[0] - color 1 hue (0.0-1.0)
/// params[1] - color 2 hue (0.0-1.0)
/// params[2] - cell size (0.0-1.0)
/// params[3] - saturation (0.0-1.0)
Bitmap generateCheckerboard(List<double> params, int width, int height) {
  Bitmap bmp = Bitmap(width, height);

  double hue1 = params[0] * 360.0;
  double hue2 = params[1] * 360.0;
  double scale = params[2] * 60.0 + 8.0;
  double sat = params[3];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      bool black = ((x ~/ scale.toInt()) + (y ~/ scale.toInt())) % 2 == 0;

      bmp.setColor(Vec2(x, y), _pick(black, hue1, hue2, sat));
    }
  }
  return bmp;
}

/// Generates a grid pattern.
/// params[0] - fill color hue (0.0-1.0)
/// params[1] - line color hue (0.0-1.0)
/// params[2] - cell size (0.0-1.0)
/// params[3] - line thickness (0.0-1.0)
/// params[4] - saturation (0.0-1.0)
Bitmap generateGrid(List<double> params, int width, int height) {
  Bitmap bmp = Bitmap(width, height);

  double hue1 = params[0] * 360.0;
  double hue2 = params[1] * 360.0;
  double scale = params[2] * 60.0 + 10.0;
  double borderSize = params[3] * 0.3 + 0.02;
  double sat = params[4];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      double nx = (x % scale) / scale;
      double ny = (y % scale) / scale;
      bool isLine = nx < borderSize || ny < borderSize;

      bmp.setColor(Vec2(x, y), _pick(!isLine, hue1, hue2, sat));
    }
  }
  return bmp;
}

/// Generates a concentric squares pattern.
/// params[0] - color 1 hue (0.0-1.0)
/// params[1] - color 2 hue (0.0-1.0)
/// params[2] - cell size (0.0-1.0)
/// params[3] - ring thickness (0.0-1.0)
/// params[4] - saturation (0.0-1.0)
Bitmap generateConcentricSquares(List<double> params, int width, int height) {
  Bitmap bmp = Bitmap(width, height);

  double hue1 = params[0] * 360.0;
  double hue2 = params[1] * 360.0;
  double scale = params[2] * 40.0 + 10.0;
  double thickness = params[3] * 0.4 + 0.1;
  double sat = params[4];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      double nx = (x % scale) / scale - 0.5;
      double ny = (y % scale) / scale - 0.5;
      double dist = max(nx.abs(), ny.abs());
      bool filled = (dist * 2) % (2 * thickness) < thickness;

      bmp.setColor(Vec2(x, y), _pick(filled, hue1, hue2, sat));
    }
  }
  return bmp;
}

/// Generates a hatching pattern.
/// params[0] - line color hue (0.0-1.0)
/// params[1] - background color hue (0.0-1.0)
/// params[2] - line spacing (0.0-1.0)
/// params[3] - line thickness (0.0-1.0)
/// params[4] - crosshatch mode (0.0 = single, 1.0 = cross)
/// params[5] - saturation (0.0-1.0)
Bitmap generateHatching(List<double> params, int width, int height) {
  Bitmap bmp = Bitmap(width, height);

  double hue1 = params[0] * 360.0;
  double hue2 = params[1] * 360.0;
  double scale = params[2] * 20.0 + 4.0;
  double thickness = params[3] * 0.4 + 0.1;
  bool crosshatch = params[4] > 0.5;
  double sat = params[5];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      double d1 = ((x + y) % scale) / scale;
      double d2 = ((x - y) % scale + scale) % scale / scale;

      bool filled = d1 < thickness || (crosshatch && d2 < thickness);

      bmp.setColor(Vec2(x, y), _pick(filled, hue1, hue2, sat));
    }
  }
  return bmp;
}
