import 'package:flutter/material.dart';

import '../theme/pawlum_tokens.dart';

class PawlumSkeleton extends StatelessWidget {
  const PawlumSkeleton({
    required this.width,
    required this.height,
    this.borderRadius = PawlumRadii.control,
    this.semanticLabel = 'Loading',
    super.key,
  });

  final double width;
  final double height;
  final double borderRadius;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: PawlumColors.outline.withValues(alpha: 0.52),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

enum PawlumStatus { draft, synced, pending, failed, deleted }

class PawlumStatusBadge extends StatelessWidget {
  const PawlumStatusBadge({required this.status, this.label, super.key});

  final PawlumStatus status;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final visual = _StatusVisual.from(status);
    final resolvedLabel = label ?? visual.label;

    return Semantics(
      label: resolvedLabel,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: visual.background,
          borderRadius: BorderRadius.circular(PawlumRadii.round),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PawlumSpacing.sm,
            vertical: PawlumSpacing.xxs,
          ),
          child: ExcludeSemantics(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(visual.icon, size: 14, color: visual.foreground),
                const SizedBox(width: PawlumSpacing.xxs),
                Text(
                  resolvedLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: visual.foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusVisual {
  const _StatusVisual({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  factory _StatusVisual.from(PawlumStatus status) {
    return switch (status) {
      PawlumStatus.draft => const _StatusVisual(
        label: 'Draft',
        icon: Icons.edit_note_rounded,
        background: Color(0xFFFFF3C4),
        foreground: PawlumColors.yellowStrong,
      ),
      PawlumStatus.synced => const _StatusVisual(
        label: 'Synced',
        icon: Icons.cloud_done_rounded,
        background: PawlumColors.mint,
        foreground: Color(0xFF285C45),
      ),
      PawlumStatus.pending => const _StatusVisual(
        label: 'Pending sync',
        icon: Icons.cloud_upload_rounded,
        background: Color(0xFFECE4FA),
        foreground: PawlumColors.purpleStrong,
      ),
      PawlumStatus.failed => const _StatusVisual(
        label: 'Sync failed',
        icon: Icons.error_outline_rounded,
        background: Color(0xFFF9DEDC),
        foreground: Color(0xFF8C1D18),
      ),
      PawlumStatus.deleted => const _StatusVisual(
        label: 'Recently deleted',
        icon: Icons.restore_from_trash_rounded,
        background: PawlumColors.paperMuted,
        foreground: PawlumColors.inkMuted,
      ),
    };
  }

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
}
