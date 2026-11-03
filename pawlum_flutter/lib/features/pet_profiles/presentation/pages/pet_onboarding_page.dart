import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/pawlum_tokens.dart';
import '../../../../core/widgets/pawlum_widgets.dart';
import '../../domain/entities/pet_models.dart';
import '../../domain/entities/pet_onboarding_draft.dart';
import '../controllers/pet_onboarding_controller.dart';

const _questionCount = 6;

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
          final draft = controller.draft.value;
          if (draft == null) return const SizedBox.shrink();

          final question = draft.resolvedQuestion;
          return Column(
            children: [
              _OnboardingHeader(
                question: question,
                onCancel: () => _showCancelDialog(context),
              ),
              const SizedBox(height: PawlumSpacing.md),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: PawlumSpacing.md),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 620),
                          child: _PageFlipSwitcher(
                            question: question,
                            forward: controller.isTurningForward.value,
                            child: _QuestionSheet(
                              key: ValueKey<PetOnboardingQuestion>(question),
                              minimumHeight: math.max(
                                500,
                                constraints.maxHeight - PawlumSpacing.xs,
                              ),
                              child: _QuestionContent(
                                question: question,
                                draft: draft,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
          'Your answers are saved. Keep this draft for later, or discard it.',
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
  const _OnboardingHeader({required this.question, required this.onCancel});

  final PetOnboardingQuestion question;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final progress = _progressFor(question);
    final status = question == PetOnboardingQuestion.welcome
        ? 'About one minute'
        : 'Question $progress of $_questionCount';

    return Row(
      children: [
        Expanded(
          child: Semantics(
            label: question == PetOnboardingQuestion.welcome
                ? 'Pet setup ready to begin'
                : 'Pet setup question $progress of $_questionCount',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List<Widget>.generate(_questionCount, (int index) {
                    final active = index < progress;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: PawlumMotion.standard,
                        curve: PawlumMotion.enterCurve,
                        height: 6,
                        margin: EdgeInsets.only(
                          right: index == _questionCount - 1
                              ? 0
                              : PawlumSpacing.xs,
                        ),
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
                  }),
                ),
                const SizedBox(height: PawlumSpacing.xs),
                Text(
                  status,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: PawlumColors.inkMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: PawlumSpacing.md),
        TextButton(onPressed: onCancel, child: const Text('Save & leave')),
      ],
    );
  }
}

class _PageFlipSwitcher extends StatelessWidget {
  const _PageFlipSwitcher({
    required this.question,
    required this.forward,
    required this.child,
  });

  final PetOnboardingQuestion question;
  final bool forward;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return ClipRect(
      child: AnimatedSwitcher(
        duration: reduceMotion
            ? PawlumMotion.quick
            : const Duration(milliseconds: 420),
        reverseDuration: reduceMotion
            ? PawlumMotion.quick
            : const Duration(milliseconds: 320),
        switchInCurve: PawlumMotion.enterCurve,
        switchOutCurve: PawlumMotion.exitCurve,
        transitionBuilder: (Widget child, Animation<double> animation) {
          if (reduceMotion) {
            return FadeTransition(opacity: animation, child: child);
          }

          final incoming =
              child.key == ValueKey<PetOnboardingQuestion>(question);
          final direction = forward ? 1.0 : -1.0;
          final beginAngle = (incoming ? direction : -direction) * math.pi / 2;
          final curved = CurvedAnimation(
            parent: animation,
            curve: incoming ? PawlumMotion.enterCurve : PawlumMotion.exitCurve,
          );
          final turn = Tween<double>(begin: beginAngle, end: 0).animate(curved);

          return FadeTransition(
            opacity: Tween<double>(begin: 0.18, end: 1).animate(curved),
            child: AnimatedBuilder(
              animation: turn,
              child: child,
              builder: (BuildContext context, Widget? child) {
                return Transform(
                  key: const Key('onboarding-page-flip'),
                  alignment: forward
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0012)
                    ..rotateY(turn.value),
                  child: child,
                );
              },
            ),
          );
        },
        child: child,
      ),
    );
  }
}

class _QuestionSheet extends StatelessWidget {
  const _QuestionSheet({
    required this.minimumHeight,
    required this.child,
    super.key,
  });

