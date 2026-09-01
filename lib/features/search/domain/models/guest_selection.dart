/// Who is travelling: adults, children (with ages) and pets.
class GuestSelection {
  const GuestSelection({
    this.adults = 2,
    this.childrenAges = const <int>[],
    this.pets = 0,
  });

  final int adults;

  /// One entry per child, holding that child's age in years (0-17).
  final List<int> childrenAges;
  final int pets;

  static const int minAdults = 1;
  static const int maxAdults = 16;
  static const int maxChildren = 10;
  static const int maxPets = 5;
  static const int maxChildAge = 17;

  int get children => childrenAges.length;
  int get totalGuests => adults + children;

  bool get isValid =>
      adults >= minAdults &&
      adults <= maxAdults &&
      children <= maxChildren &&
      pets >= 0 &&
      pets <= maxPets &&
      childrenAges.every((int age) => age >= 0 && age <= maxChildAge);

  /// `2 adults · 1 child · 1 pet`
  String get summary {
    final List<String> parts = <String>[
      _plural(adults, 'adult', 'adults'),
      if (children > 0) _plural(children, 'child', 'children'),
      if (pets > 0) _plural(pets, 'pet', 'pets'),
    ];
    return parts.join(' · ');
  }

  /// `3 guests` - the compact form used in headers.
  String get shortSummary => _plural(totalGuests, 'guest', 'guests');

  static String _plural(int count, String one, String many) =>
      '$count ${count == 1 ? one : many}';

  GuestSelection copyWith({
    int? adults,
    List<int>? childrenAges,
    int? pets,
  }) {
    return GuestSelection(
      adults: adults ?? this.adults,
      childrenAges: childrenAges ?? this.childrenAges,
      pets: pets ?? this.pets,
    );
  }

  GuestSelection incrementAdults() =>
      copyWith(adults: (adults + 1).clamp(minAdults, maxAdults));

  GuestSelection decrementAdults() =>
      copyWith(adults: (adults - 1).clamp(minAdults, maxAdults));

  /// Adds a child with a default age; ignored once [maxChildren] is reached.
  GuestSelection addChild({int age = 8}) {
    if (children >= maxChildren) return this;
    return copyWith(childrenAges: <int>[...childrenAges, age]);
  }

  GuestSelection removeLastChild() {
    if (childrenAges.isEmpty) return this;
    return copyWith(
      childrenAges: childrenAges.sublist(0, childrenAges.length - 1),
    );
  }

  GuestSelection updateChildAge(int index, int age) {
    if (index < 0 || index >= childrenAges.length) return this;
    final List<int> next = <int>[...childrenAges];
    next[index] = age.clamp(0, maxChildAge);
    return copyWith(childrenAges: next);
  }

  GuestSelection incrementPets() =>
      copyWith(pets: (pets + 1).clamp(0, maxPets));

  GuestSelection decrementPets() =>
      copyWith(pets: (pets - 1).clamp(0, maxPets));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GuestSelection) return false;
    if (other.adults != adults || other.pets != pets) return false;
    if (other.childrenAges.length != childrenAges.length) return false;
    for (int i = 0; i < childrenAges.length; i++) {
      if (other.childrenAges[i] != childrenAges[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(adults, pets, Object.hashAll(childrenAges));

  @override
  String toString() => 'GuestSelection($summary)';
}
