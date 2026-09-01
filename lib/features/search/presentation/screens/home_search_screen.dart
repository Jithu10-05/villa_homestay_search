import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_spacing.dart';
import '../../../../app/app_theme.dart';
import '../../../../shared/utils/date_helpers.dart';
import '../../../listings/presentation/providers/listings_providers.dart';
import '../../../listings/presentation/screens/property_listings_screen.dart';
import '../../domain/models/guest_selection.dart';
import '../../domain/models/search_criteria.dart';
import '../../domain/models/stay_dates.dart';
import '../providers/search_providers.dart';
import '../widgets/collections_section.dart';
import '../widgets/date_range_sheet.dart';
import '../widgets/guest_selection_sheet.dart';
import '../widgets/hero_header.dart';
import '../widgets/primary_search_button.dart';
import '../widgets/search_field_tile.dart';
import 'location_search_screen.dart';

/// Entry screen of the flow: destination, dates, guests and the search button.
class HomeSearchScreen extends ConsumerStatefulWidget {
  const HomeSearchScreen({super.key});

  @override
  ConsumerState<HomeSearchScreen> createState() => _HomeSearchScreenState();
}

class _HomeSearchScreenState extends ConsumerState<HomeSearchScreen> {
  /// Set once the traveller presses SEARCH with something missing, so the
  /// form only turns "red" after an actual attempt.
  SearchValidationError? _error;

  static const double _heroHeight = 250;
  static const double _cardOverlap = 46;

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _pickLocation() async {
    await LocationSearchScreen.push(context);
    if (!mounted) return;
    _clearError();
  }

  Future<void> _pickDates() async {
    final StayDates current = ref.read(searchCriteriaProvider).dates;
    final StayDates? picked = await DateRangeSheet.show(
      context,
      initialSelection: current,
    );
    if (picked == null || !mounted) return;
    ref.read(searchCriteriaProvider.notifier).setDates(picked);
    _clearError();
  }

  Future<void> _pickGuests() async {
    final GuestSelection current = ref.read(searchCriteriaProvider).guests;
    final GuestSelection? picked = await GuestSelectionSheet.show(
      context,
      initialSelection: current,
    );
    if (picked == null || !mounted) return;
    ref.read(searchCriteriaProvider.notifier).setGuests(picked);
    _clearError();
  }

  void _search() {
    final SearchCriteria criteria = ref.read(searchCriteriaProvider);
    final SearchValidationError? error = criteria.validate();

    if (error != null) {
      setState(() => _error = error);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }

    setState(() => _error = null);
    ref.read(submittedSearchProvider.notifier).submit(criteria);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const PropertyListingsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SearchCriteria criteria = ref.watch(searchCriteriaProvider);

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            const HeroHeader(height: _heroHeight),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: _heroHeight - _cardOverlap),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: _SearchCard(
                    criteria: criteria,
                    error: _error,
                    onPickLocation: _pickLocation,
                    onPickDates: _pickDates,
                    onPickGuests: _pickGuests,
                    onToggleEntirePlace: (bool value) {
                      ref
                          .read(searchCriteriaProvider.notifier)
                          .setEntirePlaceOnly(value: value);
                    },
                    onSearch: _search,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const CollectionsSection(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({
    required this.criteria,
    required this.error,
    required this.onPickLocation,
    required this.onPickDates,
    required this.onPickGuests,
    required this.onToggleEntirePlace,
    required this.onSearch,
  });

  final SearchCriteria criteria;
  final SearchValidationError? error;
  final VoidCallback onPickLocation;
  final VoidCallback onPickDates;
  final VoidCallback onPickGuests;
  final ValueChanged<bool> onToggleEntirePlace;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final StayDates dates = criteria.dates;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: kCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SearchFieldTile(
            icon: Icons.search_rounded,
            label: 'WHERE',
            value: criteria.location?.city ?? 'Where are you going?',
            hasValue: criteria.location != null,
            onTap: onPickLocation,
            trailing: criteria.location == null
                ? null
                : Text(
                    criteria.location!.country,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: SearchFieldTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'CHECK-IN',
                  value: dates.checkIn == null
                      ? 'Add date'
                      : DateHelpers.shortDay(dates.checkIn!),
                  hasValue: dates.checkIn != null,
                  onTap: onPickDates,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SearchFieldTile(
                  icon: Icons.event_available_rounded,
                  label: 'CHECK-OUT',
                  value: dates.checkOut == null
                      ? 'Add date'
                      : DateHelpers.shortDay(dates.checkOut!),
                  hasValue: dates.checkOut != null,
                  onTap: onPickDates,
                ),
              ),
            ],
          ),
          if (dates.isComplete)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.nights_stay_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    dates.nightsLabel,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          SearchFieldTile(
            icon: Icons.group_outlined,
            label: 'GUESTS',
            value: criteria.guests.summary,
            onTap: onPickGuests,
          ),
          const SizedBox(height: AppSpacing.sm),
          _EntirePlaceToggle(
            value: criteria.entirePlaceOnly,
            onChanged: onToggleEntirePlace,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.error_outline_rounded,
                      size: 16, color: AppColors.danger),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      error!.message,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          PrimarySearchButton(
            label: 'SEARCH',
            enabled: criteria.canSearch,
            onPressed: onSearch,
          ),
        ],
      ),
    );
  }
}

class _EntirePlaceToggle extends StatelessWidget {
  const _EntirePlaceToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: (bool? next) => onChanged(next ?? false),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Show entire villas & apartments',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Select for an entire place to yourself and more privacy',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