  final double minimumHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final compact =
        PawlumLayoutTheme.of(context).windowClass == PawlumWindowClass.compact;

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        constraints: BoxConstraints(minHeight: minimumHeight),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? PawlumSpacing.lg : PawlumSpacing.xl,
          vertical: compact ? PawlumSpacing.xl : PawlumSpacing.xxl,
        ),
        decoration: BoxDecoration(
          color: PawlumColors.paper,
          borderRadius: BorderRadius.circular(16),
          boxShadow: PawlumShadows.paper,
        ),
        child: child,
      ),
    );
  }
}

class _QuestionContent extends GetView<PetOnboardingController> {
  const _QuestionContent({required this.question, required this.draft});

  final PetOnboardingQuestion question;
  final PetOnboardingDraft draft;

  @override
  Widget build(BuildContext context) => switch (question) {
    PetOnboardingQuestion.welcome => const _WelcomeQuestion(),
    PetOnboardingQuestion.name => _NameQuestion(draft: draft),
    PetOnboardingQuestion.type => _TypeQuestion(draft: draft),
    PetOnboardingQuestion.customType => _CustomTypeQuestion(draft: draft),
    PetOnboardingQuestion.birthday => _DateQuestion(
      title: 'When was ${_petName(draft)} born?',
      description: 'This is optional. An estimate is perfectly fine.',
      value: draft.birthday,
      chooseLabel: 'Choose birthday',
      clearLabel: 'Clear birthday',
      onChanged: controller.setBirthday,
      onNext: controller.continueFromBirthday,
    ),
    PetOnboardingQuestion.firstMetDate => _DateQuestion(
      title: 'When did you first meet ${_petName(draft)}?',
      description: 'We’ll use it to open the first page of your journal.',
      value: draft.firstMetDate,
      chooseLabel: 'Choose the day',
      clearLabel: 'Clear date',
      onChanged: controller.setFirstMetDate,
      onNext: controller.continueFromFirstMetDate,
    ),
    PetOnboardingQuestion.photo => _PhotoQuestion(draft: draft),
    PetOnboardingQuestion.confirmation => _ConfirmationQuestion(draft: draft),
  };
}

class _WelcomeQuestion extends GetView<PetOnboardingController> {
  const _WelcomeQuestion();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PawlumWashiTape(label: 'A new little chapter', width: 190),
        const SizedBox(height: PawlumSpacing.xl),
        const PawlumPetPlaceholder(
          semanticLabel: 'Pet journal welcome',
          size: 116,
        ),
        const SizedBox(height: PawlumSpacing.xl),
        Text(
          'Let’s meet your pet',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Text(
            'Six small questions, then their private journal is ready for the moments you want to keep.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: PawlumSpacing.xl),
        PawlumPrimaryButton(
          label: 'Start with their name',
          icon: Icons.pets_rounded,
          onPressed: () => unawaited(controller.begin()),
        ),
      ],
    );
  }
}

class _NameQuestion extends GetView<PetOnboardingController> {
  const _NameQuestion({required this.draft});

  final PetOnboardingDraft draft;

  @override
  Widget build(BuildContext context) {
    final hasError = controller.issues.contains(
      PetOnboardingIssue.nameRequired,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: PawlumPetPlaceholder(semanticLabel: 'Pet name', size: 88),
        ),
        const SizedBox(height: PawlumSpacing.xl),
        Text(
          'What should we call your pet?',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.sm),
        Text(
          'This name will sit at the top of every memory.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.xl),
        TextField(
          key: const Key('pet-name-field'),
          controller: controller.nameController,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onChanged: (String value) => unawaited(controller.updateName(value)),
          onSubmitted: (_) => unawaited(controller.continueFromName()),
          decoration: InputDecoration(
            labelText: 'Pet name',
            hintText: 'Mochi',
            errorText: hasError ? 'Enter your pet’s name to continue' : null,
          ),
        ),
        const SizedBox(height: PawlumSpacing.xl),
        _BackNextRow(
          onBack: controller.back,
          nextLabel: 'That’s their name',
          onNext: controller.continueFromName,
        ),
      ],
    );
  }
}

class _TypeQuestion extends GetView<PetOnboardingController> {
  const _TypeQuestion({required this.draft});

  final PetOnboardingDraft draft;

