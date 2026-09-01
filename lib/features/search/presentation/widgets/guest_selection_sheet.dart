import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_spacing.dart';
import '../../../../shared/widgets/counter_control.dart';
import '../../../../shared/widgets/sheet_scaffold.dart';
import '../../domain/models/guest_selection.dart';

/// Bottom sheet for choosing adults, children (with ages) and pets.
///
/// Returns the chosen [GuestSelection] via [Navigator.pop], or `null` if the
/// sheet is dismissed without confirming.
class GuestSelectionSheet extends StatefulWidget {
  const GuestSelectionSheet({required this.initialSelection, super.key});

  final GuestSelection initialSelection;

  static Future<GuestSelection?> show(
    BuildContext context, {
    required GuestSelection initialSelection,
  }) {
    return showModalBottomSheet<GuestSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (BuildContext context) =>
          GuestSelectionSheet(initialSelection: initialSelection),
    );
  }

  @override
  State<GuestSelectionSheet> createState() => _GuestSelectionSheetState();
}

class _GuestSelectionSheetState extends State<GuestSelectionSheet> {
  late GuestSelection _guests = widget.initialSelection;

  void _update(GuestSelection next) => setState(() => _guests = next);

  @override
  Widget build(BuildContext context) {
    return SheetScaffold(
      title: 'Select guests',
      heightFactor: 0.8,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            _guests.summary,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _guests.isValid
                ? () => Navigator.of(context).pop(_guests)
                : null,
            child: const Text('DONE'),
          ),
        ],
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
            _GuestRow(
              title: 'Adults',
              subtitle: 'At least one adult is required',
              control: CounterControl(
                value: _guests.adults,
                semanticLabel: 'Adults',
                canDecrement: _guests.adults > GuestSelection.minAdults,
                canIncrement: _guests.adults < GuestSelection.maxAdults,
                onDecrement: () => _update(_guests.decrementAdults()),
                onIncrement: () => _update(_guests.incrementAdults()),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            _GuestRow(
              title: 'Children',
              subtitle: '0 - 17 years old',
              control: CounterControl(
                value: _guests.children,
                semanticLabel: 'Children',
                canDecrement: _guests.children > 0,
                canIncrement: _guests.children < GuestSelection.maxChildren,
                onDecrement: () => _update(_guests.removeLastChild()),
                onIncrement: () => _update(_guests.addChild()),
              ),
            ),
            if (_guests.children > 0) _ChildAges(
              ages: _guests.childrenAges,
              onAgeChanged: (int index, int age) =>
                  _update(_guests.updateChildAge(index, age)),
            ),
            const Divider(height: 1, color: AppColors.border),
            _GuestRow(
              title: 'Pets',
              subtitle: 'Only pet friendly stays will be shown',
              control: CounterControl(
                value: _guests.pets,
                semanticLabel: 'Pets',
                canDecrement: _guests.pets > 0,
                canIncrement: _guests.pets < GuestSelection.maxPets,
                onDecrement: () => _update(_guests.decrementPets()),
                onIncrement: () => _update(_guests.incrementPets()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuestRow extends StatelessWidget {
  const _GuestRow({
    required this.title,
    required this.subtitle,
    required this.control,
  });

  final String title;
  final String subtitle;
  final Widget control;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          control,
        ],
      ),
    );
  }
}

/// Age selector for every child added to the party.
class _ChildAges extends StatelessWidget {
  const _ChildAges({required this.ages, required this.onAgeChanged});

  final List<int> ages;
  final void Function(int index, int age) onAgeChanged;

  static String _ageLabel(int age) {
    if (age == 0) return 'Under 1';
    return age == 1 ? '1 year' : '$age years';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Tell us how old each child is so we can show the right options '
            'and prices.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...List<Widget>.generate(ages.length, (int index) {
            return Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Child ${index + 1}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: ages[index],
                        isDense: true,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        items: List<DropdownMenuItem<int>>.generate(
                          GuestSelection.maxChildAge + 1,
                          (int age) => DropdownMenuItem<int>(
                            value: age,
                            child: Text(_ageLabel(age)),
                          ),
                        ),
                        onChanged: (int? age) {
                          if (age != null) onAgeChanged(index, age);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
