import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/pawlum_tokens.dart';
import '../../../../core/widgets/pawlum_widgets.dart';
import '../../domain/entities/memory_models.dart';
import '../controllers/memory_lifecycle_controller.dart';

class MemoryLifecycleView extends GetView<MemoryLifecycleController> {
  const MemoryLifecycleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: PawlumSkeleton(
            width: 280,
            height: 180,
            semanticLabel: 'Loading memories',
          ),
        );
      }
      if (controller.active.isEmpty) {
        return const Center(
          child: _MemoryMessage(
            title: 'Timeline',
            message: 'Published memories will appear here by date.',
          ),
        );
      }
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: PawlumSpacing.lg),
        children: [
          Text('Timeline', style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: PawlumSpacing.lg),
          for (final memory in controller.active) ...[
            _ActiveMemoryCard(memory: memory),
            const SizedBox(height: PawlumSpacing.md),
          ],
        ],
      );
    });
  }
}

class _ActiveMemoryCard extends GetView<MemoryLifecycleController> {
  const _ActiveMemoryCard({required this.memory});

  final MemoryAggregate memory;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PawlumSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.auto_stories_rounded, size: 40),
            const SizedBox(width: PawlumSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.titleOf(memory),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(memory.lifecycleStatus.name),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Delete ${controller.titleOf(memory)}',
              onPressed: () => unawaited(_confirmDelete(context)),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(
          memory.isFirstMemory ? 'Delete first memory?' : 'Delete memory?',
        ),
        content: Text(controller.deleteWarning(memory)),
        actions: [
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

class MemoryRecentlyDeletedSection extends GetView<MemoryLifecycleController> {
  const MemoryRecentlyDeletedSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final memory in controller.deleted) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(PawlumSpacing.md),
                child: Row(
                  children: [
                    const Icon(Icons.photo_album_outlined, size: 40),
                    const SizedBox(width: PawlumSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.titleOf(memory),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          PawlumStatusBadge(
                            status: PawlumStatus.deleted,
                            label:
                                '${controller.daysRemaining(memory)} days left',
                          ),
                        ],
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: controller.busyMemoryId.value == null
                          ? () => unawaited(controller.restore(memory))
                          : null,
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text('Restore memory'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: PawlumSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _MemoryMessage extends StatelessWidget {
  const _MemoryMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      PawlumPetPlaceholder(
        semanticLabel: title,
        icon: Icons.auto_stories_rounded,
        size: 88,
      ),
      const SizedBox(height: PawlumSpacing.lg),
      Text(title, style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: PawlumSpacing.xs),
      Text(message, textAlign: TextAlign.center),
    ],
  );
}
