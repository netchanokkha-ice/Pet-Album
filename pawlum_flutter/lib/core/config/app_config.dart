enum AppEnvironment { development, staging, production }

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.useFakeRepositories,
    required this.googleOAuthEnabled,
    required this.oauthRedirectUrl,
  });

  factory AppConfig.fromEnvironment() {
    const environmentName = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );

    return AppConfig(
      environment: AppEnvironment.values.firstWhere(
        (value) => value.name == environmentName,
        orElse: () => AppEnvironment.development,
      ),
      supabaseUrl: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://projowodlrydgzexcald.supabase.co',
      ),
      supabasePublishableKey: const String.fromEnvironment(
        'SUPABASE_PUBLISHABLE_KEY',
      ),
      useFakeRepositories: const bool.fromEnvironment(
        'USE_FAKE_REPOSITORIES',
        defaultValue: true,
      ),
      googleOAuthEnabled: const bool.fromEnvironment(
        'GOOGLE_OAUTH_ENABLED',
        defaultValue: false,
      ),
      oauthRedirectUrl: const String.fromEnvironment(
        'OAUTH_REDIRECT_URL',
        defaultValue: 'pawlum://login-callback',
      ),
    );
  }

  factory AppConfig.test() {
    return const AppConfig(
      environment: AppEnvironment.development,
      supabaseUrl: 'https://projowodlrydgzexcald.supabase.co',
      supabasePublishableKey: '',
      useFakeRepositories: true,
      googleOAuthEnabled: false,
      oauthRedirectUrl: 'pawlum://login-callback',
    );
  }

  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabasePublishableKey;
  final bool useFakeRepositories;
  final bool googleOAuthEnabled;
  final String oauthRedirectUrl;

  bool get isDevelopment => environment == AppEnvironment.development;

  bool get hasSupabaseCredentials =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;

  Uri? get oauthRedirectUri => Uri.tryParse(oauthRedirectUrl);

  bool get googleOAuthConfigured =>
      googleOAuthEnabled && oauthRedirectUri?.hasScheme == true;
}
