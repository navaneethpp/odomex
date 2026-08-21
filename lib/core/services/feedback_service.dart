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

  /// Builds the properly encoded `mailto:` URI for user reviews.
  static Uri get feedbackMailtoUri {
    return Uri(
      scheme: 'mailto',
      path: feedbackEmail,
      queryParameters: {
        'subject': feedbackSubject,
        'body': feedbackBody,
      },
    );
  }

  /// Opens the device's default email client addressed to [feedbackEmail].
  ///
  /// Displays a friendly SnackBar message if no email application is available.
  static Future<bool> sendFeedback({BuildContext? context}) async {
    final uri = feedbackMailtoUri;
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
