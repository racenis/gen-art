import 'package:flutter/material.dart';
import 'package:gen_art/gen_art.dart' hide Color;
import 'package:image/image.dart' as img;
import 'dart:math';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pattern Viewer',
      home: const PatternViewerPage(),
    );
  }
}

typedef PatternFn = Bitmap Function(List<double> params, int w, int h);

class PatternDef {
  final String name;
  final PatternFn fn;
  final List<String> paramNames;
  const PatternDef(this.name, this.fn, this.paramNames);
}

final List<PatternDef> patterns = [
  PatternDef('Hexagons', generateHexagons, [
    'Hue 1',
    'Hue 2',
    'Cell size',
    'Border',
    'Saturation',
  ]),
  PatternDef('Herringbone', generateHerringbone, [
    'Hue 1',
    'Hue 2',
    'Brick size',
    'Color ratio',
    'Saturation',
  ]),
  PatternDef('Chevron', generateChevron, [
    'Hue 1',
    'Hue 2',
    'Scale',
    'Saturation',
  ]),
  PatternDef('Bricks', generateBricks, [
    'Hue 1',
    'Hue 2',
    'Brick W',
    'Brick H',
    'Mortar',
    'Saturation',
  ]),
  PatternDef('Crossstitch', generateCrossstitch, [
    'Hue 1',
    'Hue 2',
    'Scale',
    'Thickness',
    'Saturation',
  ]),
  PatternDef('Meander', generateMeander, [
    'Hue 1',
    'Hue 2',
    'Tile size',
    'Saturation',
  ]),
  PatternDef('Checkerboard', generateCheckerboard, [
    'Hue 1',
    'Hue 2',
    'Cell size',
    'Saturation',
  ]),
  PatternDef('Grid', generateGrid, [
    'Hue 1',
    'Hue 2',
    'Cell size',
    'Line thickness',
    'Saturation',
  ]),
  PatternDef('Concentric Squares', generateConcentricSquares, [
    'Hue 1',
    'Hue 2',
    'Cell size',
    'Ring thickness',
    'Saturation',
  ]),
  PatternDef('Hatching', generateHatching, [
    'Hue 1',
    'Hue 2',
    'Spacing',
    'Thickness',
    'Crosshatch',
    'Saturation',
  ]),
];

class PatternViewerPage extends StatefulWidget {
  const PatternViewerPage({super.key});

  @override
  State<PatternViewerPage> createState() => _PatternViewerPageState();
}

class _PatternViewerPageState extends State<PatternViewerPage> {
  int _selectedIndex = 0;
  late List<double> _params;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _params = List.filled(patterns[0].paramNames.length, 0.5);
    _regenerate();
  }

  void _regenerate() {
    final def = patterns[_selectedIndex];
    final bmp = def.fn(List.from(_params), 300, 300);
    final bytes = img.encodePng(bmp.toImage());
    setState(() => _imageBytes = Uint8List.fromList(bytes));
  }

  void _randomize() {
    final rng = Random();
    setState(() {
      _params = List.generate(
        patterns[_selectedIndex].paramNames.length,
        (_) => rng.nextDouble(),
      );
    });
    _regenerate();
  }

  @override
  Widget build(BuildContext context) {
    final def = patterns[_selectedIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Pattern Viewer')),
      body: Row(
        children: [
          Expanded(
            child: Center(
              child: _imageBytes == null
                  ? const CircularProgressIndicator()
                  : Image.memory(_imageBytes!, width: 300, height: 300),
            ),
          ),
          const VerticalDivider(),
          SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButton<int>(
                    value: _selectedIndex,
                    isExpanded: true,
                    items: [
                      for (int i = 0; i < patterns.length; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(patterns[i].name),
                        ),
                    ],
                    onChanged: (i) {
                      if (i == null) return;
                      setState(() {
                        _selectedIndex = i;
                        _params = List.filled(
                          patterns[i].paramNames.length,
                          0.5,
                        );
                      });
                      _regenerate();
                    },
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      children: [
                        for (int i = 0; i < def.paramNames.length; i++)
                          _ParamSlider(
                            label: def.paramNames[i],
                            value: _params[i],
                            onChanged: (v) {
                              setState(() => _params[i] = v);
                              _regenerate();
                            },
                          ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _randomize,
                    child: const Text('Randomize'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParamSlider extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _ParamSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_ParamSlider> createState() => _ParamSliderState();
}

class _ParamSliderState extends State<_ParamSlider> {
  late TextEditingController _controller;

  bool get _isHue => widget.label.toLowerCase().contains('hue');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(2));
  }

  @override
  void didUpdateWidget(_ParamSlider old) {
    super.didUpdateWidget(old);
    final parsed = double.tryParse(_controller.text);
    if (parsed == null || (parsed - widget.value).abs() > 0.001) {
      _controller.text = widget.value.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          if (_isHue) ...[
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: _hueToColor(widget.value),
                border: Border.all(color: Colors.black26),
              ),
            ),
            const SizedBox(width: 4),
          ] else
            const SizedBox(width: 18),

          SizedBox(
            width: 90,
            child: Text(
              widget.label,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Expanded(
            child: Slider(
              value: widget.value,
              min: 0,
              max: 1,
              onChanged: widget.onChanged,
            ),
          ),

          SizedBox(
            width: 52,
            child: TextField(
              controller: _controller,
              style: const TextStyle(fontSize: 11),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (text) {
                final v = double.tryParse(text);
                if (v != null) widget.onChanged(v.clamp(0.0, 1.0));
              },
            ),
          ),
        ],
      ),
    );
  }
}

Color _hueToColor(double value) {
  final h = (value * 360.0) / 60.0;
  final x = 1.0 - ((h % 2) - 1).abs();
  double r = 0, g = 0, b = 0;
  if (h < 1) {
    r = 1;
    g = x;
  } else if (h < 2) {
    r = x;
    g = 1;
  } else if (h < 3) {
    g = 1;
    b = x;
  } else if (h < 4) {
    g = x;
    b = 1;
  } else if (h < 5) {
    r = x;
    b = 1;
  } else {
    r = 1;
    b = x;
  }
  return Color.fromRGBO(
    (r * 255).round(),
    (g * 255).round(),
    (b * 255).round(),
    1.0,
  );
}
