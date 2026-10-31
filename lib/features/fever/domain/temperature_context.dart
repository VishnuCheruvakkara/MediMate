enum TemperatureBand { low, typical, elevated, feverRange, high }

class TemperatureContext {
  const TemperatureContext({
    required this.band,
    required this.label,
    required this.description,
  });

  final TemperatureBand band;
  final String label;
  final String description;

  static TemperatureContext fromCelsius(double temperature) {
    if (temperature < 36.1) {
      return const TemperatureContext(
        band: TemperatureBand.low,
        label: 'Below typical range',
        description: 'This is below the general adult reference range.',
      );
    }
    if (temperature <= 37.2) {
      return const TemperatureContext(
        band: TemperatureBand.typical,
        label: 'Typical adult range',
        description: 'This falls within a commonly cited adult range.',
      );
    }
    if (temperature < 38) {
      return const TemperatureContext(
        band: TemperatureBand.elevated,
        label: 'Elevated reading',
        description:
            'Above the typical range but below the general fever threshold.',
      );
    }
    if (temperature < 39.4) {
      return const TemperatureContext(
        band: TemperatureBand.feverRange,
        label: 'Fever-range reading',
        description:
            '38°C (100.4°F) or higher is generally considered a fever.',
      );
    }
    return const TemperatureContext(
      band: TemperatureBand.high,
      label: 'High fever-range reading',
      description:
          'For adults, 39.4°C (103°F) or higher warrants medical advice.',
    );
  }
}
