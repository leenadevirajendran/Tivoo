/// Backend configuration.
///
/// The app connects to the Tivoo backend via [baseUrl].
/// Default:
/// - Temporary live cloud server hosted on Render: https://tivoo-backend.onrender.com
/// - Custom: `flutter run --dart-define=TIVOO_API_URL=http://<IP_OR_DOMAIN>:8080`
class ApiConfig {
  ApiConfig._();

  static const String _envUrl = String.fromEnvironment('TIVOO_API_URL');

  /// Live temporary server hosted on Render
  static const String renderBackendUrl = 'https://tivoo-backend.onrender.com';

  static String get baseUrl {
    if (_envUrl.isNotEmpty) return _envUrl;
    return renderBackendUrl;
  }

  static bool get hasBackend => true;

  /// Largest video accepted for upload (matches the server limit).
  static const int maxUploadBytes = 2 * 1024 * 1024 * 1024;
}
