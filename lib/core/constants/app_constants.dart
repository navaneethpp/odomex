/// Application-wide constants including versioning, official URLs, and policy metadata.
class AppConstants {
  AppConstants._();

  /// Current active Privacy Policy version.
  ///
  /// If the privacy policy is updated with material changes, increment this version
  /// (e.g. to '1.1') to prompt returning users to review and acknowledge the updated policy
  /// without clearing or affecting their local vehicle data.
  static const String currentPrivacyPolicyVersion = '1.0';

  /// Official online Privacy Policy URL for Odomex.
  static const String privacyPolicyUrl = 'https://hexakode.in/odomex/privacy';

  /// Official developer website.
  static const String developerWebsiteUrl = 'https://hexakode.in';

  /// Official developer contact email for reviews and feedback.
  static const String contactEmail = 'contact@hexakode.in';
}
