import 'package:flutter_test/flutter_test.dart';
import 'package:medimate/features/fever/domain/temperature_context.dart';

void main() {
  test('classifies general adult temperature context', () {
    expect(TemperatureContext.fromCelsius(35.8).band, TemperatureBand.low);
    expect(TemperatureContext.fromCelsius(37).band, TemperatureBand.typical);
    expect(TemperatureContext.fromCelsius(37.6).band, TemperatureBand.elevated);
    expect(TemperatureContext.fromCelsius(38).band, TemperatureBand.feverRange);
    expect(TemperatureContext.fromCelsius(39.4).band, TemperatureBand.high);
  });
}
