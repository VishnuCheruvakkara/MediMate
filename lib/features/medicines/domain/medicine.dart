class MedicineSchedule {
  const MedicineSchedule({
    this.id,
    required this.timeOfDay,
    this.intervalDays = 1,
  });

  final String? id;
  final String timeOfDay;
  final int intervalDays;

  factory MedicineSchedule.fromJson(Map<String, dynamic> json) {
    return MedicineSchedule(
      id: json['id'] as String?,
      timeOfDay: json['time_of_day'] as String,
      intervalDays: json['interval_days'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'time_of_day': timeOfDay,
    'interval_days': intervalDays,
  };
}

class Medicine {
  const Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.isActive,
    required this.schedules,
  });

  final String id;
  final String name;
  final String dosage;
  final String? instructions;
  final bool isActive;
  final List<MedicineSchedule> schedules;

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: json['id'] as String,
    name: json['name'] as String,
    dosage: json['dosage'] as String,
    instructions: json['instructions'] as String?,
    isActive: json['is_active'] as bool,
    schedules: (json['schedules'] as List<dynamic>)
        .map((item) => MedicineSchedule.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class MedicineInput {
  const MedicineInput({
    required this.name,
    required this.dosage,
    required this.instructions,
    required this.isActive,
    required this.schedules,
  });

  final String name;
  final String dosage;
  final String? instructions;
  final bool isActive;
  final List<MedicineSchedule> schedules;

  Map<String, dynamic> toCreateJson() => {
    'name': name,
    'dosage': dosage,
    'instructions': instructions,
    'schedules': schedules.map((schedule) => schedule.toJson()).toList(),
  };

  Map<String, dynamic> toUpdateJson() => {
    ...toCreateJson(),
    'is_active': isActive,
  };
}

abstract interface class MedicineRepository {
  Future<List<Medicine>> listMedicines();
  Future<Medicine> createMedicine(MedicineInput input);
  Future<Medicine> updateMedicine(String id, MedicineInput input);
  Future<void> deleteMedicine(String id);
}
