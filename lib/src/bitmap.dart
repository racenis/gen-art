import 'color.dart';
import 'vec2.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'mapping.dart';

enum BitmapMode { wrap, clip }

enum ClipMode { clipBelow, clipAbove }

enum MixMode { normal }

const int colorR = 0x1;
const int colorG = 0x2;
const int colorB = 0x4;
const int colorA = 0x8;

class Bitmap {
  final int _width;
  final int _height;
  final BitmapMode _mode;
  late List<Color> _pixels;

  Bitmap(int width, int height, {BitmapMode mode = BitmapMode.clip})
      : _width = width,
        _height = height,
        _mode = mode {
    assert(_width > 0 && _height > 0);

    int pixcount = _width * _height;

    _pixels = [];
    for (int i = 0; i < pixcount; i++) {
      _pixels.add(Color(0, 0, 0, 0));
    }
  }

  Bitmap.fromList1(List<List<Color>> array)
      : _width = array[0].length,
        _height = array.length,
        _mode = BitmapMode.clip {
    _pixels = [];
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        _pixels.add(array[y][x]);
      }
    }
  }

  Bitmap.fromList2(List<List<double>> array)
      : _width = array[0].length,
        _height = array.length,
        _mode = BitmapMode.clip {
    _pixels = [];
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        _pixels.add(Color(array[y][x], array[y][x], array[y][x], 1.0));
      }
    }
  }

  void savePng(String path) {
    File(path).writeAsBytesSync(img.encodePng(toImage()));
  }

  img.Image toImage() {
    img.Image image = img.Image(width: _width, height: _height);
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        Color c = getColor(Vec2(x, y));
        image.setPixelRgba(x, y, (c.r * 255).toInt(), (c.g * 255).toInt(),
            (c.b * 255).toInt(), (c.a * 255).toInt());
      }
    }
    return image;
  }

  Bitmap.fromImage(img.Image image)
      : _width = image.width,
        _height = image.height,
        _mode = BitmapMode.clip {
    _pixels = [];
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        final pixel = image.getPixel(x, y);
        _pixels.add(Color(
          pixel.r / 255.0,
          pixel.g / 255.0,
          pixel.b / 255.0,
          pixel.a / 255.0,
        ));
      }
    }
  }

  // TODO: add construcotor/convert to and from img

  Color getColor(Vec2 pos) {
    int x = pos.x;
    int y = pos.y;

    // CLIP MODE
    if (_mode == BitmapMode.clip) {
      if (x < 0) {
        x = 0;
      } else if (x >= _width) {
        x = _width - 1;
      }

      if (y < 0) {
        y = 0;
      } else if (y >= _height) {
        y = _height - 1;
      }
    }
    // WRAP MODE
    if (_mode == BitmapMode.wrap) {
      x = ((x % _width) + _width) % _width;
      y = ((y % _height) + _height) % _height;
    }

    return _pixels[_width * y + x];
  }

  void setColor(Vec2 pos, Color color) {
    if (pos.x < 0 || pos.x >= _width || pos.y < 0 || pos.y >= _height) {
      return;
    }
    _pixels[_width * pos.y + pos.x] = color;
  }

  void drawPoint(Vec2 pos, int width, Color color) {
    int half = width ~/ 2;

    for (int y = pos.y - half; y <= pos.y + half; y++) {
      for (int x = pos.x - half; x <= pos.x + half; x++) {
        setColor(Vec2(x, y), color);
      }
    }
  }

  void drawLine(Vec2 from, Vec2 to, int width, Color color) {
    for (double t = 0.0; t <= 1.0; t += 0.001) {
      int x = (from.x + t * (to.x - from.x)).toInt();
      int y = (from.y + t * (to.y - from.y)).toInt();
      drawPoint(Vec2(x, y), width, color);
    }
  }

  // TODO: add colorize method to convert to colors? RGB to A or ? other channel

  void clip(int channels, ClipMode mode, double value, Color replacement) {
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        Color currentColor = getColor(Vec2(x, y));
        bool shouldReplace = false;

        if (channels & colorR != 0) {
          if (mode == ClipMode.clipBelow && currentColor.r < value)
            shouldReplace = true;
          if (mode == ClipMode.clipAbove && currentColor.r > value)
            shouldReplace = true;
        }

        if (channels & colorG != 0) {
          if (mode == ClipMode.clipBelow && currentColor.g < value)
            shouldReplace = true;
          if (mode == ClipMode.clipAbove && currentColor.g > value)
            shouldReplace = true;
        }

        if (channels & colorB != 0) {
          if (mode == ClipMode.clipBelow && currentColor.b < value)
            shouldReplace = true;
          if (mode == ClipMode.clipAbove && currentColor.b > value)
            shouldReplace = true;
        }

        if (shouldReplace) setColor(Vec2(x, y), replacement);
      }
    }
  }

  void erase(Bitmap mask) {
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        Color currentColor = getColor(Vec2(x, y));
        Color maskColor = mask.getColor(Vec2(x, y));

        Color newColor = Color(
          (currentColor.r - maskColor.r).clamp(0.0, 1.0),
          (currentColor.g - maskColor.g).clamp(0.0, 1.0),
          (currentColor.b - maskColor.b).clamp(0.0, 1.0),
          (currentColor.a - (maskColor.r + maskColor.g + maskColor.b) / 3)
              .clamp(0.0, 1.0),
        );

        setColor(Vec2(x, y), newColor);
      }
    }
  }

  void mix(Bitmap other, MixMode mode) {
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        Color currentColor = getColor(Vec2(x, y));
        Color otherColor = other.getColor(Vec2(x, y));

        Color newColor = currentColor;

        if (mode == MixMode.normal) {
          newColor = Color(
            (currentColor.r * (1 - otherColor.a) + otherColor.r * otherColor.a)
                .clamp(0.0, 1.0),
            (currentColor.g * (1 - otherColor.a) + otherColor.g * otherColor.a)
                .clamp(0.0, 1.0),
            (currentColor.b * (1 - otherColor.a) + otherColor.b * otherColor.a)
                .clamp(0.0, 1.0),
            (currentColor.a * (1 - otherColor.a) + otherColor.a)
                .clamp(0.0, 1.0),
          );
        }

        setColor(Vec2(x, y), newColor);
      }
    }
  }

  void colorTransfer(int source, int destination) {
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        Color c = getColor(Vec2(x, y));

        double value = 0.0;
        int count = 0;
        if (source & colorR != 0) {
          value += c.r;
          count++;
        }
        if (source & colorG != 0) {
          value += c.g;
          count++;
        }
        if (source & colorB != 0) {
          value += c.b;
          count++;
        }
        if (source & colorA != 0) {
          value += c.a;
          count++;
        }
        if (count > 0) value /= count;

        if (destination & colorR != 0) c.r = value;
        if (destination & colorG != 0) c.g = value;
        if (destination & colorB != 0) c.b = value;
        if (destination & colorA != 0) c.a = value;

        setColor(Vec2(x, y), c);
      }
    }
  }

  Bitmap map(Mapping mapping) {
    Bitmap result = Bitmap(_width, _height);
    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        result.setColor(Vec2(x, y), mapping.getValueAt(Vec2(x, y)));
      }
    }
    return result;
  }

  Bitmap convolve(Bitmap kernel) {
    Bitmap result = Bitmap(_width, _height);

    int kHalfW = kernel._width ~/ 2;
    int kHalfH = kernel._height ~/ 2;

    for (int y = 0; y < _height; y++) {
      for (int x = 0; x < _width; x++) {
        double r = 0, g = 0, b = 0, a = 0;

        for (int ky = 0; ky < kernel._height; ky++) {
          for (int kx = 0; kx < kernel._width; kx++) {
            Color pixel = getColor(Vec2(x + kx - kHalfW, y + ky - kHalfH));
            Color weight = kernel.getColor(Vec2(kx, ky));

            r += pixel.r * weight.r;
            g += pixel.g * weight.r;
            b += pixel.b * weight.r;
            a += pixel.a * weight.r;
          }
        }

        result.setColor(
            Vec2(x, y),
            Color(
              r.clamp(0.0, 1.0),
              g.clamp(0.0, 1.0),
              b.clamp(0.0, 1.0),
              a.clamp(0.0, 1.0),
            ));
      }
    }

    return result;
  }

  // TODO add blit (into this, also rect source and source bitmap)

  // TODO: add map() for mapping the image, distortions, etc.

  // TODO: add perlin noise generation, etc. functions
}
