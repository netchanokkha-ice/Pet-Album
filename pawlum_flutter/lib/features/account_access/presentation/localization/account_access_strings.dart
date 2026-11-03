import 'package:flutter/widgets.dart';

import '../../../../l10n/app_localizations.dart';

class AccountAccessStrings {
  const AccountAccessStrings._(this._values);

  factory AccountAccessStrings.of(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AccountAccessStrings._(<String, String>{
      'eyebrow': strings.eyebrow,
      'sign_in_title': strings.sign_in_title,
      'sign_in_body': strings.sign_in_body,
      'sign_in_action': strings.sign_in_action,
      'show_sign_up': strings.show_sign_up,
      'forgot_password': strings.forgot_password,
      'google_sign_in': strings.google_sign_in,
      'sign_up_title': strings.sign_up_title,
      'sign_up_body': strings.sign_up_body,
      'sign_up_action': strings.sign_up_action,
      'show_sign_in': strings.show_sign_in,
      'verification_title': strings.verification_title,
      'verification_body': strings.verification_body,
      'resend_verification': strings.resend_verification,
      'forgot_title': strings.forgot_title,
      'forgot_body': strings.forgot_body,
      'recovery_action': strings.recovery_action,
      'recovery_title': strings.recovery_title,
      'recovery_body': strings.recovery_body,
      'email_label': strings.email_label,
      'password_label': strings.password_label,
      'show_password': strings.show_password,
      'hide_password': strings.hide_password,
      'email_required': strings.email_required,
      'email_invalid': strings.email_invalid,
      'password_required': strings.password_required,
      'password_short': strings.password_short,
      'account_success_signed_in': strings.account_success_signed_in,
      'account_success_verification_sent':
          strings.account_success_verification_sent,
      'account_error_invalid_credentials':
          strings.account_error_invalid_credentials,
      'account_error_email_in_use': strings.account_error_email_in_use,
      'account_error_email_unverified': strings.account_error_email_unverified,
      'account_error_session_expired': strings.account_error_session_expired,
      'account_error_rate_limited': strings.account_error_rate_limited,
      'account_error_network': strings.account_error_network,
      'account_error_unexpected': strings.account_error_unexpected,
    });
  }

  final Map<String, String> _values;

  String text(String key) => _values[key] ?? key;
}