  @override
  Widget build(BuildContext context) {
    final hasError = controller.issues.contains(
      PetOnboardingIssue.typeRequired,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What kind of pet is ${_petName(draft)}?',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.sm),
        Text(
          'Choose the one that feels closest.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.xl),
        _PetTypeChoices(
          selected: draft.type,
          onSelected: controller.selectType,
        ),
        if (hasError) ...[
          const SizedBox(height: PawlumSpacing.sm),
          Text(
            'Choose a pet type to continue',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: PawlumSpacing.xl),
        _BackNextRow(
          onBack: controller.back,
          nextLabel: 'Continue',
          onNext: controller.continueFromType,
        ),
      ],
    );
  }
}

class _PetTypeChoices extends StatelessWidget {
  const _PetTypeChoices({required this.selected, required this.onSelected});

  final PetType? selected;
  final Future<void> Function(PetType type) onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final itemWidth = constraints.maxWidth >= 480
            ? (constraints.maxWidth - PawlumSpacing.sm) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: PawlumSpacing.sm,
          runSpacing: PawlumSpacing.sm,
          children: PetType.values
              .map((PetType type) {
                final isSelected = selected == type;
                return SizedBox(
                  width: itemWidth,
                  child: Semantics(
                    selected: isSelected,
                    button: true,
                    label: _typeLabel(type),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => unawaited(onSelected(type)),
                        borderRadius: BorderRadius.circular(
                          PawlumRadii.control,
                        ),
                        child: AnimatedContainer(
                          duration: PawlumMotion.standard,
                          curve: PawlumMotion.enterCurve,
                          constraints: const BoxConstraints(minHeight: 68),
                          padding: const EdgeInsets.symmetric(
                            horizontal: PawlumSpacing.md,
                            vertical: PawlumSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? PawlumColors.pinkSoft
                                : PawlumColors.canvas,
                            borderRadius: BorderRadius.circular(
                              PawlumRadii.control,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? PawlumColors.pinkStrong
                                  : PawlumColors.outline,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _typeIcon(type),
                                color: isSelected
                                    ? PawlumColors.pinkStrong
                                    : PawlumColors.inkMuted,
                              ),
                              const SizedBox(width: PawlumSpacing.sm),
                              Expanded(
                                child: Text(
                                  _typeLabel(type),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: PawlumColors.pinkStrong,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

class _CustomTypeQuestion extends GetView<PetOnboardingController> {
  const _CustomTypeQuestion({required this.draft});

  final PetOnboardingDraft draft;

  @override
  Widget build(BuildContext context) {
    final hasError = controller.issues.contains(
      PetOnboardingIssue.otherTypeLabelRequired,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: PawlumPetPlaceholder(
            semanticLabel: 'Other pet type',
            size: 88,
            icon: Icons.favorite_rounded,
          ),
        ),
        const SizedBox(height: PawlumSpacing.xl),
        Text(
          'Tell us what kind of pet ${_petName(draft)} is',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.sm),
        Text(
          'Use the name you naturally use for them.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.xl),
        TextField(
          key: const Key('other-type-field'),
          controller: controller.otherTypeController,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          onChanged: (String value) =>
              unawaited(controller.updateOtherType(value)),
          onSubmitted: (_) => unawaited(controller.continueFromCustomType()),
          decoration: InputDecoration(
            labelText: 'Kind of pet',
            hintText: 'Hamster, turtle, gecko…',
            errorText: hasError ? 'Tell us what kind of pet this is' : null,
          ),
        ),
        const SizedBox(height: PawlumSpacing.xl),
        _BackNextRow(
          onBack: controller.back,
          nextLabel: 'Continue',
          onNext: controller.continueFromCustomType,
        ),
      ],
    );
  }
}

class _DateQuestion extends GetView<PetOnboardingController> {
  const _DateQuestion({
    required this.title,
    required this.description,
    required this.value,
    required this.chooseLabel,
    required this.clearLabel,
    required this.onChanged,
    required this.onNext,
  });

  final String title;
  final String description;
  final DateTime? value;
  final String chooseLabel;
  final String clearLabel;
  final Future<void> Function(DateTime? value) onChanged;
  final Future<void> Function() onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: PawlumPetPlaceholder(
            semanticLabel: 'Pet milestone date',
            size: 88,
            icon: Icons.calendar_month_rounded,
          ),
        ),
        const SizedBox(height: PawlumSpacing.xl),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.sm),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.xl),
        OutlinedButton.icon(
          onPressed: () => _chooseDate(context),
          icon: const Icon(Icons.calendar_today_rounded),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: PawlumSpacing.sm),
            child: Text(
              value == null ? chooseLabel : DateFormat.yMMMMd().format(value!),
            ),
          ),
        ),
        if (value != null)
          Center(
            child: TextButton(
              onPressed: () => unawaited(onChanged(null)),
              child: Text(clearLabel),
            ),
          ),
        const SizedBox(height: PawlumSpacing.xl),
        _BackNextRow(
          onBack: controller.back,
          nextLabel: value == null ? 'Skip for now' : 'Continue',
          onNext: onNext,
        ),
      ],
    );
  }

