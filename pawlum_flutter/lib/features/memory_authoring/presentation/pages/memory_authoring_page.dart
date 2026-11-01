import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../../../../core/theme/pawlum_tokens.dart';
import '../../../../core/widgets/pawlum_widgets.dart';
import '../../domain/entities/memory_models.dart';
import '../controllers/memory_authoring_controller.dart';

class MemoryAuthoringPage extends GetView<MemoryAuthoringController> {
  const MemoryAuthoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingDraft.value) {
        return const Center(
          child: PawlumSkeleton(
            width: 280,
            height: 140,
            semanticLabel: 'Restoring memory draft',
          ),
        );
      }
      final current = controller.step.value;
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final wide = constraints.maxWidth >= 760;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AuthoringHeader(step: current, controller: controller),
              const SizedBox(height: PawlumSpacing.md),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: wide ? 900 : 620),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: PawlumSpacing.xl),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: KeyedSubtree(
                          key: ValueKey<MemoryAuthoringStep>(current),
                          child: _stepBody(context, current, wide),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _AuthoringError(controller: controller),
              _AuthoringNavigation(controller: controller),
            ],
          );
        },
      );
    });
  }

  Widget _stepBody(BuildContext context, MemoryAuthoringStep step, bool wide) {
    return switch (step) {
      MemoryAuthoringStep.media => _MediaStep(
        controller: controller,
        wide: wide,
      ),
      MemoryAuthoringStep.decoration => _DecorationStep(controller: controller),
      MemoryAuthoringStep.story => _StoryStep(controller: controller),
      MemoryAuthoringStep.review => _ReviewStep(controller: controller),
    };
  }
}

class _AuthoringHeader extends StatelessWidget {
  const _AuthoringHeader({required this.step, required this.controller});

  final MemoryAuthoringStep step;
  final MemoryAuthoringController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PawlumWashiTape(label: 'Craft a memory'),
        const SizedBox(height: PawlumSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                _stepTitle(step),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            Obx(
              () => controller.pendingSync.value
                  ? const PawlumStatusBadge(
                      status: PawlumStatus.pending,
                      label: 'Pending sync',
                    )
                  : const SizedBox.shrink(),
            ),
            IconButton(
              tooltip: 'Exit memory editor',
              onPressed: () => unawaited(_requestExit(context, controller)),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        const SizedBox(height: PawlumSpacing.sm),
        Semantics(
          label: 'Step ${step.index + 1} of 4, ${_stepTitle(step)}',
          child: Row(
            children: [
              for (final item in MemoryAuthoringStep.values)
                Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(
                      right: item == MemoryAuthoringStep.review
                          ? 0
                          : PawlumSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: item.index <= step.index
                          ? PawlumColors.pinkStrong
                          : PawlumColors.outline,
                      borderRadius: BorderRadius.circular(PawlumRadii.round),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MediaStep extends StatelessWidget {
  const _MediaStep({required this.controller, required this.wide});

  final MemoryAuthoringController controller;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final media = controller.mediaSelection.value.activeMedia;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Add up to three photos and one video.'),
          const SizedBox(height: PawlumSpacing.md),
          Wrap(
            spacing: PawlumSpacing.sm,
            runSpacing: PawlumSpacing.sm,
            children: [
              FilledButton.icon(
                onPressed: controller.isPicking.value
                    ? null
                    : () => unawaited(controller.addImages()),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add photos'),
              ),
              OutlinedButton.icon(
                onPressed: controller.isPicking.value
                    ? null
                    : () => unawaited(controller.addVideo()),
                icon: const Icon(Icons.video_library_outlined),
                label: const Text('Add video'),
              ),
            ],
          ),
          const SizedBox(height: PawlumSpacing.lg),
          if (media.isEmpty)
            const _PaperPanel(
              child: Column(
                children: [
                  Icon(Icons.collections_outlined, size: 44),
                  SizedBox(height: PawlumSpacing.sm),
                  Text('Your selected moments will appear here.'),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: media.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: wide ? 3 : 2,
                crossAxisSpacing: PawlumSpacing.sm,
                mainAxisSpacing: PawlumSpacing.sm,
                childAspectRatio: wide ? 1.35 : 1.05,
              ),
              itemBuilder: (BuildContext context, int index) {
                final item = media[index];
                return _MediaTile(
                  media: item,
                  onCover: () => controller.chooseCover(item.id),
                  onRemove: () => controller.removeMedia(item.id),
                );
              },
            ),
        ],
      );
    });
  }
}

class _AuthoringError extends StatelessWidget {
  const _AuthoringError({required this.controller});

  final MemoryAuthoringController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final message = controller.errorMessage.value;
      if (message == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: PawlumSpacing.sm),
        child: Semantics(
          liveRegion: true,
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    });
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.media,
    required this.onCover,
    required this.onRemove,
  });

