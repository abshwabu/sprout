class Plant {
  final String id;
  final String name;
  final String species;
  final int wateringIntervalDays;
  final DateTime lastWatered;

  Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.wateringIntervalDays,
    required this.lastWatered,
  });

  Plant copyWith({
    String? id,
    String? name,
    String? species,
    int? wateringIntervalDays,
    DateTime? lastWatered,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      wateringIntervalDays: wateringIntervalDays ?? this.wateringIntervalDays,
      lastWatered: lastWatered ?? this.lastWatered,
    );
  }
}
