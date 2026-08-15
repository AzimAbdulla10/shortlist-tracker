class PlacementUpdate {
  final String gmailMessageId;
  final String companyName;
  final String emailSubject;
  final DateTime dateReceived;
  final String snippet;
  final String status; // Shortlisted, Test, PPT, Interview, Offered, Unknown
  final bool hasExcelAttachment;

  PlacementUpdate({
    required this.gmailMessageId,
    required this.companyName,
    required this.emailSubject,
    required this.dateReceived,
    required this.snippet,
    required this.status,
    required this.hasExcelAttachment,
  });

  Map<String, dynamic> toMap() {
    return {
      'gmailMessageId': gmailMessageId,
      'companyName': companyName,
      'emailSubject': emailSubject,
      'dateReceived': dateReceived.millisecondsSinceEpoch,
      'snippet': snippet,
      'status': status,
      'hasExcelAttachment': hasExcelAttachment ? 1 : 0,
    };
  }

  factory PlacementUpdate.fromMap(Map<String, dynamic> map) {
    return PlacementUpdate(
      gmailMessageId: map['gmailMessageId'] as String,
      companyName: map['companyName'] as String,
      emailSubject: map['emailSubject'] as String,
      dateReceived: DateTime.fromMillisecondsSinceEpoch(map['dateReceived'] as int),
      snippet: map['snippet'] as String,
      status: map['status'] as String,
      hasExcelAttachment: (map['hasExcelAttachment'] as int) == 1,
    );
  }

  PlacementUpdate copyWith({
    String? gmailMessageId,
    String? companyName,
    String? emailSubject,
    DateTime? dateReceived,
    String? snippet,
    String? status,
    bool? hasExcelAttachment,
  }) {
    return PlacementUpdate(
      gmailMessageId: gmailMessageId ?? this.gmailMessageId,
      companyName: companyName ?? this.companyName,
      emailSubject: emailSubject ?? this.emailSubject,
      dateReceived: dateReceived ?? this.dateReceived,
      snippet: snippet ?? this.snippet,
      status: status ?? this.status,
      hasExcelAttachment: hasExcelAttachment ?? this.hasExcelAttachment,
    );
  }
}
