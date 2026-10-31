class FeverEntry {
  const FeverEntry({
    required this.id,
    required this.temperatureC,
    required this.measuredAt,
    required this.measurementMethod,
    required this.symptoms,
    required this.notes,
    required this.medicineTaken,
  });

  final String id;
  final double temperatureC;
  final DateTime measuredAt;
  final String measurementMethod;
  final List<String> symptoms;
  final String? notes;
  final bool medicineTaken;

  factory FeverEntry.fromJson(Map<String, dynamic> json) => FeverEntry(
    id: json['id'] as String,
    temperatureC: (json['temperature_c'] as num).toDouble(),
    measuredAt: DateTime.parse(json['measured_at'] as String).toLocal(),
    measurementMethod: json['measurement_method'] as String,
    symptoms: List<String>.from(json['symptoms'] as List<dynamic>),
    notes: json['notes'] as String?,
    medicineTaken: json['medicine_taken'] as bool,
  );
}

class FeverEntryInput {
  const FeverEntryInput({
    required this.temperatureC,
    required this.measuredAt,
    required this.measurementMethod,
    required this.symptoms,
    required this.notes,
    required this.medicineTaken,
  });

  final double temperatureC;
  final DateTime measuredAt;
  final String measurementMethod;
  final List<String> symptoms;
  final String? notes;
  final bool medicineTaken;

  Map<String, dynamic> toJson() => {
    'temperature_c': temperatureC,
    'measured_at': measuredAt.toUtc().toIso8601String(),
    'measurement_method': measurementMethod,
    'symptoms': symptoms,
    'notes': notes,
    'medicine_taken': medicineTaken,
  };
}

abstract interface class FeverRepository {
  Future<List<FeverEntry>> listEntries();
  Future<FeverEntry> createEntry(FeverEntryInput input);
  Future<FeverEntry> updateEntry(String id, FeverEntryInput input);
  Future<void> deleteEntry(String id);
}
