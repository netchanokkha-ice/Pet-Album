import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/pawlum_tokens.dart';
import '../../../../core/widgets/pawlum_widgets.dart';
import '../../domain/entities/pet_models.dart';
import '../../domain/entities/pet_onboarding_draft.dart';
import '../controllers/pet_onboarding_controller.dart';

class PetOnboardingPage extends GetView<PetOnboardingController> {
  const PetOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PawlumPaperBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: PawlumSkeleton(
                width: 220,
                height: 24,
                semanticLabel: 'Loading pet setup',
              ),
            );
          }
          if (controller.errorMessage.value case final message?) {
            return Center(child: Text(message));
          }
          final current = controller.draft.value;
          if (current == null) return const SizedBox.shrink();

          return Column(
            children: [
              _OnboardingHeader(
                step: current.step,
                onCancel: () => _showCancelDialog(context),
              ),
              const SizedBox(height: PawlumSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: AnimatedSwitcher(
                        duration: PawlumMotion.standard,
                        child: _StepContent(
                          key: ValueKey<PetOnboardingStep>(current.step),
                          draft: current,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Leave pet setup?'),
        content: const Text(
          'Keep this draft for next time, or discard the setup completely.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              unawaited(controller.discardAndExit());
            },
            child: const Text('Discard setup'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              unawaited(controller.keepDraftAndExit());
            },
            child: const Text('Keep draft'),
          ),
        ],
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({required this.step, required this.onCancel});

  final PetOnboardingStep step;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            label: 'Pet setup step ${step.index + 1} of 4',
            child: Row(
              children: PetOnboardingStep.values
                  .map((PetOnboardingStep item) {
                    final active = item.index <= step.index;
                    return Expanded(
                      child: Container(
                        key: ValueKey<String>('progress-${item.name}'),
                        height: 6,
                        margin: const EdgeInsets.only(right: PawlumSpacing.xs),
                        decoration: BoxDecoration(
                          color: active
                              ? PawlumColors.pinkStrong
                              : PawlumColors.outline,
                          borderRadius: BorderRadius.circular(
                            PawlumRadii.round,
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ),
        TextButton(onPressed: onCancel, child: const Text('Cancel')),
      ],
    );
  }
}

class _StepContent extends GetView<PetOnboardingController> {
  const _StepContent({required this.draft, super.key});

  final PetOnboardingDraft draft;

  @override
  Widget build(BuildContext context) => switch (draft.step) {
    PetOnboardingStep.welcome => _WelcomeStep(onBegin: controller.begin),
    PetOnboardingStep.petInfo => _PetInfoStep(draft: draft),
    PetOnboardingStep.photo => _PhotoStep(draft: draft),
    PetOnboardingStep.confirmation => _ConfirmationStep(draft: draft),
  };
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onBegin});

  final Future<void> Function() onBegin;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PawlumWashiTape(label: 'A new little chapter', width: 190),
        const SizedBox(height: PawlumSpacing.lg),
        const PawlumPetPlaceholder(
          semanticLabel: 'Pet journal welcome',
          size: 120,
        ),
        const SizedBox(height: PawlumSpacing.lg),
        Text(
          'Let’s meet your pet',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.sm),
        Text(
          'A few details help every memory land in the right journal.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.xl),
        PawlumPrimaryButton(
          label: 'Begin pet setup',
          icon: Icons.pets_rounded,
          onPressed: () => unawaited(onBegin()),
        ),
      ],
    );
  }
}

class _PetInfoStep extends GetView<PetOnboardingController> {
  const _PetInfoStep({required this.draft});

  final PetOnboardingDraft draft;

  @override
  Widget build(BuildContext context) {
    final issues = controller.issues;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PawlumStickerLabel(
          label: 'Pet details',
          icon: Icons.favorite_rounded,
        ),
        const SizedBox(height: PawlumSpacing.md),
        Text(
          'Tell us about your pet',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: PawlumSpacing.lg),
        TextField(
          key: const Key('pet-name-field'),
          controller: controller.nameController,
          onChanged: (String value) => unawaited(controller.updateName(value)),
          decoration: InputDecoration(
            labelText: 'Pet name *',
            errorText: issues.contains(PetOnboardingIssue.nameRequired)
                ? 'Pet name is required'
                : null,
          ),
        ),
        const SizedBox(height: PawlumSpacing.lg),
        Text('Pet type *', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: PawlumSpacing.xs),
        Wrap(
          spacing: PawlumSpacing.xs,
          runSpacing: PawlumSpacing.xs,
          children: PetType.values
              .map((PetType type) {
                return ChoiceChip(
                  label: Text(_typeLabel(type)),
                  selected: draft.type == type,
                  onSelected: (_) => unawaited(controller.selectType(type)),
                );
              })
              .toList(growable: false),
        ),
        if (issues.contains(PetOnboardingIssue.typeRequired))
          const Padding(
            padding: EdgeInsets.only(top: PawlumSpacing.xs),
            child: Text(
              'Choose a pet type',
              style: TextStyle(color: Colors.red),
            ),
          ),
        if (draft.type == PetType.other) ...[
          const SizedBox(height: PawlumSpacing.md),
          TextField(
            key: const Key('other-type-field'),
            controller: controller.otherTypeController,
            onChanged: (String value) =>
                unawaited(controller.updateOtherType(value)),
            decoration: InputDecoration(
              labelText: 'What kind of pet? *',
              errorText:
                  issues.contains(PetOnboardingIssue.otherTypeLabelRequired)
                  ? 'Custom pet type is required'
                  : null,
            ),
          ),
        ],
        const SizedBox(height: PawlumSpacing.lg),
        _DateField(
          label: 'Birthday (optional)',
          value: draft.birthday,
          onChanged: controller.setBirthday,
        ),
        const SizedBox(height: PawlumSpacing.sm),
        _DateField(
          label: 'First met or adoption date (optional)',
          value: draft.firstMetDate,
          onChanged: controller.setFirstMetDate,
        ),
        const SizedBox(height: PawlumSpacing.xl),
        _BackNextRow(
          onBack: controller.back,
          nextLabel: 'Continue to photo',
          onNext: controller.continueFromPetInfo,
        ),
      ],
    );
  }

  String _typeLabel(PetType type) => switch (type) {
    PetType.dog => 'Dog',
    PetType.cat => 'Cat',
    PetType.bird => 'Bird',
    PetType.rabbit => 'Rabbit',
    PetType.other => 'Other',
  };
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final Future<void> Function(DateTime? value) onChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(1980),
          lastDate: DateTime.now(),
        );
        if (selected != null) await onChanged(selected);
      },
      icon: const Icon(Icons.calendar_today_rounded),
      label: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          value == null
              ? label
              : '$label: ${DateFormat.yMMMd().format(value!)}',
        ),
      ),
    );
  }
}

