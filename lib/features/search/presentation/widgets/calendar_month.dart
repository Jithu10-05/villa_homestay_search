import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_spacing.dart';
import '../../../../shared/utils/date_helpers.dart';
import '../../domain/models/stay_dates.dart';

/// One month of a hand-built calendar grid.
///
/// Deliberately implemented with plain Flutter widgets - no calendar package.
class CalendarMonth extends StatelessWidget {
  const CalendarMonth({
    required this.month,
    required this.selection,
    required this.firstSelectableDay,
    required this.onDaySelected,
    super.key,
  });

  /// Any date inside the month being rendered.
  final DateTime month;
  final StayDates selection;

  /// Days before this are shown disabled.
  final DateTime firstSelectableDay;
  final ValueChanged<DateTime> onDaySelected;

  static const List<String> _weekdayLabels = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final int year = month.year;
    final int monthNumber = month.month;
    final int totalDays = DateHelpers.daysInMonth(year, monthNumber);

    // DateTime.weekday: Monday = 1 ... Sunday = 7.
    final int leadingBlanks = DateTime(year, monthNumber, 1).weekday - 1;
    final int cellCount = leadingBlanks + totalDays;
    final int rows = (cellCount / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: _weekdayLabels
              .map(
                (String label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double cellWidth = constraints.maxWidth / 7;
            final double cellHeight = (cellWidth * 0.95).clamp(38.0, 56.0);

            return Column(
              children: List<Widget>.generate(rows, (int row) {
                return SizedBox(
                  height: cellHeight,
                  child: Row(
                    children: List<Widget>.generate(7, (int column) {
                      final int index = row * 7 + column;
                      final int dayNumber = index - leadingBlanks + 1;
                      if (dayNumber < 1 || dayNumber > totalDays) {
                        return const Expanded(child: SizedBox.shrink());
                      }
                      return Expanded(
                        child: _DayCell(
                          date: DateTime(year, monthNumber, dayNumber),
                          selection: selection,
                          firstSelectableDay: firstSelectableDay,
                          onSelected: onDaySelected,
                        ),
                      );
                    }),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.selection,
    required this.firstSelectableDay,
    required this.onSelected,
  });

  final DateTime date;
  final StayDates selection;
  final DateTime firstSelectableDay;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = date.isBefore(firstSelectableDay);
    final bool isCheckIn = selection.isCheckIn(date);
    final bool isCheckOut = selection.isCheckOut(date);
    final bool isBetween = selection.isBetween(date);
    final bool isEdge = isCheckIn || isCheckOut;
    final bool isToday = DateHelpers.isSameDay(date, DateHelpers.today());

    // The soft band that connects the two ends of the range.
    BorderRadius? bandRadius;
    if (isCheckIn && isCheckOut) {
      bandRadius = BorderRadius.circular(AppRadius.pill);
    } else if (isCheckIn) {
      bandRadius = const BorderRadius.horizontal(
        left: Radius.circular(AppRadius.pill),
      );
    } else if (isCheckOut) {
      bandRadius = const BorderRadius.horizontal(
        right: Radius.circular(AppRadius.pill),
      );
    }

    final bool showBand = isBetween || (isEdge && selection.isComplete);

    return Semantics(
      button: !isDisabled,
      selected: isEdge,
      label: DateHelpers.longDay(date),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (showBand)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: bandRadius,
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkResponse(
                onTap: isDisabled ? null : () => onSelected(date),
                radius: 24,
                child: Center(
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isEdge ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isEdge
                          ? Border.all(color: AppColors.primary, width: 1.2)
                          : null,
                    ),
                    // Scales the label down instead of overflowing when the
                    // device uses a large text size.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight:
                                  isEdge ? FontWeight.w700 : FontWeight.w500,
                              color: isDisabled
                                  ? AppColors.inkFaint.withValues(alpha: 0.55)
                                  : isEdge
                                      ? Colors.white
                                      : AppColors.ink,
                            ),
                          ),
                          if (isEdge)
                            Text(
                              isCheckIn ? 'in' : 'out',
                              style: const TextStyle(
                                fontSize: 8.5,
                                height: 1,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
