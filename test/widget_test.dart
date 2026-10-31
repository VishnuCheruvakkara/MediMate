import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimate/app/app.dart';
import 'package:medimate/features/fever/domain/fever_entry.dart';
import 'package:medimate/features/medicines/domain/medicine.dart';

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

class FakeMedicineRepository implements MedicineRepository {
  FakeMedicineRepository({this.medicines = const []});
  List<Medicine> medicines;

  @override
  Future<List<Medicine>> listMedicines() async => medicines;

  @override
  Future<Medicine> createMedicine(MedicineInput input) async {
    final medicine = Medicine(
      id: 'new-medicine',
      name: input.name,
      dosage: input.dosage,
      instructions: input.instructions,
      isActive: input.isActive,
      schedules: input.schedules,
    );
    medicines = [medicine, ...medicines];
    return medicine;
  }

  @override
  Future<void> deleteMedicine(String id) async {
    medicines = medicines.where((medicine) => medicine.id != id).toList();
  }

  @override
  Future<Medicine> updateMedicine(String id, MedicineInput input) async {
    final updated = Medicine(
      id: id,
      name: input.name,
      dosage: input.dosage,
      instructions: input.instructions,
      isActive: input.isActive,
      schedules: input.schedules,
    );
    medicines = medicines
        .map((item) => item.id == id ? updated : item)
        .toList();
    return updated;
  }
}

void main() {
  testWidgets('shows the empty fever tracker', (tester) async {
    await tester.pumpWidget(
      MediMateApp(
        repository: FakeFeverRepository(),
        medicineRepository: FakeMedicineRepository(),
        initialIndex: 1,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Fever tracker'), findsOneWidget);
    expect(find.text('No fever readings yet'), findsOneWidget);
    expect(find.text('Add reading'), findsOneWidget);
  });

  testWidgets('validates and saves a temperature reading', (tester) async {
    final repository = FakeFeverRepository();
    await tester.pumpWidget(
      MediMateApp(
        repository: repository,
        medicineRepository: FakeMedicineRepository(),
        initialIndex: 1,
      ),
    );
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
    await tester.pumpWidget(
      MediMateApp(
        repository: repository,
        medicineRepository: FakeMedicineRepository(),
        initialIndex: 1,
      ),
    );
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
    await tester.pumpWidget(
      MediMateApp(
        repository: repository,
        medicineRepository: FakeMedicineRepository(),
        initialIndex: 1,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('38.0°C'), findsWidgets);
    expect(find.text('Fever-range reading'), findsOneWidget);
    expect(
      find.byKey(const Key('temperatureContextIndicator')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('latestReadingUnitTabs')),
        matching: find.text('°F'),
      ),
    );
    await tester.pump();

    expect(find.text('100.4°F'), findsOneWidget);
  });

  testWidgets('shows medicine management as the default tab', (tester) async {
    await tester.pumpWidget(
      MediMateApp(
        repository: FakeFeverRepository(),
        medicineRepository: FakeMedicineRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My medicines'), findsOneWidget);
    expect(find.text('No medicines added'), findsOneWidget);
    expect(find.text('Add medicine'), findsOneWidget);
  });

  testWidgets('requires a dose time before saving medicine', (tester) async {
    final repository = FakeMedicineRepository();
    await tester.pumpWidget(
      MediMateApp(
        repository: FakeFeverRepository(),
        medicineRepository: repository,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addMedicineButton')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('medicineNameField')),
      'Vitamin D',
    );
    await tester.enterText(
      find.byKey(const Key('medicineDosageField')),
      '1 tablet',
    );
    await tester.ensureVisible(find.byKey(const Key('saveMedicineButton')));
    await tester.tap(find.byKey(const Key('saveMedicineButton')));
    await tester.pump();

    expect(find.text('Add at least one dose time'), findsOneWidget);
    expect(repository.medicines, isEmpty);
  });
}
