# Villa Homestay Search

A modern villa & homestay search experience built with Flutter, Dart and Riverpod.
This first version runs entirely on **mock data** - there is no backend and no
network access - but the layers are separated so a real API can be plugged in
without touching the UI.

## Run it

```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Android: `flutter run -d <device-id>` (or pick the device in your IDE).

## The flow

```
Home search  →  Location search  →  Date range sheet  →  Guest sheet  →  SEARCH  →  Listings
```

Selections live in a single Riverpod `SearchCriteria` state, so every screen and
sheet reads and writes the same source of truth and the home screen always
reflects the current choices.

## Features

- **Home search card** - destination, check-in / check-out, guests, an "entire
  place" toggle and a prominent gradient SEARCH button.
- **Location search** - full-screen search over mock destinations with recent
  searches, popular searches and an empty state.
- **Custom calendar** - hand-built with plain Flutter widgets (no calendar
  package): past dates disabled, first tap = check-in, later tap = check-out,
  earlier tap restarts the range, live night count, DONE enabled only when the
  range is complete, month-by-month navigation.
- **Guest selection** - adults (minimum 1), children with an age per child, and
  pets, with a live `2 adults · 1 child · 1 pet` summary.
- **Listings** - compact search summary, sorting, and rich property cards with
  local illustrations, rating, reviews, tags, benefits and pricing.
- **Validation** - searching without a destination or dates shows an inline
  message and a snackbar instead of failing.

## Architecture

```
lib/
  main.dart                  ProviderScope + app entry
  app/                       theme, colours, spacing, root widget
  core/constants/            asset paths
  shared/                    date/currency helpers, reusable widgets
  features/
    search/
      domain/                AppLocation, StayDates, GuestSelection,
                             SearchCriteria, TravelCollection, repository contract
      data/                  mock destinations + mock repository
      presentation/          providers, screens, widgets
    listings/
      domain/                Property, PropertySort, repository contract
      data/                  mock stays + mock repository
      presentation/          providers, screens, widgets
```

Domain models are pure Dart (no Flutter imports) and hold the business rules -
date-range selection, night counting, guest summaries and search validation -
so they are unit-testable on their own.

## Swapping in a real API

Implement `LocationRepository` / `PropertyRepository` with your HTTP client and
override the two providers:

```dart
ProviderScope(
  overrides: [
    locationRepositoryProvider.overrideWithValue(ApiLocationRepository()),
    propertyRepositoryProvider.overrideWithValue(ApiPropertyRepository()),
  ],
  child: const VillaHomestayApp(),
);
```

Nothing in the widget layer changes.

## Images

Listings, the collections strip and the home hero show **real demo photographs**
loaded from the Unsplash CDN (`lib/core/constants/app_images.dart` plus the
`imageUrl` fields in the mock data).

Every remote photo has a bundled illustration behind it in `assets/images/`:
`RemoteImage` (`lib/shared/widgets/remote_image.dart`) shows a soft placeholder
while the photo downloads and falls back to the local asset if it fails, so the
app still looks right with no connection.

Because of this the app now needs internet access for the photos. The Android
`INTERNET` permission is declared in `android/app/src/main/AndroidManifest.xml`.
To use your own photography, swap the `imageUrl` values (or drop files into
`assets/images/` and clear the URLs).

## Tests

`flutter test` covers the logic that matters: night calculation and calendar
selection rules, guest summaries and counter limits, search validation and
labels, mock search filtering and sorting, plus a widget test of the home
screen form.
