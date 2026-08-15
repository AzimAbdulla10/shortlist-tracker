class AppConstants {
  // Gmail query constants
  static const String defaultCdcSender = 'cdc_sender@example.com';
  static const String defaultPlacementId = 'YOUR_PLACEMENT_ID';

  // Secure Storage keys
  static const String keyPlacementId = 'placement_id';
  static const String keyCdcSender = 'cdc_sender';
  static const String keyUserEmail = 'user_email';

  // Gmail API scopes
  static const List<String> gmailScopes = [
    'https://www.googleapis.com/auth/gmail.readonly',
  ];

  // Helper for deep links to Gmail message
  static String getGmailWebUrl(String messageId) {
    return 'https://mail.google.com/mail/u/0/#inbox/$messageId';
  }
}