  Future<void> _chooseDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (selected != null) await onChanged(selected);
  }
}

class _PhotoQuestion extends GetView<PetOnboardingController> {
  const _PhotoQuestion({required this.draft});

  final PetOnboardingDraft draft;

  @override
  Widget build(BuildContext context) {
    final photo = draft.profileImageBytes;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Which photo feels most like ${_petName(draft)}?',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.sm),
        Text(
          'Optional for now. It stays private in your pet journal.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.lg),
        SizedBox(
          width: 280,
          child: PawlumPolaroidCard(
            caption: _petName(draft),
            media: photo == null
                ? const ColoredBox(
                    color: PawlumColors.pinkSoft,
                    child: Center(
                      child: Icon(Icons.add_a_photo_rounded, size: 56),
                    ),
                  )
                : Image.memory(
                    photo,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
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

class _ConfirmationQuestion extends GetView<PetOnboardingController> {
  const _ConfirmationQuestion({required this.draft});

  final PetOnboardingDraft draft;

  @override
  Widget build(BuildContext context) {
    final photo = draft.profileImageBytes;
    final milestoneDate =
        draft.firstMetDate ?? draft.birthday ?? controller.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PawlumRibbon(label: 'Ready for the first page'),
        const SizedBox(height: PawlumSpacing.xl),
        Text(
          '${_petName(draft)}’s journal is ready',
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.lg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(PawlumSpacing.lg),
          decoration: BoxDecoration(
            color: PawlumColors.paperMuted,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(PawlumRadii.control),
                child: SizedBox.square(
                  dimension: 92,
                  child: photo == null
                      ? const PawlumPetPlaceholder(
                          semanticLabel: 'Pet profile preview',
                          size: 92,
                        )
                      : Image.memory(
                          photo,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.medium,
                        ),
                ),
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
                    const SizedBox(height: PawlumSpacing.xxs),
                    Text(
                      draft.type == PetType.other
                          ? draft.customTypeLabel ?? 'Pet'
                          : _typeLabel(draft.type),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: PawlumSpacing.xxs),
                    Text(
                      DateFormat.yMMMd().format(milestoneDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PawlumColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PawlumSpacing.lg),
        Text(
          'We’ll create their private profile and an editable first memory.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: PawlumSpacing.xl),
        Obx(
          () => _BackNextRow(
            onBack: controller.back,
            nextLabel: 'Create ${_petName(draft)}’s journal',
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
      children: [
        PawlumGhostButton(
          label: 'Back',
          onPressed: isLoading ? null : () => unawaited(onBack()),
        ),
        const SizedBox(width: PawlumSpacing.sm),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: PawlumPrimaryButton(
              label: nextLabel,
              isLoading: isLoading,
              onPressed: () => unawaited(onNext()),
            ),
          ),
        ),
      ],
    );
  }
}

int _progressFor(PetOnboardingQuestion question) {
  return switch (question) {
    PetOnboardingQuestion.welcome => 0,
    PetOnboardingQuestion.name => 1,
    PetOnboardingQuestion.type || PetOnboardingQuestion.customType => 2,
    PetOnboardingQuestion.birthday => 3,
    PetOnboardingQuestion.firstMetDate => 4,
    PetOnboardingQuestion.photo => 5,
    PetOnboardingQuestion.confirmation => 6,
  };
}

String _petName(PetOnboardingDraft draft) {
  final name = draft.name.trim();
  return name.isEmpty ? 'your pet' : name;
}

String _typeLabel(PetType? type) => switch (type) {
  PetType.dog => 'Dog',
  PetType.cat => 'Cat',
  PetType.bird => 'Bird',
  PetType.rabbit => 'Rabbit',
  PetType.other => 'Other',
  null => 'Pet',
};

IconData _typeIcon(PetType type) => switch (type) {
  PetType.dog => Icons.pets_rounded,
  PetType.cat => Icons.pets_outlined,
  PetType.bird => Icons.flutter_dash_rounded,
  PetType.rabbit => Icons.cruelty_free_rounded,
  PetType.other => Icons.favorite_outline_rounded,
};
