import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/pawlum_tokens.dart';
import '../../../../core/widgets/pawlum_widgets.dart';
import '../../../memory_authoring/domain/entities/memory_models.dart';
import '../controllers/memory_detail_controller.dart';

class MemoryDetailView extends GetView<MemoryDetailController> {
  const MemoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final version = controller.publishedVersion;
      if (controller.unavailable.value || version == null) {
        return _UnavailableMemory(onExit: controller.exit);
      }
      final aggregate = controller.memory.value!;
      return CustomScrollView(
        key: ValueKey<String>('memory-detail-${aggregate.id}'),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Row(
              children: <Widget>[
                IconButton(
                  tooltip: 'Back to timeline',
                  onPressed: () => unawaited(controller.exit()),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: PawlumSpacing.xs),
                Expanded(
                  child: Text(
                    'Memory detail',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (aggregate.currentWorkingVersion != null)
                  PawlumGhostButton(
                    label: 'Resume editing',
                    icon: Icons.edit_note_rounded,
                    onPressed: () => unawaited(controller.resumeEdit()),
                  ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              top: PawlumSpacing.lg,
              bottom: PawlumSpacing.xxl,
            ),
            sliver: SliverList.list(
              children: <Widget>[
                _DetailMediaGallery(media: version.media),
                const SizedBox(height: PawlumSpacing.lg),
                Text(
                  version.title ?? 'Untitled memory',
                  key: const Key('memory-detail-title'),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: PawlumSpacing.sm),
                _MemoryDate(date: version.memoryDate),
                if (version.caption?.trim() case final story?
                    when story.isNotEmpty) ...<Widget>[
                  const SizedBox(height: PawlumSpacing.lg),
                  Text('Story', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: PawlumSpacing.xs),
                  Text(
                    story,
                    key: const Key('memory-detail-story'),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(height: 1.55),
                  ),
                ],
                const SizedBox(height: PawlumSpacing.lg),
                _MemoryMetadata(version: version),
                const SizedBox(height: PawlumSpacing.lg),
                _PresentationSummary(presentation: version.presentation),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _DetailMediaGallery extends StatelessWidget {
  const _DetailMediaGallery({required this.media});

  final List<MemoryMedia> media;

  @override
  Widget build(BuildContext context) {
    final active =
        media
            .where(
              (MemoryMedia item) =>
                  item.uploadState != MemoryMediaUploadState.removed,
            )
            .toList()
          ..sort(
            (MemoryMedia left, MemoryMedia right) =>
                left.sortOrder.compareTo(right.sortOrder),
          );
    if (active.isEmpty) {
      return const _DetailMediaFallback(
        label: 'This memory has no available media',
        icon: Icons.photo_album_outlined,
      );
    }
    return SizedBox(
      height: MediaQuery.orientationOf(context) == Orientation.landscape
          ? 190
          : 280,
      child: PageView.builder(
        itemCount: active.length,
        itemBuilder: (BuildContext context, int index) => Padding(
          padding: const EdgeInsets.only(right: PawlumSpacing.sm),
          child: _DetailMediaItem(media: active[index]),
        ),
      ),
    );
  }
}

class _DetailMediaItem extends StatelessWidget {
  const _DetailMediaItem({required this.media});

  final MemoryMedia media;

  @override
  Widget build(BuildContext context) {
    final path = media.thumbnailPath ?? media.sourcePath;
    if (media.type == MemoryMediaType.video && media.thumbnailPath == null) {
      return const _DetailMediaFallback(
        label: 'Video memory',
        icon: Icons.play_circle_outline_rounded,
      );
    }
    final uri = Uri.tryParse(path);
    final isRemote =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!isRemote && !File(path).existsSync()) {
      return const _DetailMediaFallback(
        label: 'Memory media unavailable',
        icon: Icons.broken_image_outlined,
      );
    }
    final image = isRemote
        ? Image.network(path, fit: BoxFit.cover, errorBuilder: _mediaError)
        : Image.file(File(path), fit: BoxFit.cover, errorBuilder: _mediaError);
    return Semantics(
      label: media.type == MemoryMediaType.video
          ? 'Video memory preview'
          : 'Memory photo',
      image: true,
      child: ClipRRect(borderRadius: BorderRadius.circular(16), child: image),
    );
  }

  static Widget _mediaError(
    BuildContext context,
    Object error,
    StackTrace? stack,
  ) => const _DetailMediaFallback(
    label: 'Memory media unavailable',
    icon: Icons.broken_image_outlined,
  );
}

class _DetailMediaFallback extends StatelessWidget {
  const _DetailMediaFallback({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    image: true,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: PawlumColors.paperMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: PawlumColors.inkMuted),
            const SizedBox(height: PawlumSpacing.xs),
            Text(label),
          ],
        ),
      ),
    ),
  );
}

class _MemoryDate extends StatelessWidget {
  const _MemoryDate({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      const Icon(Icons.calendar_today_outlined, size: 18),
      const SizedBox(width: PawlumSpacing.xs),
      Text(
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
        key: const Key('memory-detail-date'),
      ),
    ],
  );
}

class _MemoryMetadata extends StatelessWidget {
  const _MemoryMetadata({required this.version});

  final MemoryVersion version;

  @override
  Widget build(BuildContext context) {
    final values = <(IconData, String, String?)>[
      (Icons.mood_rounded, 'Mood', version.mood),
      (Icons.location_on_outlined, 'Location', version.location),
      (Icons.celebration_outlined, 'Occasion', version.occasion),
    ].where((item) => item.$3?.trim().isNotEmpty ?? false);
    if (values.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: PawlumSpacing.sm,
      runSpacing: PawlumSpacing.sm,
      children: <Widget>[
        for (final (icon, label, value) in values)
          PawlumStickerLabel(
            label: '$label: $value',
            icon: icon,
            backgroundColor: PawlumColors.paperMuted,
            foregroundColor: PawlumColors.ink,
          ),
      ],
    );
  }
}

class _PresentationSummary extends StatelessWidget {
  const _PresentationSummary({required this.presentation});

  final MemoryPresentation presentation;

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        'Presentation theme ${presentation.themeKey}, template ${presentation.templateKey}, layout ${presentation.layoutKey}',
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: PawlumColors.paper,
        borderRadius: BorderRadius.circular(14),
        boxShadow: PawlumShadows.paper,
      ),
      child: Padding(
        padding: const EdgeInsets.all(PawlumSpacing.md),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.palette_outlined,
              color: PawlumColors.purpleStrong,
            ),
            const SizedBox(width: PawlumSpacing.sm),
            Expanded(
              child: Text(
                'Presentation · ${_displayKey(presentation.themeKey)} · '
                '${_displayKey(presentation.templateKey)} · '
                '${_displayKey(presentation.layoutKey)}',
                key: const Key('memory-detail-presentation'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _UnavailableMemory extends StatelessWidget {
  const _UnavailableMemory({required this.onExit});

  final Future<void> Function() onExit;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const PawlumPetPlaceholder(
            semanticLabel: 'Memory no longer available',
            icon: Icons.auto_stories_outlined,
            size: 88,
          ),
          const SizedBox(height: PawlumSpacing.lg),
          Text(
            'Memory no longer available',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PawlumSpacing.xs),
          const Text(
            'It may have moved to Recently Deleted. Your journal is still safe.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: PawlumSpacing.lg),
          PawlumPrimaryButton(
            label: 'Back to timeline',
            icon: Icons.arrow_back_rounded,
            onPressed: () => unawaited(onExit()),
          ),
        ],
      ),
    ),
  );
}

String _displayKey(String value) => value
    .split('_')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');
