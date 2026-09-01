import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_spacing.dart';
import '../../../../shared/utils/date_helpers.dart';
import '../../../../shared/widgets/sheet_scaffold.dart';
import '../../domain/models/stay_dates.dart';
import 'calendar_month.dart';

/// Bottom sheet that lets the traveller pick a check-in / check-out range on a
/// hand-built calendar.
///
/// Returns the chosen [StayDates] via [Navigator.pop], or `null` if dismissed.
class DateRangeSheet extends StatefulWidget {
  const DateRangeSheet({required this.initialSelection, super.key});

  final StayDates initialSelection;

  /// Number of months the traveller can browse forward.
  static const int monthsAhead = 18;

  static Future<StayDates?> show(
    BuildContext context, {
    required StayDates initialSelection,
  }) {
    return showModalBottomSheet<StayDates>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (BuildContext context) =>
          DateRangeSheet(initialSelection: initialSelection),
    );
  }

  @override
  State<DateRangeSheet> createState() => _DateRangeSheetState();
}

class _DateRangeSheetState extends State<DateRangeSheet> {
  late StayDates _selection = widget.initialSelection;
  late final DateTime _today = DateHelpers.today();
  late final DateTime _firstMonth = DateTime(_today.year, _today.month);
  late final PageController _controller =
      PageController(initialPage: _initialPage);
  late int _pageIndex = _initialPage;

  int get _initialPage {
    final DateTime? checkIn = widget.initialSelection.checkIn;
    if (checkIn == null) return 0;
    final int offset = DateHelpers.monthsBetween(_firstMonth, checkIn);
    return offset.clamp(0, DateRangeSheet.monthsAhead - 1);
  }

  DateTime _monthAt(int index) =>
      DateTime(_firstMonth.year, _firstMonth.month + index);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index < 0 || index >= DateRangeSheet.monthsAhead) return;
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  void _onDaySelected(DateTime day) {
    setState(() => _selection = _selection.select(day));
  }

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: 'Select dates',
      footer: _Footer(
        selection: _selection,
        onClear: _selection.hasCheckIn
            ? () => setState(() => _selection = const StayDates.empty())
            : null,
        onDone: _selection.isComplete
            ? () => Navigator.of(context).pop(_selection)
            : null,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _MonthNavigator(
              title: DateHelpers.monthTitle(_monthAt(_pageIndex)),
              canGoBack: _pageIndex > 0,
              canGoForward: _pageIndex < DateRangeSheet.monthsAhead - 1,
              onBack: () => _goToPage(_pageIndex - 1),
              onForward: () => _goToPage(_pageIndex + 1),
            ),
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double cellWidth = constraints.maxWidth / 7;
                final double cellHeight = (cellWidth * 0.95).clamp(38.0, 56.0);
                // Weekday header + six rows keeps the page height stable while
                // swiping between months of different lengths. The header
                // allowance follows the text scale so large font settings do
                // not overflow the page.
                final double headerHeight =
                    MediaQuery.textScalerOf(context).scale(12) + 20;
                final double pageHeight = headerHeight + cellHeight * 6;

                return SizedBox(
                  height: pageHeight,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: DateRangeSheet.monthsAhead,
                    onPageChanged: (int index) =>
                        setState(() => _pageIndex = index),
                    itemBuilder: (BuildContext context, int index) {
                      return CalendarMonth(
                        month: _monthAt(index),
                        selection: _selection,
                        firstSelectableDay: _today,
                        onDaySelected: _onDaySelected,
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            const _Hint(),
          ],
        ),
      ),
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.title,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final String title;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: canGoBack ? onBack : null,
          icon: const Icon(Icons.chevron_left_rounded),
          tooltip: 'Previous month',
          color: AppColors.primary,
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          onPressed: canGoForward ? onForward : null,
          icon: const Icon(Icons.chevron_right_rounded),
          tooltip: 'Next month',
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(Icons.info_outline_rounded,
            size: 16, color: AppColors.inkFaint),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Tap once for check-in, then a later date for check-out. '
            'Tapping an earlier date starts a new range.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.selection,
    required this.onDone,
    this.onClear,
  });

  final StayDates selection;
  final VoidCallback? onDone;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _DateSummaryBox(
                label: 'CHECK-IN',
                value: selection.checkIn == null
                    ? '-'
                    : DateHelpers.longDay(selection.checkIn!),
                isActive: !selection.hasCheckIn,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                selection.isComplete ? selection.nightsLabel : '-',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            Expanded(
              child: _DateSummaryBox(
                label: 'CHECK-OUT',
                value: selection.checkOut == null
                    ? '-'
                    : DateHelpers.longDay(selection.checkOut!),
                isActive: selection.hasCheckIn && !selection.isComplete,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            if (onClear != null) ...<Widget>[
              TextButton(onPressed: onClear, child: const Text('Clear')),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: ElevatedButton(
                onPressed: onDone,
                child: const Text('DONE'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateSummaryBox extends StatelessWidget {
  const _DateSummaryBox({
    required this.label,
    required this.value,
    required this.isActive,
  });

  final String label;
  final String value;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primarySoft : AppColors.surface,
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
        ),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.inkFaint,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