  final MemoryMedia media;
  final VoidCallback onCover;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final fileName = path.basename(media.sourcePath);
    return Semantics(
      label: '${media.type.name} $fileName${media.isCover ? ', cover' : ''}',
      container: true,
      child: _PaperPanel(
        padding: const EdgeInsets.all(PawlumSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              media.type == MemoryMediaType.image
                  ? Icons.image_outlined
                  : Icons.play_circle_outline_rounded,
              size: 32,
            ),
            const SizedBox(height: PawlumSpacing.xs),
            Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: PawlumSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: media.isCover ? 'Current cover' : 'Make cover',
                  onPressed: media.isCover ? null : onCover,
                  icon: Icon(
                    media.isCover ? Icons.star_rounded : Icons.star_outline,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove $fileName',
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorationStep extends StatelessWidget {
  const _DecorationStep({required this.controller});

  final MemoryAuthoringController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Decoration is optional. Pawlum keeps a warm default ready for you.',
        ),
        const SizedBox(height: PawlumSpacing.lg),
        _ChoiceGroup(
          title: 'Theme',
          selected: controller.themeKey.value,
          choices: const <String, String>{
            'pawlum_default': 'Pawlum default',
            'sunny_day': 'Sunny day',
            'mint_note': 'Mint note',
          },
          onSelected: controller.setTheme,
        ),
        _ChoiceGroup(
          title: 'Template',
          selected: controller.templateKey.value,
          choices: const <String, String>{
            'classic': 'Classic',
            'postcard': 'Postcard',
            'film_strip': 'Film strip',
          },
          onSelected: controller.setTemplate,
        ),
        _ChoiceGroup(
          title: 'Layout',
          selected: controller.layoutKey.value,
          choices: const <String, String>{
            'single': 'Single',
            'grid': 'Grid',
            'stacked': 'Stacked',
          },
          onSelected: controller.setLayout,
        ),
      ],
    );
  }
}

class _ChoiceGroup extends StatelessWidget {
  const _ChoiceGroup({
    required this.title,
    required this.selected,
    required this.choices,
    required this.onSelected,
  });