class _PhotoStep extends GetView<PetOnboardingController> {
  const _PhotoStep({required this.draft});

  final PetOnboardingDraft draft;

  @override
  Widget build(BuildContext context) {
    final photo = draft.profileImageBytes;
    return Column(
      children: [
        Text(
          'Add a favorite photo',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: PawlumSpacing.sm),
        Text(
          'Optional for now — a warm placeholder will keep the journal cozy.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.lg),
        SizedBox(
          width: 280,
          child: PawlumPolaroidCard(
            caption: draft.name.trim().isEmpty ? 'Your pet' : draft.name.trim(),
            media: photo == null
                ? const ColoredBox(
                    color: PawlumColors.pinkSoft,
                    child: Center(
                      child: Icon(Icons.add_a_photo_rounded, size: 56),
                    ),
                  )
                : Image.memory(photo, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: PawlumSpacing.lg),
        PawlumGhostButton(
          label: photo == null ? 'Choose photo' : 'Change photo',
          icon: Icons.photo_library_outlined,
          onPressed: () => unawaited(controller.pickPhoto()),
        ),
        const SizedBox(height: PawlumSpacing.xl),
        _BackNextRow(
          onBack: controller.back,
          nextLabel: photo == null ? 'Skip for now' : 'Use this photo',
          onNext: controller.continueFromPhoto,
        ),
      ],
    );
  }
}

class _ConfirmationStep extends GetView<PetOnboardingController> {
  const _ConfirmationStep({required this.draft});

  final PetOnboardingDraft draft;

  @override
  Widget build(BuildContext context) {
    final type = draft.type == PetType.other
        ? draft.customTypeLabel ?? 'Other pet'
        : draft.type?.name ?? 'Pet';
    final milestoneDate =
        draft.firstMetDate ?? draft.birthday ?? controller.now();
    return Column(
      children: [
        const PawlumRibbon(label: 'First memory'),
        const SizedBox(height: PawlumSpacing.lg),
        Text(
          'Your journal is ready to begin',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.lg),
        Container(
          padding: const EdgeInsets.all(PawlumSpacing.lg),
          decoration: BoxDecoration(
            color: PawlumColors.paper,
            borderRadius: BorderRadius.circular(PawlumRadii.card),
            boxShadow: PawlumShadows.paper,
          ),
          child: Row(
            children: [
              const PawlumPetPlaceholder(
                semanticLabel: 'Pet profile preview',
                size: 88,
              ),
              const SizedBox(width: PawlumSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.name.trim(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(type, style: Theme.of(context).textTheme.bodyLarge),
                    Text(
                      DateFormat.yMMMd().format(milestoneDate),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PawlumSpacing.lg),
        Text(
          'Confirming will create the pet journal and an editable first-memory milestone.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.xl),
        Obx(
          () => _BackNextRow(
            onBack: controller.back,
            nextLabel: 'Confirm first memory',
            onNext: controller.confirm,
            isLoading: controller.isSaving.value,
          ),
        ),
      ],
    );
  }
}

class _BackNextRow extends StatelessWidget {
  const _BackNextRow({
    required this.onBack,
    required this.nextLabel,
    required this.onNext,
    this.isLoading = false,
  });

  final Future<void> Function() onBack;
  final String nextLabel;
  final Future<Object?> Function() onNext;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PawlumGhostButton(label: 'Back', onPressed: () => unawaited(onBack())),
        const SizedBox(width: PawlumSpacing.sm),
        Flexible(
          child: PawlumPrimaryButton(
            label: nextLabel,
            isLoading: isLoading,
            onPressed: () => unawaited(onNext()),
          ),
        ),
      ],
    );
  }
}
