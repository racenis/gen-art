import 'color.dart';
import 'vec2.dart';

enum BitmapMode {
    wrap, clip
}

class Bitmap {

    // TODO: add bitmap mode to constructor
    Bitmap(int width, int height) : _width = width, _height = height {
        assert(_width > 0 && _height > 0);

        int pixcount = _width * _height;

        _pixels = [];
        for (int i = 0; i < pixcount; i++) {
            _pixels.add(Color(0, 0, 0, 0));
        }
    }

    // TODO: add construcotor/convert to and from img

    Color getColor(Vec2 pos) {
        assert(pos.x >= 0 && pos.x < _width);
        assert(pos.y >= 0 && pos.y < _height);
        // TODO: add wrapping depending on bitmap mode
        // clip -- select nearest pixel on image
        // wrap -- use mod to map coords into local coords

        return _pixels[_width * pos.y + pos.x];
    }

    void setColor(Vec2 pos, Color color) {
        assert(pos.x >= 0 && pos.x < _width);
        assert(pos.y >= 0 && pos.y < _height);

        _pixels[_width * pos.y + pos.x] = color;
    }

    // TODO: add drawLine(from, to, width) and drawPoint(pos, width) methods

    // TODO: add colorize method to convert to colors? RGB to A or ? other channel

    // TODO: add clip(mode/abovebelow, value, replacecolor)

    // TODO: add erase (use bitmap to erase ointo this one)

    // TODO add blit (into this, also rect source and source bitmap)

    // TODO: add map() for mapping the image, distortions, etc.

    // TODO: add perlin noise generation, etc. functions

    final int _width;
    final int _height;
    late List<Color> _pixels;
}