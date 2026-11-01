import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/pawlum_tokens.dart';
import '../../../../core/widgets/pawlum_widgets.dart';
import '../../../memory_authoring/presentation/controllers/memory_lifecycle_controller.dart';
import '../../../memory_authoring/presentation/pages/memory_lifecycle_view.dart';
import '../../domain/entities/pet_models.dart';
import '../controllers/pet_recently_deleted_controller.dart';

class PetRecentlyDeletedView extends GetView<PetRecentlyDeletedController> {
  const PetRecentlyDeletedView({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final memoryController = Get.find<MemoryLifecycleController>();
    return Obx(() {
      if (controller.isLoading.value || memoryController.isLoading.value) {
        return const Center(
          child: PawlumSkeleton(
            width: 280,
            height: 160,
            semanticLabel: 'Loading recently deleted pets',
          ),
        );
      }
      if (controller.errorMessage.value case final message?) {
        return _DeletedMessage(
          title: 'Recently Deleted unavailable',
          message: message,
          onBack: onBack,
          action: PawlumPrimaryButton(
            label: 'Try again',
            onPressed: controller.load,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Back to Settings',
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: PawlumSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recently Deleted',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const Text(
                      'Pet journals and memories stay recoverable for seven days.',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: PawlumSpacing.lg),
          if (controller.pets.isEmpty && memoryController.deleted.isEmpty)
            Expanded(
              child: _DeletedMessage(
                title: 'Nothing to recover',
                message:
                    'Deleted pet journals and memories will appear here for seven days.',
                onBack: onBack,
              ),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  if (controller.pets.isNotEmpty) ...[
                    Text(
                      'Pet journals',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: PawlumSpacing.sm),
                    for (final pet in controller.pets) ...[
                      _DeletedPetCard(
                        pet: pet,
                        daysRemaining: controller.daysRemaining(pet),
                        isRestoring: controller.restoringPetId.value == pet.id,
                        onRestore: () => unawaited(controller.restore(pet)),
                      ),
                      const SizedBox(height: PawlumSpacing.md),
                    ],
                  ],
                  if (memoryController.deleted.isNotEmpty) ...[
                    Text(
                      'Memories',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: PawlumSpacing.sm),
                    const MemoryRecentlyDeletedSection(),
                  ],
                ],
              ),
            ),
        ],
      );
    });
  }
}

class _DeletedPetCard extends StatelessWidget {
  const _DeletedPetCard({
    required this.pet,
    required this.daysRemaining,
    required this.isRestoring,
    required this.onRestore,
  });

  final PetProfile pet;
  final int daysRemaining;
  final bool isRestoring;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final recoveryLabel = daysRemaining == 1
        ? '1 day left'
        : '$daysRemaining days left';
    return Semantics(
      label: '${pet.name}, $recoveryLabel',
      container: true,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(PawlumSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(PawlumRadii.control),
                child: SizedBox.square(
                  dimension: 72,
                  child: _DeletedPetPhoto(pet: pet),
                ),
              ),
              const SizedBox(width: PawlumSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: PawlumSpacing.xs),
                    PawlumStatusBadge(
                      status: PawlumStatus.deleted,
                      label: recoveryLabel,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: PawlumSpacing.sm),
              FilledButton.tonalIcon(
                onPressed: isRestoring ? null : onRestore,
                icon: isRestoring
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.restore_rounded),
                label: const Text('Restore'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeletedPetPhoto extends StatelessWidget {
  const _DeletedPetPhoto({required this.pet});

  final PetProfile pet;

  @override
  Widget build(BuildContext context) {
    final path = pet.profileImagePath;
    if (path == null) {
      return PawlumPetPlaceholder(
        semanticLabel: '${pet.name} placeholder',
        size: 72,
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => PawlumPetPlaceholder(
        semanticLabel: '${pet.name} photo unavailable',
        size: 72,
      ),
    );
  }
}

class _DeletedMessage extends StatelessWidget {
  const _DeletedMessage({
    required this.title,
    required this.message,
    required this.onBack,
    this.action,
  });

  final String title;
  final String message;
  final VoidCallback onBack;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PawlumPetPlaceholder(
              semanticLabel: title,
              icon: Icons.restore_from_trash_rounded,
              size: 88,
            ),
            const SizedBox(height: PawlumSpacing.lg),
            Text(title, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: PawlumSpacing.xs),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: PawlumSpacing.lg),
              action!,
            ],
            const SizedBox(height: PawlumSpacing.sm),
            TextButton(
              onPressed: onBack,
              child: const Text('Back to Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
