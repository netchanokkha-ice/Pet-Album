import 'package:flutter/material.dart';

import '../theme/pawlum_tokens.dart';
import '../theme/pawlum_typography.dart';

class PawlumPetPlaceholder extends StatelessWidget {
  const PawlumPetPlaceholder({
    required this.semanticLabel,
    this.size = 96,
    this.icon = Icons.pets_rounded,
    super.key,
  });

  final String semanticLabel;
  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: PawlumColors.pinkSoft,
            borderRadius: BorderRadius.circular(size * 0.34),
            border: Border.all(color: PawlumColors.pink),
          ),
          child: Icon(icon, size: size * 0.42, color: PawlumColors.pinkStrong),
        ),
      ),
    );
  }
}

class PawlumPolaroidCard extends StatelessWidget {
  const PawlumPolaroidCard({
    required this.media,
    required this.caption,
    this.semanticLabel,
    this.rotation = 0,
    this.onTap,
    super.key,
  });

  final Widget media;
  final String caption;
  final String? semanticLabel;
  final double rotation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      decoration: BoxDecoration(
        color: PawlumColors.paper,
        borderRadius: BorderRadius.circular(PawlumRadii.control),
        boxShadow: PawlumShadows.paper,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(aspectRatio: 4 / 3, child: media),
          ),
          const SizedBox(height: PawlumSpacing.sm),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: PawlumTypography.handwritten(
              fontSize: 18,
              color: PawlumColors.ink,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label: semanticLabel ?? caption,
      image: true,
      button: onTap != null,
      child: Transform.rotate(
        angle: rotation,
        child: onTap == null
            ? card
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(PawlumRadii.control),
                  child: card,
                ),
              ),
      ),
    );
  }
}