  final String title;
  final String selected;
  final Map<String, String> choices;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PawlumSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: PawlumSpacing.sm),
          Wrap(
            spacing: PawlumSpacing.sm,
            runSpacing: PawlumSpacing.sm,
            children: [
              for (final entry in choices.entries)
                ChoiceChip(
                  label: Text(entry.value),
                  selected: selected == entry.key,
                  onSelected: (_) => onSelected(entry.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoryStep extends StatelessWidget {
  const _StoryStep({required this.controller});

  final MemoryAuthoringController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          key: const Key('memory-title-field'),
          initialValue: controller.title.value,
          onChanged: controller.setTitle,
          decoration: const InputDecoration(
            labelText: 'Title · optional',
            prefixIcon: Icon(Icons.title_rounded),
          ),
        ),
        const SizedBox(height: PawlumSpacing.md),
        TextFormField(
          key: const Key('memory-caption-field'),
          initialValue: controller.caption.value,
          onChanged: controller.setCaption,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Story',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: PawlumSpacing.md),
        _StoryField(
          key: const Key('memory-mood-field'),
          label: 'Mood',
          initialValue: controller.mood.value,
          onChanged: controller.setMood,
        ),
        const SizedBox(height: PawlumSpacing.md),
        _StoryField(
          key: const Key('memory-location-field'),
          label: 'Location',
          initialValue: controller.location.value,
          onChanged: controller.setLocation,
        ),
        const SizedBox(height: PawlumSpacing.md),
        _StoryField(
          key: const Key('memory-occasion-field'),
          label: 'Occasion',
          initialValue: controller.occasion.value,
          onChanged: controller.setOccasion,
        ),
        const SizedBox(height: PawlumSpacing.md),
        OutlinedButton.icon(
          onPressed: () async {
            final selected = await showDatePicker(
              context: context,
              initialDate: controller.memoryDate.value,
              firstDate: DateTime(2000),
              lastDate: controller.now(),
            );
            if (selected != null) controller.setMemoryDate(selected);
          },
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(
            'Memory date · ${DateFormat.yMMMd().format(controller.memoryDate.value)}',
          ),
        ),
      ],
    );
  }
}

class _StoryField extends StatelessWidget {
  const _StoryField({
    required super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: '$label · optional'),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({required this.controller});

  final MemoryAuthoringController controller;

  @override
  Widget build(BuildContext context) {
    final presentation = controller.presentation;
    final title = controller.title.value.trim();
    final caption = controller.caption.value.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PawlumRibbon(label: 'Publish review'),
        const SizedBox(height: PawlumSpacing.md),
        _PaperPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PawlumPetPlaceholder(
                semanticLabel: 'Memory cover preview',
                icon: Icons.photo_library_outlined,
                size: 120,
              ),
              const SizedBox(height: PawlumSpacing.md),
              Text(
                title.isEmpty ? 'Untitled memory' : title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              if (caption.isNotEmpty) ...[
                const SizedBox(height: PawlumSpacing.xs),
                Text(caption),
              ],
              const SizedBox(height: PawlumSpacing.md),
              Text(
                '${controller.mediaSelection.value.activeMedia.length} media · '
                '${DateFormat.yMMMd().format(controller.memoryDate.value)}',
              ),
              const SizedBox(height: PawlumSpacing.xs),
              Text(
                'Theme: ${_displayKey(presentation.themeKey)} · '
                'Template: ${_displayKey(presentation.templateKey)} · '
                'Layout: ${_displayKey(presentation.layoutKey)}',
                key: const Key('memory-presentation-summary'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthoringNavigation extends StatelessWidget {
  const _AuthoringNavigation({required this.controller});

  final MemoryAuthoringController controller;

  @override
  Widget build(BuildContext context) {
    final first = controller.step.value == MemoryAuthoringStep.media;
    final review = controller.step.value == MemoryAuthoringStep.review;
    return SafeArea(
      top: false,
      child: Row(
        children: [
          if (!first)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.back,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back'),
              ),
            ),
          if (!first) const SizedBox(width: PawlumSpacing.sm),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: controller.isSavingDraft.value
                  ? null
                  : () => unawaited(controller.saveDraft()),
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save draft'),
            ),
          ),
          const SizedBox(width: PawlumSpacing.sm),
          Expanded(
            child: FilledButton.icon(
              onPressed: review
                  ? () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Review complete. Ready to publish.'),
                      ),
                    )
                  : controller.next,
              icon: Icon(
                review ? Icons.check_rounded : Icons.arrow_forward_rounded,
              ),
              label: Text(review ? 'Finish review' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaperPanel extends StatelessWidget {
  const _PaperPanel({
    required this.child,
    this.padding = const EdgeInsets.all(PawlumSpacing.lg),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PawlumColors.paper,
        borderRadius: BorderRadius.circular(PawlumRadii.card),
        border: Border.all(color: PawlumColors.outline),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

String _stepTitle(MemoryAuthoringStep step) => switch (step) {
  MemoryAuthoringStep.media => 'Choose media',
  MemoryAuthoringStep.decoration => 'Decorate',
  MemoryAuthoringStep.story => 'Tell the story',
  MemoryAuthoringStep.review => 'Review memory',
};

String _displayKey(String value) => value
    .split('_')
    .map(
      (String part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}',
    )
    .join(' ');

Future<void> _requestExit(
  BuildContext context,
  MemoryAuthoringController controller,
) async {
  if (!controller.hasUnsavedChanges.value) {
    await controller.exitWithoutChanges();
    return;
  }
  final choice = await showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: const Text('Save this memory draft?'),
      content: const Text(
        'Your latest changes have not reached local recovery yet.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, 'cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, 'discard'),
          child: const Text('Discard'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, 'save'),
          child: const Text('Save draft'),
        ),
      ],
    ),
  );
  if (choice == 'save') {
    await controller.saveAndExit();
  } else if (choice == 'discard') {
    await controller.discardDraft();
  }
}
