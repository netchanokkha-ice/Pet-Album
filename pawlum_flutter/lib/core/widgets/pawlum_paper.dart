import 'package:flutter/material.dart';

import '../theme/pawlum_tokens.dart';

class PawlumPaperBackground extends StatelessWidget {
  const PawlumPaperBackground({
    required this.child,
    this.useResponsivePadding = true,
    super.key,
  });

  final Widget child;
  final bool useResponsivePadding;

  @override
  Widget build(BuildContext context) {
    final layout = PawlumLayoutTheme.of(context);

    return ColoredBox(
      color: PawlumColors.canvas,
      child: SafeArea(
        child: Padding(
          padding: useResponsivePadding ? layout.pagePadding : EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

class PawlumWashiTape extends StatelessWidget {
  const PawlumWashiTape({
    required this.label,
    this.color = PawlumColors.purple,
    this.angle = -0.035,
    this.width = 132,
    super.key,
  });

  final String label;
  final Color color;
  final double angle;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      container: true,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          constraints: const BoxConstraints(minHeight: 32),
          padding: const EdgeInsets.symmetric(
            horizontal: PawlumSpacing.sm,
            vertical: PawlumSpacing.xxs,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: ExcludeSemantics(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: PawlumColors.ink),
            ),
          ),
        ),
      ),
    );
  }
}

class PawlumStickerLabel extends StatelessWidget {
  const PawlumStickerLabel({
    required this.label,
    this.icon,
    this.backgroundColor = PawlumColors.pinkSoft,
    this.foregroundColor = PawlumColors.pinkStrong,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: foregroundColor.withValues(alpha: 0.24)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PawlumSpacing.sm,
            vertical: PawlumSpacing.xs,
          ),
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: foregroundColor),
                  const SizedBox(width: PawlumSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: foregroundColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PawlumRibbon extends StatelessWidget {
  const PawlumRibbon({
    required this.label,
    this.color = PawlumColors.pink,
    this.foregroundColor = PawlumColors.ink,
    super.key,
  });

  final String label;
  final Color color;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      container: true,
      child: ClipPath(
        clipper: const _RibbonClipper(),
        child: ColoredBox(
          color: color,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PawlumSpacing.lg,
              vertical: PawlumSpacing.xs,
            ),
            child: ExcludeSemantics(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: foregroundColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RibbonClipper extends CustomClipper<Path> {
  const _RibbonClipper();

  @override
  Path getClip(Size size) {
    const notch = 10.0;

    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - notch, size.height / 2)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(notch, size.height / 2)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class PawlumDateStamp extends StatelessWidget {
  const PawlumDateStamp({
    required this.day,
    required this.month,
    required this.year,
    this.semanticLabel,
    super.key,
  });

  final String day;
  final String month;
  final String year;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final label = semanticLabel ?? '$day $month $year';
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(
        child: Container(
          width: 76,
          padding: const EdgeInsets.symmetric(
            horizontal: PawlumSpacing.xs,
            vertical: PawlumSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: PawlumColors.paper,
            border: Border.all(color: PawlumColors.pinkStrong, width: 1.5),
            borderRadius: BorderRadius.circular(PawlumRadii.control),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(day, style: textTheme.headlineMedium),
              Text(month.toUpperCase(), style: textTheme.labelMedium),
              Text(year, style: textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
