import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimate/app/app.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';

class FakeFeverRepository implements FeverRepository {
  FakeFeverRepository({this.entries = const []});
  List<FeverEntry> entries;

  @override
  Future<List<FeverEntry>> listEntries() async => entries;

  @override
  Future<FeverEntry> createEntry(FeverEntryInput input) async {
    final entry = FeverEntry(
      id: 'new-entry',
      temperatureC: input.temperatureC,
      measuredAt: input.measuredAt,
      measurementMethod: input.measurementMethod,
      symptoms: input.symptoms,
      notes: input.notes,
      medicineTaken: input.medicineTaken,
    );
    entries = [entry, ...entries];
    return entry;
  }

  @override
  Future<void> deleteEntry(String id) async {
    entries = entries.where((entry) => entry.id != id).toList();
  }

  @override
  Future<FeverEntry> updateEntry(String id, FeverEntryInput input) async =>
      createEntry(input);
}

void main() {
  testWidgets('shows the empty fever tracker', (tester) async {
    await tester.pumpWidget(MediMateApp(repository: FakeFeverRepository()));
    await tester.pumpAndSettle();
    expect(find.text('Fever tracker'), findsOneWidget);
    expect(find.text('No fever readings yet'), findsOneWidget);
    expect(find.text('Add reading'), findsOneWidget);
  });

  testWidgets('validates and saves a temperature reading', (tester) async {
    final repository = FakeFeverRepository();
    await tester.pumpWidget(MediMateApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addEntryButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('temperatureField')), '38.2');
    await tester.ensureVisible(find.byKey(const Key('saveEntryButton')));
    await tester.tap(find.byKey(const Key('saveEntryButton')));
    await tester.pumpAndSettle();
    expect(find.text('38.2°C'), findsWidgets);
    expect(repository.entries, hasLength(1));
  });

  testWidgets('accepts Fahrenheit and stores normalized Celsius', (
    tester,
  ) async {
    final repository = FakeFeverRepository();
    await tester.pumpWidget(MediMateApp(repository: repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addEntryButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('temperatureUnitField')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('°F').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('temperatureField')), '100.4');
    await tester.ensureVisible(find.byKey(const Key('saveEntryButton')));
    await tester.tap(find.byKey(const Key('saveEntryButton')));
    await tester.pumpAndSettle();
    expect(repository.entries.single.temperatureC, closeTo(38, 0.01));
  });

  testWidgets('switches the latest reading between Celsius and Fahrenheit', (
    tester,
  ) async {
    final repository = FakeFeverRepository(
      entries: [
        FeverEntry(
          id: 'reading',
          temperatureC: 38,
          measuredAt: DateTime(2026, 10, 31, 19, 30),
          measurementMethod: 'oral',
          symptoms: const [],
          notes: null,
          medicineTaken: false,
        ),
      ],
    );
    await tester.pumpWidget(MediMateApp(repository: repository));
    await tester.pumpAndSettle();
    expect(find.text('38.0°C'), findsWidgets);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('latestReadingUnitTabs')),
        matching: find.text('°F'),
      ),
    );
    await tester.pump();

    expect(find.text('100.4°F'), findsOneWidget);
  });
}
