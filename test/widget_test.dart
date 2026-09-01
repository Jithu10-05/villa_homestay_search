import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:villa_homestay_search/features/search/domain/models/app_location.dart';
import 'package:villa_homestay_search/features/search/domain/models/guest_selection.dart';
import 'package:villa_homestay_search/features/search/domain/models/stay_dates.dart';
import 'package:villa_homestay_search/features/search/presentation/providers/search_providers.dart';
import 'package:villa_homestay_search/app/app_theme.dart';
import 'package:villa_homestay_search/features/search/presentation/screens/home_search_screen.dart';
import 'package:villa_homestay_search/features/search/presentation/widgets/search_field_tile.dart';

/// Pumps the home screen inside a container so providers can be inspected.
Future<ProviderContainer> pumpHome(WidgetTester tester) async {
  final ProviderContainer container = ProviderContainer();
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const HomeSearchScreen(),
      ),
    ),
  );
  await tester.pump();
  return container;
}

void main() {
  testWidgets('home screen shows the empty search form', (
    WidgetTester tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Where are you going?'), findsOneWidget);
    expect(find.text('Add date'), findsNWidgets(2));
    expect(find.text('2 adults'), findsOneWidget);
    expect(find.text('SEARCH'), findsOneWidget);
  });

  testWidgets('searching without a destination shows a validation message', (
    WidgetTester tester,
  ) async {
    await pumpHome(tester);

    await tester.tap(find.text('SEARCH'));
    await tester.pump();

    expect(find.text('Choose where you are going'), findsWidgets);
  });

  testWidgets('the form reflects the shared search criteria', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = await pumpHome(tester);

    container.read(searchCriteriaProvider.notifier)
      ..selectLocation(
        const AppLocation(id: 'goa', city: 'Goa', country: 'India'),
      )
      ..setDates(
        StayDates(
          checkIn: DateTime(2026, 9, 11),
          checkOut: DateTime(2026, 9, 17),
        ),
      )
      ..setGuests(const GuestSelection(adults: 2, childrenAges: <int>[6]));
    await tester.pump();

    // "Goa" also appears on a collection card, so scope the check to the field.
    expect(
      find.descendant(
        of: find.byType(SearchFieldTile),
        matching: find.text('Goa'),
      ),
      findsOneWidget,
    );
    expect(find.text('11 Sep'), findsOneWidget);
    expect(find.text('17 Sep'), findsOneWidget);
    expect(find.text('6 nights'), findsOneWidget);
    expect(find.text('2 adults · 1 child'), findsOneWidget);
    expect(container.read(searchCriteriaProvider).canSearch, isTrue);
  });
}
