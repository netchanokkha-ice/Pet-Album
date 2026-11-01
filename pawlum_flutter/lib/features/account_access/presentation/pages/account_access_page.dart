import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/pawlum_tokens.dart';
import '../../../../core/widgets/pawlum_widgets.dart';
import '../controllers/account_access_controller.dart';
import '../localization/account_access_strings.dart';

class AccountAccessPage extends GetView<AccountAccessController> {
  const AccountAccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AccountAccessStrings.of(context);
    return Scaffold(
      body: PawlumPaperBackground(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: PawlumColors.paper,
                  borderRadius: BorderRadius.circular(PawlumRadii.sheet),
                  border: Border.all(color: PawlumColors.outline),
                  boxShadow: PawlumShadows.paper,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(PawlumSpacing.lg),
                  child: Obx(
                    () => AnimatedSwitcher(
                      duration: PawlumMotion.standard,
                      child: _StepContent(
                        key: ValueKey(controller.step.value),
                        step: controller.step.value,
                        controller: controller,
                        strings: strings,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({
    required this.step,
    required this.controller,
    required this.strings,
    super.key,
  });

  final AccountAccessStep step;
  final AccountAccessController controller;
  final AccountAccessStrings strings;

  @override
  Widget build(BuildContext context) => switch (step) {
    AccountAccessStep.signIn => _CredentialsForm(
      title: strings.text('sign_in_title'),
      body: strings.text('sign_in_body'),
      actionLabel: strings.text('sign_in_action'),
      strings: strings,
      controller: controller,
      onSubmit: controller.signIn,
      secondaryActions: [
        TextButton(
          onPressed: controller.showSignUp,
          child: Text(strings.text('show_sign_up')),
        ),
        TextButton(
          onPressed: controller.showForgotPassword,
          child: Text(strings.text('forgot_password')),
        ),
      ],
    ),
    AccountAccessStep.signUp => _CredentialsForm(
      title: strings.text('sign_up_title'),
      body: strings.text('sign_up_body'),
      actionLabel: strings.text('sign_up_action'),
      strings: strings,
      controller: controller,
      onSubmit: controller.signUp,
      secondaryActions: [
        TextButton(
          onPressed: controller.showSignIn,
          child: Text(strings.text('show_sign_in')),
        ),
      ],
    ),
    AccountAccessStep.verificationPending => _ResultContent(
      icon: Icons.mark_email_unread_rounded,
      title: strings.text('verification_title'),
      message:
          '${strings.text('verification_body')}\n${controller.pendingEmail.value}',
      controller: controller,
      primaryLabel: strings.text('resend_verification'),
      onPrimary: controller.resendVerification,
      secondaryLabel: strings.text('show_sign_in'),
      onSecondary: controller.showSignIn,
      strings: strings,
    ),
    AccountAccessStep.forgotPassword => _RecoveryForm(
      strings: strings,
      controller: controller,
    ),
    AccountAccessStep.recoveryResult => _ResultContent(
      icon: Icons.forward_to_inbox_rounded,
      title: strings.text('recovery_title'),
      message: strings.text('recovery_body'),
      controller: controller,
      primaryLabel: strings.text('show_sign_in'),
      onPrimary: controller.showSignIn,
      strings: strings,
    ),
  };
}

class _CredentialsForm extends StatefulWidget {
  const _CredentialsForm({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.strings,
    required this.controller,
    required this.onSubmit,
    required this.secondaryActions,
  });

  final String title;
  final String body;
  final String actionLabel;
  final AccountAccessStrings strings;
  final AccountAccessController controller;
  final Future<void> Function({required String email, required String password})
  onSubmit;
  final List<Widget> secondaryActions;

  @override
  State<_CredentialsForm> createState() => _CredentialsFormState();
}

class _CredentialsFormState extends State<_CredentialsForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(
            title: widget.title,
            body: widget.body,
            strings: widget.strings,
          ),
          const SizedBox(height: PawlumSpacing.lg),
          TextFormField(
            key: const Key('account-email-field'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: widget.strings.text('email_label'),
              prefixIcon: const Icon(Icons.alternate_email_rounded),
            ),
            validator: (value) => _validateEmail(value, widget.strings),
          ),
          const SizedBox(height: PawlumSpacing.md),
          TextFormField(
            key: const Key('account-password-field'),
            controller: _passwordController,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: widget.strings.text('password_label'),
              prefixIcon: const Icon(Icons.lock_outline_rounded),
            ),
            validator: (value) => _validatePassword(value, widget.strings),
          ),
          const SizedBox(height: PawlumSpacing.md),
          _Feedback(controller: widget.controller, strings: widget.strings),
          const SizedBox(height: PawlumSpacing.md),
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => PawlumPrimaryButton(
                label: widget.actionLabel,
                isLoading: widget.controller.isLoading.value,
                onPressed: () {
                  if (_formKey.currentState?.validate() != true) return;
                  widget.onSubmit(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: PawlumSpacing.xs),
          Wrap(
            alignment: WrapAlignment.center,
            children: widget.secondaryActions,
          ),
          if (widget.controller.googleOAuthAvailable) ...[
            const SizedBox(height: PawlumSpacing.xs),
            SizedBox(
              width: double.infinity,
              child: PawlumGhostButton(
                label: widget.strings.text('google_sign_in'),
                icon: Icons.g_mobiledata_rounded,
                onPressed: widget.controller.beginGoogleSignIn,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecoveryForm extends StatefulWidget {
  const _RecoveryForm({required this.strings, required this.controller});

  final AccountAccessStrings strings;
  final AccountAccessController controller;

  @override
  State<_RecoveryForm> createState() => _RecoveryFormState();
}

class _RecoveryFormState extends State<_RecoveryForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(
          title: widget.strings.text('forgot_title'),
          body: widget.strings.text('forgot_body'),
          strings: widget.strings,
        ),
        const SizedBox(height: PawlumSpacing.lg),
        TextFormField(
          key: const Key('recovery-email-field'),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: widget.strings.text('email_label'),
            prefixIcon: const Icon(Icons.alternate_email_rounded),
          ),
          validator: (value) => _validateEmail(value, widget.strings),
        ),
        const SizedBox(height: PawlumSpacing.md),
        _Feedback(controller: widget.controller, strings: widget.strings),
        const SizedBox(height: PawlumSpacing.md),
        SizedBox(
          width: double.infinity,
          child: Obx(
            () => PawlumPrimaryButton(
              label: widget.strings.text('recovery_action'),
              isLoading: widget.controller.isLoading.value,
              onPressed: () {
                if (_formKey.currentState?.validate() != true) return;
                widget.controller.requestRecovery(email: _emailController.text);
              },
            ),
          ),
        ),
        TextButton(
          onPressed: widget.controller.showSignIn,
          child: Text(widget.strings.text('show_sign_in')),
        ),
      ],
    ),
  );
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({
    required this.icon,
    required this.title,
    required this.message,
    required this.controller,
    required this.primaryLabel,
    required this.onPrimary,
    required this.strings,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String message;
  final AccountAccessController controller;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final AccountAccessStrings strings;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      PawlumPetPlaceholder(semanticLabel: title, icon: icon, size: 88),
      const SizedBox(height: PawlumSpacing.lg),
      Text(title, style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: PawlumSpacing.xs),
      Text(message, textAlign: TextAlign.center),
      const SizedBox(height: PawlumSpacing.md),
      _Feedback(controller: controller, strings: strings),
      const SizedBox(height: PawlumSpacing.md),
      Obx(
        () => PawlumPrimaryButton(
          label: primaryLabel,
          isLoading: controller.isLoading.value,
          onPressed: onPrimary,
        ),
      ),
      if (secondaryLabel != null)
        TextButton(onPressed: onSecondary, child: Text(secondaryLabel!)),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.body,
    required this.strings,
  });

  final String title;
  final String body;
  final AccountAccessStrings strings;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      PawlumWashiTape(label: strings.text('eyebrow'), width: 168),
      const SizedBox(height: PawlumSpacing.lg),
      Text(title, style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: PawlumSpacing.xs),
      Text(body, textAlign: TextAlign.center),
    ],
  );
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.controller, required this.strings});

  final AccountAccessController controller;
  final AccountAccessStrings strings;

  @override
  Widget build(BuildContext context) => Obx(() {
    final key = controller.errorKey.value ?? controller.noticeKey.value;
    if (key == null) return const SizedBox.shrink();
    final isError = controller.errorKey.value != null;
    return Semantics(
      liveRegion: true,
      child: Text(
        strings.text(key),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isError
              ? Theme.of(context).colorScheme.error
              : PawlumColors.purpleStrong,
        ),
      ),
    );
  });
}

String? _validateEmail(String? value, AccountAccessStrings strings) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return strings.text('email_required');
  final separator = email.indexOf('@');
  if (separator <= 0 ||
      separator == email.length - 1 ||
      !email.substring(separator).contains('.')) {
    return strings.text('email_invalid');
  }
  return null;
}

String? _validatePassword(String? value, AccountAccessStrings strings) {
  if (value == null || value.isEmpty) return strings.text('password_required');
  if (value.length < 8) return strings.text('password_short');
  return null;
}
