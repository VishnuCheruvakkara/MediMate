import 'package:flutter/foundation.dart';

/// Public, build-time Flutter configuration.
///
/// Values compiled into a mobile app are readable by its users. Never add a
/// database password, backend signing key, or third-party private key here.
abstract final class AppConfig {
  static const _configuredApiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get apiBaseUrl {
    if (_configuredApiBaseUrl.isNotEmpty) return _configuredApiBaseUrl;
    return kIsWeb ? 'http://127.0.0.1:8000' : 'http://10.0.2.2:8000';
  }

  static const environment = String.fromEnvironment(
    'APP_ENVIRONMENT',
    defaultValue: 'development',
  );
}
