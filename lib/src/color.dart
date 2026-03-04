class Color {
  Color(this.r, this.g, this.b, this.a);

  double r;
  double g;
  double b;
  double a;

  // TODO: add hsv constructor and also methods to convert into
  Color.fromRGB(double r, double g, double b)
      : this.r = r,
        this.g = g,
        this.b = b,
        this.a = 1.0;

  Color.fromR(double r)
      : this.r = r,
        this.g = 0,
        this.b = 0,
        this.a = 1.0;

  Color.fromG(double g)
      : this.r = 0,
        this.g = g,
        this.b = 0,
        this.a = 1.0;

  Color.fromB(double b)
      : this.r = 0,
        this.g = 0,
        this.b = b,
        this.a = 1.0;

  Color.fromA(double a)
      : this.r = 0,
        this.g = 0,
        this.b = 0,
        this.a = a;

  Color.fromHSV(double h, double s, double v)
      : this.r = _hsvR(h, s, v),
        this.g = _hsvG(h, s, v),
        this.b = _hsvB(h, s, v),
        this.a = 1.0;

  static double _hsvR(double h, double s, double v) {
    double c = v * s;
    double x = c * (1 - ((h / 60) % 2 - 1).abs());
    double m = v - c;
    if (h < 60) return c + m;
    if (h < 120) return x + m;
    if (h < 180) return m;
    if (h < 240) return m;
    if (h < 300) return x + m;
    return c + m;
  }

  static double _hsvG(double h, double s, double v) {
    double c = v * s;
    double x = c * (1 - ((h / 60) % 2 - 1).abs());
    double m = v - c;
    if (h < 60) return x + m;
    if (h < 120) return c + m;
    if (h < 180) return c + m;
    if (h < 240) return x + m;
    if (h < 300) return m;
    return m;
  }

  static double _hsvB(double h, double s, double v) {
    double c = v * s;
    double x = c * (1 - ((h / 60) % 2 - 1).abs());
    double m = v - c;
    if (h < 60) return m;
    if (h < 120) return m;
    if (h < 180) return x + m;
    if (h < 240) return c + m;
    if (h < 300) return c + m;
    return x + m;
  }
}
