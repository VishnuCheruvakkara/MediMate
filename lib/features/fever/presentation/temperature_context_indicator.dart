import 'package:flutter/material.dart';
import 'package:medimate/features/fever/domain/temperature_context.dart';

class TemperatureContextIndicator extends StatelessWidget {
  const TemperatureContextIndicator({super.key, required this.temperatureC});

  final double temperatureC;

  @override
  Widget build(BuildContext context) {
    final temperatureContext = TemperatureContext.fromCelsius(temperatureC);
    final accent = _colorFor(temperatureContext.band);
    return Container(
      key: const Key('temperatureContextIndicator'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  temperatureContext.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF173F39),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Text(
                'Adult guide',
                style: TextStyle(
                  color: Color(0xFF5E6F6A),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TemperatureMap(temperatureC: temperatureC),
          const SizedBox(height: 10),
          Text(
            temperatureContext.description,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: const Color(0xFF42534E)),
          ),
          const SizedBox(height: 4),
          Text(
            'Temperature varies by person, age, time, and measurement method. This is context, not a diagnosis.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: const Color(0xFF6A7A75), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _TemperatureMap extends StatelessWidget {
  const _TemperatureMap({required this.temperatureC});

  final double temperatureC;

  @override
  Widget build(BuildContext context) {
    final position = ((temperatureC.clamp(35, 40.5) - 35) / 5.5);
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final markerLeft = (constraints.maxWidth - 12) * position;
            return SizedBox(
              height: 20,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    top: 6,
                    bottom: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const Row(
                        children: [
                          Expanded(child: ColoredBox(color: Color(0xFF69A8D9))),
                          Expanded(child: ColoredBox(color: Color(0xFF62B989))),
                          Expanded(child: ColoredBox(color: Color(0xFFF0B957))),
                          Expanded(child: ColoredBox(color: Color(0xFFE67A62))),
                          Expanded(child: ColoredBox(color: Color(0xFFC84E57))),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: markerLeft,
                    child: Container(
                      width: 12,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF173F39),
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '35°C',
              style: TextStyle(fontSize: 10, color: Color(0xFF6A7A75)),
            ),
            Text(
              '38°C',
              style: TextStyle(fontSize: 10, color: Color(0xFF6A7A75)),
            ),
            Text(
              '40.5°C',
              style: TextStyle(fontSize: 10, color: Color(0xFF6A7A75)),
            ),
          ],
        ),
      ],
    );
  }
}

Color _colorFor(TemperatureBand band) => switch (band) {
  TemperatureBand.low => const Color(0xFF3D8DC2),
  TemperatureBand.typical => const Color(0xFF2E9A62),
  TemperatureBand.elevated => const Color(0xFFD99625),
  TemperatureBand.feverRange => const Color(0xFFD85F48),
  TemperatureBand.high => const Color(0xFFB92F42),
};
