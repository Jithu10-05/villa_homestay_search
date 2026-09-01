import 'package:flutter/material.dart';

import '../../app/app_colors.dart';
import '../../app/app_spacing.dart';

/// Keeps the app in a phone-shaped, centred column.
///
/// On a phone this is a no-op. In a desktop Chrome window it prevents the
/// screens (and the modal sheets, which live inside the same subtree) from
/// stretching across the full browser width.
class MobileShell extends StatelessWidget {
  const MobileShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isWide = constraints.maxWidth > AppSpacing.maxContentWidth;
        if (!isWide) return child;

        return ColoredBox(
          color: const Color(0xFFE8ECF3),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.maxContentWidth,
              ),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppColors.canvas,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0x1A0A1A2B),
                      blurRadius: 28,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
