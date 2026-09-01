import '../../../../shared/utils/date_helpers.dart';
import 'app_location.dart';
import 'guest_selection.dart';
import 'stay_dates.dart';

/// Why a search cannot be performed yet.
enum SearchValidationError {
  missingLocation,
  missingDates,
  incompleteDates,
  invalidDateOrder,
  invalidGuests;

  String get message {
    switch (this) {
      case SearchValidationError.missingLocation:
        return 'Choose where you are going';
      case SearchValidationError.missingDates:
        return 'Add your check-in and check-out dates';
      case SearchValidationError.incompleteDates:
        return 'Add a check-out date';
      case SearchValidationError.invalidDateOrder:
        return 'Check-out must be after check-in';
      case SearchValidationError.invalidGuests:
        return 'At least one adult is required';
    }
  }
}

/// Everything the traveller has selected. This is the single source of truth
/// that the whole search flow reads from and writes to.
class SearchCriteria {
  const SearchCriteria({
    this.location,
    this.dates = const StayDates.empty(),
    this.guests = const GuestSelection(),
    this.entirePlaceOnly = false,
  });

  final AppLocation? location;
  final StayDates dates;
  final GuestSelection guests;

  /// Mirrors the "Show entire villas & apartments" toggle.
  final bool entirePlaceOnly;

  SearchCriteria copyWith({
    AppLocation? location,
    StayDates? dates,
    GuestSelection? guests,
    bool? entirePlaceOnly,
  }) {
    return SearchCriteria(
      location: location ?? this.location,
      dates: dates ?? this.dates,
      guests: guests ?? this.guests,
      entirePlaceOnly: entirePlaceOnly ?? this.entirePlaceOnly,
    );
  }

  /// Returns the first blocking problem, or `null` when the search is valid.
  SearchValidationError? validate() {
    if (location == null) return SearchValidationError.missingLocation;
    if (!dates.hasCheckIn) return SearchValidationError.missingDates;
    if (!dates.isComplete) return SearchValidationError.incompleteDates;
    if (!dates.checkOut!.isAfter(dates.checkIn!)) {
      return SearchValidationError.invalidDateOrder;
    }
    if (!guests.isValid) return SearchValidationError.invalidGuests;
    return null;
  }

  bool get canSearch => validate() == null;

  int get nights => dates.nights;

  /// `Goa` - used by the listings header.
  String get locationLabel => location?.city ?? 'Where are you going?';

  /// `11 Sep - 17 Sep · 2 guests`
  String get summaryLine {
    final List<String> parts = <String>[
      if (dates.isComplete) dates.rangeLabel,
      guests.shortSummary,
    ];
    return parts.join(' · ');
  }

  /// `11 Sep - 17 Sep, 6 nights` (falls back gracefully when incomplete).
  String get datesLabel {
    if (dates.isComplete) {
      return '${dates.rangeLabel}, ${dates.nightsLabel}';
    }
    if (dates.hasCheckIn) {
      return '${DateHelpers.shortDay(dates.checkIn!)} - Add check-out';
    }
    return 'Add dates';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SearchCriteria &&
          other.location == location &&
          other.dates == dates &&
          other.guests == guests &&
          other.entirePlaceOnly == entirePlaceOnly);

  @override
  int get hashCode => Object.hash(location, dates, guests, entirePlaceOnly);

  @override
  String toString() =>
      'SearchCriteria(${location?.city}, ${dates.rangeLabel}, ${guests.summary})';
}
