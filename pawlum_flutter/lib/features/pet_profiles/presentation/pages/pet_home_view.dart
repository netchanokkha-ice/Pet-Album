import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/pawlum_tokens.dart';
import '../../../../core/widgets/pawlum_widgets.dart';
import '../../domain/entities/pet_models.dart';
import '../controllers/pet_home_controller.dart';

class PetHomeView extends GetView<PetHomeController> {
  const PetHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: PawlumSkeleton(
            width: 260,
            height: 180,
            semanticLabel: 'Loading pet journals',
          ),
        );
      }
      if (controller.errorMessage.value case final message?) {
        return _HomeMessage(
          title: 'Pet journals unavailable',
          message: message,
          action: PawlumPrimaryButton(
            label: 'Try again',
            onPressed: controller.load,
          ),
        );
      }
      if (controller.pets.isEmpty) {
        return _HomeMessage(
          title: 'No pet journals yet',
          message: 'Add a pet to give every memory its own little home.',
          action: PawlumPrimaryButton(
            label: 'Add your first pet',
            icon: Icons.add_rounded,
            onPressed: () => unawaited(controller.addPet()),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PawlumWashiTape(label: 'My little family'),
                    const SizedBox(height: PawlumSpacing.sm),
                    Text(
                      'Your pets',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
              PawlumGhostButton(
                label: 'Add pet',
                icon: Icons.add_rounded,
                onPressed: () => unawaited(controller.addPet()),
              ),
            ],
          ),
          const SizedBox(height: PawlumSpacing.lg),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final columns = constraints.maxWidth >= 720 ? 3 : 2;
                return GridView.builder(
                  itemCount: controller.pets.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: PawlumSpacing.md,
                    mainAxisSpacing: PawlumSpacing.md,
                    childAspectRatio: constraints.maxWidth < 480 ? 0.72 : 0.82,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final pet = controller.pets[index];
                    return _PetCard(
                      pet: pet,
                      selected: controller.selectedPetId.value == pet.id,
                      onOpen: () => unawaited(controller.selectPet(pet)),
                      onEdit: () => _showEditor(context, pet),
                    );
                  },
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Future<void> _showEditor(BuildContext context, PetProfile pet) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
          _EditPetDialog(pet: pet, controller: controller),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({
    required this.pet,
    required this.selected,
    required this.onOpen,
    required this.onEdit,
  });

  final PetProfile pet;
  final bool selected;
  final VoidCallback onOpen;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${pet.name} pet journal',
      button: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? PawlumColors.pinkStrong : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(PawlumRadii.card),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Stack(
            children: [
              Positioned.fill(
                child: PawlumPolaroidCard(
                  caption: pet.name,
                  semanticLabel: 'Open ${pet.name} journal',
                  onTap: onOpen,
                  media: _PetPhoto(pet: pet),
                ),
              ),
              Positioned(
                right: PawlumSpacing.xs,
                top: PawlumSpacing.xs,
                child: IconButton.filledTonal(
                  tooltip: 'Edit ${pet.name}',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetPhoto extends StatelessWidget {
  const _PetPhoto({required this.pet});

  final PetProfile pet;

  @override
  Widget build(BuildContext context) {
    final path = pet.profileImagePath;
    if (path == null) {
      return PawlumPetPlaceholder(
        semanticLabel: '${pet.name} placeholder',
        size: 120,
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => PawlumPetPlaceholder(
        semanticLabel: '${pet.name} photo unavailable',
        size: 120,
      ),
    );
  }
}

class _EditPetDialog extends StatefulWidget {
  const _EditPetDialog({required this.pet, required this.controller});

  final PetProfile pet;
  final PetHomeController controller;

  @override
  State<_EditPetDialog> createState() => _EditPetDialogState();
}

class _EditPetDialogState extends State<_EditPetDialog> {
  late final TextEditingController _nameController;
  late String? _photoPath;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _photoPath = widget.pet.profileImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.pet.name}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('edit-pet-name-field'),
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Pet name',
                errorText: _errorText,
              ),
            ),
            const SizedBox(height: PawlumSpacing.md),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Pet type · read only',
              ),
              child: Text(_petTypeLabel(widget.pet)),
            ),
            const SizedBox(height: PawlumSpacing.md),
            PawlumGhostButton(
              label: _photoPath == null
                  ? 'Choose profile photo'
                  : 'Change profile photo',
              icon: Icons.photo_library_outlined,
              onPressed: () async {
                final selected = await widget.controller.choosePhoto();
                if (selected != null && mounted) {
                  setState(() => _photoPath = selected);
                }
              },
            ),
            const SizedBox(height: PawlumSpacing.sm),
            TextButton.icon(
              onPressed: _deletePet,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Move to Recently Deleted'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (_nameController.text.trim().isEmpty) {
              setState(() => _errorText = 'Pet name is required');
              return;
            }
            final saved = await widget.controller.saveProfile(
              pet: widget.pet,
              name: _nameController.text,
              profileImagePath: _photoPath,
            );
            if (saved && context.mounted) Navigator.pop(context);
          },
          child: const Text('Save changes'),
        ),
      ],
    );
  }

  Future<void> _deletePet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text('Delete ${widget.pet.name}?'),
        content: const Text(
          'This pet journal will leave Home. You can restore it from '
          'Recently Deleted for seven days.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep pet'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete pet'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final deleted = await widget.controller.deletePet(widget.pet);
    if (deleted && mounted) Navigator.pop(context);
  }

  String _petTypeLabel(PetProfile pet) {
    if (pet.type == PetType.other) return pet.customTypeLabel ?? 'Other';
    return '${pet.type.name[0].toUpperCase()}${pet.type.name.substring(1)}';
  }
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({required this.title, required this.message, this.action});

  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PawlumPetPlaceholder(semanticLabel: title, size: 96),
            const SizedBox(height: PawlumSpacing.lg),
            Text(title, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: PawlumSpacing.xs),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: PawlumSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
