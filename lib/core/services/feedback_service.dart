import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Centralized service for handling user feedback and reviews via email launcher.
class FeedbackService {
  FeedbackService._();

  /// Primary support and feedback recipient address.
  static const String feedbackEmail = 'contact@hexakode.in';

  /// Default email subject for reviews.
  static const String feedbackSubject = 'Odomex Feedback';

  /// Pre-filled email body template with space for user input.
  static const String feedbackBody =
      'Hi HexaKode Team,\n\nI would like to share my feedback about Odomex.\n\nFeedback:\n';

  /// Encodes query parameters using RFC 3986 percent-encoding (e.g. `%20` for spaces).
  ///
  /// Unlike standard form URL-encoding (which converts spaces to `+`), `mailto:`
  /// query strings require percent-encoding according to RFC 6068 so email
  /// clients (like Gmail, Outlook, and system email apps) preserve spaces and line breaks.
  static String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  /// Builds a properly formatted `mailto:` URI for user reviews and custom feedback.
  static Uri buildFeedbackUri({
    String? subject,
    String? body,
  }) {
    final effectiveSubject = subject ?? feedbackSubject;
    final effectiveBody = body ?? feedbackBody;

    final query = encodeQueryParameters({
      'subject': effectiveSubject,
      'body': effectiveBody,
    });

    return Uri(
      scheme: 'mailto',
      path: feedbackEmail,
      query: query,
    );
  }

  /// Builds the default properly encoded `mailto:` URI for user reviews.
  static Uri get feedbackMailtoUri => buildFeedbackUri();

  /// Opens the device's default email client addressed to [feedbackEmail].
  ///
  /// Displays a friendly SnackBar message if no email application is available.
  static Future<bool> sendFeedback({
    BuildContext? context,
    String? subject,
    String? body,
  }) async {
    final uri = buildFeedbackUri(subject: subject, body: body);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email app is available on this device.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return launched;
    } catch (_) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email app is available on this device.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
  }
}
