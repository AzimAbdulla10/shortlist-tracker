import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:http/http.dart' as http;
import '../../data/models/placement_update.dart';

class AuthenticatedClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  AuthenticatedClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}

class GmailService {
  // Fetch matching placement updates from Gmail
  Future<List<PlacementUpdate>> fetchPlacementUpdates({
    required Map<String, String> authHeaders,
    required String placementId,
    required String cdcSender,
  }) async {
    final client = AuthenticatedClient(authHeaders);
    final gmailApi = GmailApi(client);
    final List<PlacementUpdate> updates = [];

    try {
      // Build the query: "from:vitianscdc2027@vitstudent.ac.in I1F1A6M5"
      final String query = 'from:$cdcSender $placementId';
      debugPrint("Searching Gmail with query: '$query'");

      final ListMessagesResponse response = await gmailApi.users.messages.list(
        'me',
        q: query,
        maxResults: 50, // Keep it light
      );

      final messages = response.messages;
      if (messages == null || messages.isEmpty) {
        debugPrint("No placement emails found.");
        return [];
      }

      for (final msgRef in messages) {
        final String? msgId = msgRef.id;
        if (msgId == null) continue;

        try {
          // Fetch full message details
          final Message msg = await gmailApi.users.messages.get('me', msgId, format: 'full');
          final update = _parseGmailMessage(msg);
          if (update != null) {
            updates.add(update);
          }
        } catch (e) {
          debugPrint("Error fetching details for message $msgId: $e");
        }
      }
    } catch (e) {
      debugPrint("Error list messages: $e");
      rethrow;
    } finally {
      client.close();
    }

    return updates;
  }

  // Parse a raw Gmail Message into a PlacementUpdate
  PlacementUpdate? _parseGmailMessage(Message msg) {
    final String? messageId = msg.id;
    if (messageId == null) return null;

    final String snippet = msg.snippet ?? '';
    final String internalDateStr = msg.internalDate ?? '0';
    final DateTime dateReceived = DateTime.fromMillisecondsSinceEpoch(
      int.tryParse(internalDateStr) ?? 0,
    );

    // Extract headers
    final headers = msg.payload?.headers ?? [];
    String subject = '';
    for (final header in headers) {
      if (header.name?.toLowerCase() == 'subject') {
        subject = header.value ?? '';
        break;
      }
    }

    // Determine if email has Excel attachment
    final bool hasExcel = _checkForExcelAttachments(msg.payload);

    // Extract company name and status
    final String companyName = _extractCompanyName(subject, snippet);
    final String status = _detectStatus(subject, snippet);

    return PlacementUpdate(
      gmailMessageId: messageId,
      companyName: companyName,
      emailSubject: subject,
      dateReceived: dateReceived,
      snippet: snippet,
      status: status,
      hasExcelAttachment: hasExcel,
    );
  }

  // Recursively inspect parts for .xlsx attachments
  bool _checkForExcelAttachments(MessagePart? part) {
    if (part == null) return false;

    final String? filename = part.filename;
    if (filename != null && filename.toLowerCase().endsWith('.xlsx')) {
      return true;
    }

    final parts = part.parts;
    if (parts != null && parts.isNotEmpty) {
      for (final subPart in parts) {
        if (_checkForExcelAttachments(subPart)) {
          return true;
        }
      }
    }

    return false;
  }

  // Heuristically extract the company name from the subject or snippet
  String _extractCompanyName(String subject, String snippet) {
    if (subject.isEmpty) return 'Unknown Company';

    // Remove common prefixes
    String cleaned = subject
        .replaceAll(RegExp(r'^(Fwd:|Re:|Urgent:|Fw:|Notification:)\s*', caseSensitive: false), '')
        .trim();

    // Pattern 1: Company | Job Profile or Company | Shortlist
    if (cleaned.contains('|')) {
      final parts = cleaned.split('|');
      final possibleCompany = parts[0].trim();
      if (possibleCompany.isNotEmpty) return _cleanWord(possibleCompany);
    }

    // Pattern 2: Company - Job Profile
    if (cleaned.contains(' - ')) {
      final parts = cleaned.split(' - ');
      final possibleCompany = parts[0].trim();
      if (possibleCompany.isNotEmpty) return _cleanWord(possibleCompany);
    }

    // Pattern 3: "Recruitment Process of [Company]" or "Placement Drive of [Company]"
    final driveRegex = RegExp(
      r'(Recruitment Process|Placement Drive|Shortlist|Campus Drive|Hiring) (of|for|at)\s+([A-Za-z0-9\s]+)',
      caseSensitive: false,
    );
    final match = driveRegex.firstMatch(cleaned);
    if (match != null && match.groupCount >= 3) {
      final possibleCompany = match.group(3)!.trim();
      // Take first 2-3 words of the captured string to avoid swallowing action verbs
      final words = possibleCompany.split(' ');
      if (words.isNotEmpty) {
        return words.take(3).join(' ');
      }
    }

    // Pattern 4: "[Company] Shortlist" or "[Company] Recruitment"
    final words = cleaned.split(' ');
    if (words.length >= 2) {
      final firstTwoWords = words.take(2).join(' ');
      // If the second word is a filler/common cdc term, just use the first word
      final commonCdcKeywords = {'shortlist', 'recruitment', 'hiring', 'online', 'test', 'process', 'placement', 'selection'};
      if (commonCdcKeywords.contains(words[1].toLowerCase())) {
        return words[0];
      }
      return firstTwoWords;
    }

    return cleaned.isNotEmpty ? cleaned : 'Unknown Company';
  }

  // Clean common trailing characters
  String _cleanWord(String text) {
    return text.replaceAll(RegExp(r'[^\w\s\.\-\&\(\)]'), '').trim();
  }

  // Detect status / type of shortlist update
  String _detectStatus(String subject, String snippet) {
    final text = '$subject $snippet'.toLowerCase();

    if (text.contains('congratulations') ||
        text.contains('offer letter') ||
        text.contains('placed') ||
        text.contains('selected')) {
      return 'Offered';
    }

    if (text.contains('interview') || text.contains('gd') || text.contains('discussion')) {
      return 'Interview';
    }

    if (text.contains('online test') ||
        text.contains('assessment') ||
        text.contains('coding test') ||
        text.contains('exam') ||
        text.contains('hackerearth') ||
        text.contains('mcat') ||
        text.contains('cocubes')) {
      return 'Online Test';
    }

    if (text.contains('ppt') || text.contains('pre-placement') || text.contains('presentation')) {
      return 'PPT';
    }

    if (text.contains('shortlist') || text.contains('shortlisted') || text.contains('nominated')) {
      return 'Shortlisted';
    }

    return 'Update';
  }
}
