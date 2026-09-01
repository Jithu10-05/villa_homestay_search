import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_spacing.dart';
import '../../../search/domain/models/search_criteria.dart';
import '../../domain/models/property.dart';
import '../../domain/models/property_sort.dart';
import '../providers/listings_providers.dart';
import '../widgets/property_card.dart';
import '../widgets/search_summary_header.dart';
import '../widgets/sort_bar.dart';

/// Results for the search the traveller submitted on the home screen.
class PropertyListingsScreen extends ConsumerWidget {
  const PropertyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SearchCriteria? criteria = ref.watch(submittedSearchProvider);

    if (criteria == null) {
      // Defensive: the screen is only reachable after a valid search.
      return Scaffold(
        appBar: AppBar(title: const Text('Stays')),
        body: const Center(child: Text('Start a search to see stays here.')),
      );
    }

    final AsyncValue<List<Property>> results =
        ref.watch(propertyResultsProvider);
    final PropertySort sort = ref.watch(propertySortProvider);

    return Scaffold(
      body: Column(
        children: <Widget>[
          SearchSummaryHeader(
            criteria: criteria,
            onEdit: () => Navigator.of(context).maybePop(),
          ),
          SortBar(
            selected: sort,
            onSelected: (PropertySort next) =>
                ref.read(propertySortProvider.notifier).select(next),
          ),
          Expanded(
            child: results.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
              error: (Object error, StackTrace stack) => _ListingsMessage(
                icon: Icons.cloud_off_rounded,
                title: 'We could not load stays',
                message: 'Something went wrong while searching. Try again.',
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(propertySearchProvider),
              ),
              data: (List<Property> properties) {
                if (properties.isEmpty) {
                  return _ListingsMessage(
                    icon: Icons.search_off_rounded,
                    title: 'No stays match this search',
                    message: 'Try fewer guests, a different destination, or '
                        'turn off the "entire place" filter.',
                    actionLabel: 'Change search',
                    onAction: () => Navigator.of(context).maybePop(),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  itemCount: properties.length + 1,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          '${properties.length} stays in '
                          '${criteria.locationLabel}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      );
                    }
                    final Property property = properties[index - 1];
                    return PropertyCard(
                      // Keyed by id so the saved state stays with the stay
                      // when the sort order changes.
                      key: ValueKey<String>(property.id),
                      property: property,
                      nights: criteria.nights,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared empty / error presentation for the results area.
class _ListingsMessage extends StatelessWidget {
  const _ListingsMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 46, color: AppColors.inkFaint),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
