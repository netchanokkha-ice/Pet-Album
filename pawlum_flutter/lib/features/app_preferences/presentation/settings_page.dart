import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/pawlum_tokens.dart';
import '../../../core/widgets/pawlum_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../account_access/domain/entities/account_identity.dart';
import '../../app_shell/presentation/controllers/app_shell_controller.dart';
import '../domain/app_language.dart';
import 'settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SafeArea(
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: PawlumSkeleton(
              width: 260,
              height: 24,
              semanticLabel: strings.settings_loading,
            ),
          );
        }
        final identity = controller.account.value;
        if (identity == null) {
          return _SettingsFailure(
            message: strings.settings_error_load,
            onRetry: controller.load,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            PawlumSpacing.md,
            PawlumSpacing.lg,
            PawlumSpacing.md,
            PawlumSpacing.xxl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    strings.settings_title,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: PawlumSpacing.xxs),
                  Text(
                    strings.settings_body,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: PawlumColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: PawlumSpacing.lg),
                  if (controller.error.value != null)
                    _SettingsNotice(
                      icon: Icons.error_outline_rounded,
                      message: _errorMessage(strings, controller.error.value!),
                      isError: true,
                    ),
                  if (controller.passwordEmailSent.value)
                    _SettingsNotice(
                      icon: Icons.mark_email_read_outlined,
                      message: strings.settings_password_email_sent,
                    ),
                  _SettingsCard(
                    title: strings.settings_account_title,
                    icon: Icons.account_circle_outlined,
                    child: _AccountDetails(identity: identity),
                  ),
                  const SizedBox(height: PawlumSpacing.md),
                  _SettingsCard(
                    title: strings.settings_language_title,
                    icon: Icons.translate_rounded,
                    child: Semantics(
                      label: strings.a11y_settings_language,
                      child: SegmentedButton<AppLanguage>(
                        segments: [
                          ButtonSegment<AppLanguage>(
                            value: AppLanguage.thai,
                            label: Text(strings.settings_language_thai),
                          ),
                          ButtonSegment<AppLanguage>(
                            value: AppLanguage.english,
                            label: Text(strings.settings_language_english),
                          ),
                        ],
                        selected: <AppLanguage>{controller.language},
                        onSelectionChanged: controller.isSavingLanguage.value
                            ? null
                            : (selection) =>
                                  controller.changeLanguage(selection.single),
                      ),
                    ),
                  ),
                  const SizedBox(height: PawlumSpacing.md),
                  _SettingsCard(
                    title: strings.settings_journal_title,
                    icon: Icons.auto_stories_outlined,
                    child: _SettingsAction(
                      icon: Icons.restore_from_trash_rounded,
                      label: strings.settings_recently_deleted,
                      onTap: controller.onOpenRecentlyDeleted,
                    ),
                  ),
                  const SizedBox(height: PawlumSpacing.lg),
                  PawlumGhostButton(
                    label: strings.settings_sign_out,
                    icon: Icons.logout_rounded,
                    onPressed: controller.isSigningOut.value
                        ? null
                        : () => _confirmSignOut(context),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final pendingDraftCount =
        Get.find<AppShellController>().readiness.value?.pendingDraftCount;
    if ((pendingDraftCount ?? 0) > 0) {
      final strings = AppLocalizations.of(context);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.settings_sign_out_pending_title),
          content: Text(strings.settings_sign_out_pending_body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.settings_sign_out_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.settings_sign_out_keep_draft),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await controller.signOut();
  }

  String _errorMessage(AppLocalizations strings, SettingsError error) {
    return switch (error.type) {
      SettingsErrorType.load => strings.settings_error_load,
      SettingsErrorType.saveLanguage => strings.settings_error_save_language,
      SettingsErrorType.signOut => strings.settings_error_sign_out,
      SettingsErrorType.account => strings.account_error_unexpected,
    };
  }
}

class _AccountDetails extends GetView<SettingsController> {
  const _AccountDetails({required this.identity});

  final AccountIdentity identity;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (identity.displayName case final displayName?
            when displayName.trim().isNotEmpty)
          _AccountRow(label: strings.settings_display_name, value: displayName),
        _AccountRow(label: strings.settings_email, value: identity.email),
        const SizedBox(height: PawlumSpacing.sm),
        Wrap(
          spacing: PawlumSpacing.xs,
          runSpacing: PawlumSpacing.xs,
          children: [
            Chip(
              avatar: const Icon(Icons.verified_outlined, size: 18),
              label: Text(
                identity.isEmailVerified
                    ? strings.settings_verified
                    : strings.settings_unverified,
              ),
            ),
            for (final method in identity.authMethods)
              Chip(
                label: Text(switch (method) {
                  AccountAuthMethod.emailPassword =>
                    strings.settings_auth_email_password,
                  AccountAuthMethod.google => strings.settings_auth_google,
                }),
              ),
          ],
        ),
        if (controller.supportsPasswordAction) ...[
          const SizedBox(height: PawlumSpacing.md),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: PawlumGhostButton(
              label: strings.settings_change_password,
              icon: Icons.password_rounded,
              onPressed: controller.isRequestingPassword.value
                  ? null
                  : controller.requestPasswordChange,
            ),
          ),
        ],
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: PawlumSpacing.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: PawlumColors.inkMuted),
          ),
        ),
        Expanded(child: SelectableText(value)),
      ],
    ),
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: PawlumColors.paper,
      borderRadius: BorderRadius.circular(PawlumRadii.card),
      border: Border.all(color: PawlumColors.outline),
    ),
    child: Padding(
      padding: const EdgeInsets.all(PawlumSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: PawlumColors.pinkStrong),
              const SizedBox(width: PawlumSpacing.xs),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: PawlumSpacing.md),
          child,
        ],
      ),
    ),
  );
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: PawlumColors.purpleStrong),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    ),
  );
}

class _SettingsNotice extends StatelessWidget {
  const _SettingsNotice({
    required this.icon,
    required this.message,
    this.isError = false,
  });

  final IconData icon;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: PawlumSpacing.md),
    child: Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isError ? const Color(0xFFF9DEDC) : PawlumColors.mint,
          borderRadius: BorderRadius.circular(PawlumRadii.control),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PawlumSpacing.sm),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: PawlumSpacing.xs),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SettingsFailure extends StatelessWidget {
  const _SettingsFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        const SizedBox(height: PawlumSpacing.md),
        PawlumPrimaryButton(
          label: AppLocalizations.of(context).action_retry,
          onPressed: onRetry,
        ),
      ],
    ),
  );
}
