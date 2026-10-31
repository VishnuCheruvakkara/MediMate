enum TemperatureUnit { celsius, fahrenheit }

extension TemperatureUnitX on TemperatureUnit {
  String get symbol => this == TemperatureUnit.celsius ? '°C' : '°F';

  double displayValue(double celsius) =>
      this == TemperatureUnit.celsius ? celsius : (celsius * 9 / 5) + 32;

  double toCelsius(double value) =>
      this == TemperatureUnit.celsius ? value : (value - 32) * 5 / 9;

  String format(double celsius) {
    return '${displayValue(celsius).toStringAsFixed(1)}$symbol';
  }
}
