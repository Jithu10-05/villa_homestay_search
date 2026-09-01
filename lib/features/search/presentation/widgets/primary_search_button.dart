import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_spacing.dart';

/// The prominent gradient call-to-action on the home search card.
class PrimarySearchButton extends StatelessWidget {
  const PrimarySearchButton({
    required this.label,
    required this.onPressed,
    this.enabled = true,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  /// When false the button keeps a muted look but stays tappable, so the
  /// traveller still gets told what is missing.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Ink(
            height: 52,
            decoration: BoxDecoration(
              gradient: enabled ? AppColors.primaryGradient : null,
              color: enabled ? null : AppColors.border,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: enabled
                  ? const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x3D1266E3),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: enabled ? Colors.white : AppColors.inkFaint,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
