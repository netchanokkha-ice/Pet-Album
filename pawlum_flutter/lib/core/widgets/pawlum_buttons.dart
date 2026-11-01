import 'package:flutter/material.dart';

import '../theme/pawlum_tokens.dart';

class PawlumPrimaryButton extends StatelessWidget {
  const PawlumPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final callback = isLoading ? null : onPressed;

    return Semantics(
      label: label,
      button: true,
      enabled: callback != null,
      child: SizedBox(
        height: 48,
        child: FilledButton(
          onPressed: callback,
          child: isLoading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: PawlumSpacing.xs),
                    ],
                    Flexible(child: Text(label)),
                  ],
                ),
        ),
      ),
    );
  }
}

class PawlumGhostButton extends StatelessWidget {
  const PawlumGhostButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      enabled: onPressed != null,
      child: SizedBox(
        height: 48,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.arrow_back_rounded, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: PawlumColors.pinkStrong,
            side: const BorderSide(color: PawlumColors.pinkStrong),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(PawlumRadii.control),
            ),
          ),
        ),
      ),
    );
  }
}
