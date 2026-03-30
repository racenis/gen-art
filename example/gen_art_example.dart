import 'package:gen_art/gen_art.dart';
import 'dart:io';

void main() {
  Directory('output').createSync(recursive: true);

  const double a = 0.2;
  const double b = 0.3;
  const double sat = 0.9;

  generateCheckerboard([a, b, 0.3, sat], 512, 512)
      .savePng('output/checker.png');
  generateGrid([a, b, 0.4, 0.05, sat], 512, 512).savePng('output/grid.png');
  generateHexagons([a, b, 0.5, 0.1, sat], 512, 512).savePng('output/hex.png');
  generateBricks([a, b, 0.5, 0.4, 0.3, sat], 512, 512)
      .savePng('output/brick.png');
  generateChevron([a, b, 0.4, sat], 512, 512).savePng('output/chevron.png');
  generateHerringbone([a, b, 0.5, 0.45, sat], 512, 512)
      .savePng('output/herring.png');
  generateCrossstitch([a, b, 0.4, 0.15, sat], 512, 512)
      .savePng('output/cross.png');
  generateMeander([a, b, 0.6, sat], 512, 512).savePng('output/meander.png');
  generateConcentricSquares([a, b, 0.5, 0.2, sat], 512, 512)
      .savePng('output/concentric.png');
  generateHatching([a, b, 0.3, 0.15, 0.0, sat], 512, 512)
      .savePng('output/hatch.png');
}
