import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_spacing.dart';
import '../../../../app/app_theme.dart';
import '../../../../shared/widgets/section_label.dart';
import '../../domain/models/app_location.dart';
import '../providers/search_providers.dart';

/// Full screen destination search.
///
/// Pops with the chosen [AppLocation] (and also writes it into the shared
/// search criteria so the home screen updates immediately).
class LocationSearchScreen extends ConsumerStatefulWidget {
  const LocationSearchScreen({super.key});

  static Future<AppLocation?> push(BuildContext context) {
    return Navigator.of(context).push<AppLocation>(
      MaterialPageRoute<AppLocation>(
        builder: (BuildContext context) => const LocationSearchScreen(),
      ),
    );
  }

  @override
  ConsumerState<LocationSearchScreen> createState() =>
      _LocationSearchScreenState();
}

class _LocationSearchScreenState extends ConsumerState<LocationSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(AppLocation location) {
    ref.read(searchCriteriaProvider.notifier).selectLocation(location);
    ref.read(recentLocationsProvider.notifier).remember(location);
    Navigator.of(context).pop(location);
  }

  @override
  Widget build(BuildContext context) {
    final String query = ref.watch(locationQueryProvider);
    final AsyncValue<List<AppLocation>> results =
        ref.watch(locationResultsProvider);
    final List<AppLocation> recents = ref.watch(recentLocationsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _SearchBar(
              controller: _controller,
              onChanged: (String value) =>
                  ref.read(locationQueryProvider.notifier).update(value),
              onClear: () {
                _controller.clear();
                ref.read(locationQueryProvider.notifier).update('');
              },
            ),
            Expanded(
              child: _Results(
                // Previous results stay on screen while the next query loads,
                // so the list does not flash a spinner on every keystroke.
                locations: results.valueOrNull,
                hasError: results.hasError,
                query: query.trim(),
                recents: recents,
                onSelect: _select,
                onRetry: () => ref.invalidate(locationResultsProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        decoration: appInputDecoration(
          hintText: 'Just type what you want...',
          prefixIcon: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.ink,
            tooltip: 'Back',
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (BuildContext context, TextEditingValue value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
                color: AppColors.inkMuted,
                tooltip: 'Clear',
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Chooses between the loading, error, empty and result states.
class _Results extends StatelessWidget {
  const _Results({
    required this.locations,
    required this.hasError,
    required this.query,
    required this.recents,
    required this.onSelect,
    required this.onRetry,
  });

  /// `null` until the first result arrives.
  final List<AppLocation>? locations;
  final bool hasError;
  final String query;
  final List<AppLocation> recents;
  final ValueChanged<AppLocation> onSelect;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final List<AppLocation>? locations = this.locations;

    if (locations == null) {
      if (hasError) return _ErrorState(onRetry: onRetry);
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      );
    }

    if (query.isEmpty) {
      return _BrowseList(
        recents: recents,
        all: locations,
        onSelect: onSelect,
      );
    }

    if (locations.isEmpty) return _EmptyState(query: query);

    return ListView(
      children: <Widget>[
        SectionLabel(text: '${locations.length} destinations'),
        ...locations.map(
          (AppLocation location) => _LocationTile(
            location: location,
            icon: Icons.place_outlined,
            onTap: () => onSelect(location),
          ),
        ),
      ],
    );
  }
}

/// Default view: recent picks first, then popular, then everything else.
class _BrowseList extends StatelessWidget {
  const _BrowseList({
    required this.recents,
    required this.all,
    required this.onSelect,
  });

  final List<AppLocation> recents;
  final List<AppLocation> all;
  final ValueChanged<AppLocation> onSelect;

  @override
  Widget build(BuildContext context) {
    final List<AppLocation> popular =
        all.where((AppLocation location) => location.isPopular).toList();
    final List<AppLocation> others =
        all.where((AppLocation location) => !location.isPopular).toList();

    return ListView(
      children: <Widget>[
        if (recents.isNotEmpty) ...<Widget>[
          const SectionLabel(text: 'Recent searches'),
          ...recents.map(
            (AppLocation location) => _LocationTile(
              location: location,
              icon: Icons.history_rounded,
              onTap: () => onSelect(location),
            ),
          ),
        ],
        const SectionLabel(text: 'Popular searches'),
        ...popular.map(
          (AppLocation location) => _LocationTile(
            location: location,
            icon: Icons.trending_up_rounded,
            iconColor: AppColors.success,
            onTap: () => onSelect(location),
          ),
        ),
        if (others.isNotEmpty) ...<Widget>[
          const SectionLabel(text: 'More destinations'),
          ...others.map(
            (AppLocation location) => _LocationTile(
              location: location,
              icon: Icons.place_outlined,
              onTap: () => onSelect(location),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.location,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.inkMuted,
  });

  final AppLocation location;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: iconColor),
      title: Text(
        location.city,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        location.region == null
            ? location.country
            : '${location.region}, ${location.country}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: const Icon(
        Icons.north_east_rounded,
        size: 16,
        color: AppColors.inkFaint,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.travel_explore_rounded,
                size: 44, color: AppColors.inkFaint),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No destinations match "$query"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try a nearby city, for example Goa, Manali or Jaipur.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.wifi_off_rounded,
                size: 44, color: AppColors.inkFaint),
            const SizedBox(height: AppSpacing.md),
            Text(
              'We could not load destinations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
