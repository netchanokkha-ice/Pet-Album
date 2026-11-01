import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/pawlum_tokens.dart';
import '../../../../core/widgets/pawlum_widgets.dart';
import '../../../memory_authoring/domain/entities/memory_models.dart';
import '../../../memory_authoring/presentation/controllers/memory_lifecycle_controller.dart';
import '../../domain/entities/timeline_models.dart';
import '../controllers/timeline_controller.dart';

class TimelineView extends GetView<TimelineController> {
  const TimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    final lifecycle = Get.isRegistered<MemoryLifecycleController>()
        ? Get.find<MemoryLifecycleController>()
        : null;
    return Obx(() {
      final lifecycleLoading = lifecycle?.isLoading.value ?? false;
      if ((controller.isLoading.value || lifecycleLoading) &&
          controller.entries.isEmpty) {
        return const Center(
          child: PawlumSkeleton(
            width: 300,
            height: 360,
            semanticLabel: 'Loading timeline',
          ),
        );
      }
      if (controller.errorMessage.value case final message?
          when controller.entries.isEmpty) {
        return _TimelineMessage(
          icon: Icons.cloud_off_rounded,
          title: 'Timeline unavailable',
          message: message,
          action: PawlumPrimaryButton(
            label: 'Try again',
            onPressed: controller.loadFirstPage,
          ),
        );
      }

      if (MediaQuery.orientationOf(context) == Orientation.landscape &&
          controller.entries.isNotEmpty) {
        return _LandscapeTimeline(controller: controller);
      }

      return KeyedSubtree(
        key: const Key('timeline-portrait-layout'),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification.depth == 0) {
              controller.maybeLoadMore(notification.metrics.extentAfter);
            }
            return false;
          },
          child: CustomScrollView(
            key: const PageStorageKey<String>('portrait-timeline-scroll'),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _PetTimelineHeader(controller: controller),
              ),
              if (controller.entries.isEmpty)
                SliverToBoxAdapter(
                  child: _TimelineMessage(
                    icon: Icons.auto_stories_rounded,
                    title: 'No memories here yet',
                    message:
                        'Add a favorite moment and ${controller.petName.value}’s scrapbook will begin here.',
                    action: PawlumPrimaryButton(
                      label: 'Add a memory',
                      icon: Icons.add_photo_alternate_rounded,
                      onPressed: () => unawaited(controller.addMemory()),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(
                    top: PawlumSpacing.lg,
                    bottom: PawlumSpacing.xxl,
                  ),
                  sliver: SliverList.list(
                    children: <Widget>[
                      for (final group in controller.groups)
                        _TimelineMonthSection(group: group),
                      if (controller.isLoadingMore.value)
                        const _NextPageLoading(),
                      if (controller.pageErrorMessage.value case final message?)
                        _NextPageError(
                          message: message,
                          onRetry: controller.loadNextPage,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _LandscapeTimeline extends StatelessWidget {
  const _LandscapeTimeline({required this.controller});

  final TimelineController controller;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final group in controller.groups) {
      children
        ..add(_LandscapeMonthMarker(group: group))
        ..addAll(
          group.entries.map(
            (TimelineEntry entry) => _LandscapeMemoryCard(entry: entry),
          ),
        );
    }
    if (controller.isLoadingMore.value) {
      children.add(const _LandscapeNextPageLoading());
    }
    if (controller.pageErrorMessage.value case final message?) {
      children.add(
        SizedBox(
          width: 300,
          child: Center(
            child: _NextPageError(
              message: message,
              onRetry: controller.loadNextPage,
            ),
          ),
        ),
      );
    }
    return KeyedSubtree(
      key: const Key('timeline-landscape-layout'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 168,
            child: _LandscapePetRail(controller: controller),
          ),
          const SizedBox(width: PawlumSpacing.lg),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification.depth == 0) {
                  controller.maybeLoadMore(notification.metrics.extentAfter);
                }
                return false;
              },
              child: ListView.separated(
                key: const PageStorageKey<String>('landscape-timeline-scroll'),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: PawlumSpacing.xs),
                itemCount: children.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: PawlumSpacing.md),
                itemBuilder: (_, int index) => children[index],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandscapePetRail extends StatelessWidget {
  const _LandscapePetRail({required this.controller});

  final TimelineController controller;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: '${controller.petName.value} memory scrapbook',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PawlumColors.paper,
          borderRadius: BorderRadius.circular(16),
          boxShadow: PawlumShadows.paper,
        ),
        child: Padding(
          padding: const EdgeInsets.all(PawlumSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _PetAvatar(
                name: controller.petName.value,
                path: controller.petImagePath.value,
                size: 56,
              ),
              const SizedBox(height: PawlumSpacing.xs),
              Text(
                controller.petName.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                'Memory scrapbook',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: PawlumSpacing.sm),
              IconButton.filledTonal(
                tooltip: 'Add a memory for ${controller.petName.value}',
                onPressed: () => unawaited(controller.addMemory()),
                icon: const Icon(Icons.add_photo_alternate_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LandscapeMonthMarker extends StatelessWidget {
  const _LandscapeMonthMarker({required this.group});

  final TimelineMonthGroup group;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: PawlumColors.pinkStrong,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: PawlumSpacing.sm),
          Text(
            _monthName(group.month),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            group.year.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _LandscapeMemoryCard extends StatelessWidget {
  const _LandscapeMemoryCard({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final isDraft = entry.draftIndicator == TimelineDraftIndicator.draft;
    final lifecycle = Get.isRegistered<MemoryLifecycleController>()
        ? Get.find<MemoryLifecycleController>()
        : null;
    final memory = lifecycle?.activeMemory(entry.memoryId);
    return SizedBox(
      width: 320,
      child: Semantics(
        label: switch (entry.draftIndicator) {
          TimelineDraftIndicator.draft =>
            'Draft memory, ${entry.title}, tap to continue',
          TimelineDraftIndicator.editDraft =>
            'Published memory, ${entry.title}, unpublished edits available',
          TimelineDraftIndicator.none => 'Published memory, ${entry.title}',
        },
        button: true,
        child: Material(
          color: isDraft ? const Color(0xFFFFF7D9) : PawlumColors.paper,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => unawaited(controller.open(entry)),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(PawlumSpacing.sm),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: PawlumShadows.paper,
              ),
              child: Row(
                children: <Widget>[
                  SizedBox(width: 104, child: _MemoryCover(entry: entry)),
                  const SizedBox(width: PawlumSpacing.sm),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                '${entry.memoryDate.day} ${_monthName(entry.memoryDate.month).substring(0, 3)} ${entry.memoryDate.year}',
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                            if (memory != null)
                              IconButton(
                                tooltip: 'Delete ${entry.title}',
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints.tightFor(
                                  width: 36,
                                  height: 36,
                                ),
                                onPressed: () => unawaited(
                                  _confirmDelete(context, lifecycle!, memory),
                                ),
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                ),
                              ),
                            if (entry.draftIndicator ==
                                TimelineDraftIndicator.editDraft)
                              IconButton(
                                tooltip: 'Resume edits for ${entry.title}',
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints.tightFor(
                                  width: 36,
                                  height: 36,
                                ),
                                onPressed: () =>
                                    unawaited(controller.resume(entry)),
                                icon: const Icon(
                                  Icons.edit_note_rounded,
                                  size: 18,
                                ),
                              ),
                          ],
                        ),
                        if (isDraft) ...<Widget>[
                          const SizedBox(height: PawlumSpacing.xs),
                          const PawlumStatusBadge(
                            status: PawlumStatus.draft,
                            label: 'Draft',
                          ),
                        ] else if (entry.draftIndicator ==
                            TimelineDraftIndicator.editDraft) ...<Widget>[
                          const SizedBox(height: PawlumSpacing.xs),
                          const PawlumStatusBadge(
                            status: PawlumStatus.pending,
                            label: 'Unpublished edits',
                          ),
                        ],
                        const SizedBox(height: PawlumSpacing.xs),
                        Text(
                          entry.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (entry.caption?.trim() case final caption?
                            when caption.isNotEmpty) ...<Widget>[
                          const SizedBox(height: PawlumSpacing.xxs),
                          Text(
                            caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TimelineController get controller => Get.find<TimelineController>();

  Future<void> _confirmDelete(
    BuildContext context,
    MemoryLifecycleController controller,
    MemoryAggregate memory,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          memory.isFirstMemory ? 'Delete first memory?' : 'Delete memory?',
        ),
        content: Text(controller.deleteWarning(memory)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Move to Recently Deleted'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final deleted = await controller.softDelete(memory);
    if (!deleted || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Memory moved to Recently Deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => unawaited(controller.undoLastDelete()),
        ),
      ),
    );
  }
}

class _PetTimelineHeader extends StatelessWidget {
  const _PetTimelineHeader({required this.controller});

  final TimelineController controller;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: '${controller.petName.value} memory scrapbook',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: PawlumColors.paper,
          borderRadius: BorderRadius.circular(16),
          boxShadow: PawlumShadows.paper,
        ),
        child: Padding(
          padding: const EdgeInsets.all(PawlumSpacing.md),
          child: Row(
            children: <Widget>[
              _PetAvatar(
                name: controller.petName.value,
                path: controller.petImagePath.value,
              ),
              const SizedBox(width: PawlumSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      controller.petName.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: PawlumSpacing.xxs),
                    Text(
                      'Memory scrapbook',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: PawlumColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Add a memory for ${controller.petName.value}',
                onPressed: () => unawaited(controller.addMemory()),
                icon: const Icon(Icons.add_photo_alternate_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  const _PetAvatar({required this.name, required this.path, this.size = 72});

  final String name;
  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imagePath = path;
    if (imagePath == null || imagePath.isEmpty) {
      return PawlumPetPlaceholder(
        semanticLabel: '$name profile placeholder',
        size: size,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        File(imagePath),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => PawlumPetPlaceholder(
          semanticLabel: '$name profile photo unavailable',
          size: size,
        ),
      ),
    );
  }
}

class _TimelineMonthSection extends StatelessWidget {
  const _TimelineMonthSection({required this.group});

  final TimelineMonthGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PawlumSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: PawlumColors.pinkStrong,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: PawlumSpacing.sm),
              Text(
                '${_monthName(group.month)} ${group.year}',
                key: ValueKey<String>('month-${group.year}-${group.month}'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          const SizedBox(height: PawlumSpacing.md),
          for (var index = 0; index < group.entries.length; index++)
            _TimelineRailItem(
              entry: group.entries[index],
              isLast: index == group.entries.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineRailItem extends StatelessWidget {
  const _TimelineRailItem({required this.entry, required this.isLast});

  final TimelineEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 34,
            child: Column(
              children: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: PawlumSpacing.lg),
                  decoration: BoxDecoration(
                    color: entry.draftIndicator == TimelineDraftIndicator.draft
                        ? PawlumColors.yellowStrong
                        : PawlumColors.pinkStrong,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 1, color: PawlumColors.outline),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: PawlumSpacing.md),
              child: _TimelineMemoryCard(entry: entry),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineMemoryCard extends StatelessWidget {
  const _TimelineMemoryCard({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final isDraft = entry.draftIndicator == TimelineDraftIndicator.draft;
    final lifecycle = Get.isRegistered<MemoryLifecycleController>()
        ? Get.find<MemoryLifecycleController>()
        : null;
    final memory = lifecycle?.activeMemory(entry.memoryId);
    return Semantics(
      label: _semanticLabel,
      button: true,
      child: Material(
        color: isDraft ? const Color(0xFFFFF7D9) : PawlumColors.paper,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: InkWell(
          onTap: () => unawaited(Get.find<TimelineController>().open(entry)),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: PawlumShadows.paper,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _MemoryCover(entry: entry),
                Padding(
                  padding: const EdgeInsets.all(PawlumSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          PawlumDateStamp(
                            day: entry.memoryDate.day.toString().padLeft(
                              2,
                              '0',
                            ),
                            month: _monthName(
                              entry.memoryDate.month,
                            ).substring(0, 3),
                            year: entry.memoryDate.year.toString(),
                          ),
                          const SizedBox(width: PawlumSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (isDraft)
                                  const PawlumStatusBadge(
                                    status: PawlumStatus.draft,
                                    label: 'Draft — tap to continue',
                                  )
                                else if (entry.draftIndicator ==
                                    TimelineDraftIndicator.editDraft)
                                  const PawlumStatusBadge(
                                    status: PawlumStatus.pending,
                                    label: 'Unpublished edits',
                                  ),
                                if (entry.draftIndicator !=
                                    TimelineDraftIndicator.none)
                                  const SizedBox(height: PawlumSpacing.xs),
                                Text(
                                  entry.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                          if (memory != null)
                            IconButton(
                              tooltip: 'Delete ${entry.title}',
                              onPressed: () => unawaited(
                                _confirmDelete(context, lifecycle!, memory),
                              ),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                        ],
                      ),
                      if (entry.caption?.trim() case final caption?
                          when caption.isNotEmpty) ...<Widget>[
                        const SizedBox(height: PawlumSpacing.sm),
                        Text(
                          caption,
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: PawlumColors.inkMuted,
                                height: 1.45,
                              ),
                        ),
                      ],
                      if (entry.draftIndicator ==
                          TimelineDraftIndicator.editDraft) ...<Widget>[
                        const SizedBox(height: PawlumSpacing.sm),
                        TextButton.icon(
                          onPressed: () => unawaited(
                            Get.find<TimelineController>().resume(entry),
                          ),
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text('Resume edits'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _semanticLabel => switch (entry.draftIndicator) {
    TimelineDraftIndicator.draft =>
      'Draft memory, ${entry.title}, tap to continue',
    TimelineDraftIndicator.editDraft =>
      'Published memory, ${entry.title}, unpublished edits available',
    TimelineDraftIndicator.none => 'Published memory, ${entry.title}',
  };

  Future<void> _confirmDelete(
    BuildContext context,
    MemoryLifecycleController controller,
    MemoryAggregate memory,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          memory.isFirstMemory ? 'Delete first memory?' : 'Delete memory?',
        ),
        content: Text(controller.deleteWarning(memory)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Move to Recently Deleted'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final deleted = await controller.softDelete(memory);
    if (!deleted || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Memory moved to Recently Deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => unawaited(controller.undoLastDelete()),
        ),
      ),
    );
  }
}

class _MemoryCover extends StatelessWidget {
  const _MemoryCover({required this.entry});

  final TimelineEntry entry;

  @override
  Widget build(BuildContext context) {
    final path = entry.coverObjectPath;
    if (path == null || path.isEmpty) {
      return const _MediaFallback(
        label: 'No photo for this memory',
        icon: Icons.photo_album_outlined,
      );
    }
    final uri = Uri.tryParse(path);
    final isRemote =
        uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    if (!isRemote && !File(path).existsSync()) {
      return const _MediaFallback(
        label: 'Memory photo unavailable',
        icon: Icons.broken_image_outlined,
      );
    }
    final image = isRemote
        ? Image.network(path, fit: BoxFit.cover, errorBuilder: _mediaError)
        : Image.file(File(path), fit: BoxFit.cover, errorBuilder: _mediaError);
    return Semantics(
      label: '${entry.title} cover photo',
      image: true,
      child: AspectRatio(aspectRatio: 16 / 9, child: image),
    );
  }

  static Widget _mediaError(
    BuildContext context,
    Object error,
    StackTrace? stack,
  ) {
    return const _MediaFallback(
      label: 'Memory photo unavailable',
      icon: Icons.broken_image_outlined,
    );
  }
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(
        child: ColoredBox(
          color: PawlumColors.paperMuted,
          child: SizedBox(
            height: 152,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(icon, color: PawlumColors.inkMuted, size: 36),
                  const SizedBox(height: PawlumSpacing.xs),
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimelineMessage extends StatelessWidget {
  const _TimelineMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: PawlumSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              PawlumPetPlaceholder(semanticLabel: title, icon: icon, size: 88),
              const SizedBox(height: PawlumSpacing.lg),
              Text(title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: PawlumSpacing.xs),
              Text(message, textAlign: TextAlign.center),
              if (action != null) ...<Widget>[
                const SizedBox(height: PawlumSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NextPageError extends StatelessWidget {
  const _NextPageError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Row(
      children: <Widget>[
        const Icon(Icons.cloud_off_rounded, color: PawlumColors.pinkStrong),
        const SizedBox(width: PawlumSpacing.sm),
        Expanded(child: Text(message)),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    ),
  );
}

class _NextPageLoading extends StatelessWidget {
  const _NextPageLoading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: PawlumSpacing.lg),
    child: Center(
      child: PawlumSkeleton(
        width: 220,
        height: 88,
        semanticLabel: 'Loading more memories',
      ),
    ),
  );
}

class _LandscapeNextPageLoading extends StatelessWidget {
  const _LandscapeNextPageLoading();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 220,
    child: Center(
      child: PawlumSkeleton(
        width: 180,
        height: 120,
        semanticLabel: 'Loading more memories',
      ),
    ),
  );
}

String _monthName(int month) => const <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
][month - 1];
