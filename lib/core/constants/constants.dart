class AppConstants {
  // Gmail query constants
  static const String defaultCdcSender = 'vitianscdc2027@vitstudent.ac.in';
  static const String defaultPlacementId = 'I1F1A6M5';

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
