import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/constants.dart';
import '../../core/theme/theme.dart';
import '../../data/models/placement_update.dart';

class DetailScreen extends StatelessWidget {
  final PlacementUpdate update;

  const DetailScreen({super.key, required this.update});

  Future<void> _openGmailMessage(BuildContext context) async {
    final String urlStr = AppConstants.getGmailWebUrl(update.gmailMessageId);
    final Uri url = Uri.parse(urlStr);
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to open email. Link: $urlStr"),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text("PTRACKER"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "SHORTLIST DETAILS" Header
              const Text(
                "SHORTLIST DETAILS",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),

              // Company Header (Big & bold Bauhaus)
              Text(
                update.companyName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Selection Round Row
              _buildDetailRow(
                context: context,
                label: "SELECTION ROUND",
                value: update.status.toUpperCase(),
                icon: Icons.help_outline_rounded,
                bgColor: AppTheme.surfaceWhite,
              ),
              const SizedBox(height: 12),

              // Date Received Row
              _buildDetailRow(
                context: context,
                label: "DATE RECEIVED",
                value: _formatDate(update.dateReceived).toUpperCase(),
                icon: Icons.calendar_today_outlined,
                bgColor: AppTheme.surfaceWhite,
              ),
              const SizedBox(height: 12),

              // Spreadsheet Row (Yellow if attached)
              _buildDetailRow(
                context: context,
                label: "SPREADSHEET",
                value: update.hasExcelAttachment ? "ATTACHED" : "NONE",
                icon: Icons.table_chart_outlined,
                bgColor: update.hasExcelAttachment ? AppTheme.accentYellow : AppTheme.surfaceWhite,
              ),
              const SizedBox(height: 28),

              // COMMUNICATION DETAILS Box
              _buildSectionLabel("COMMUNICATION DETAILS"),
              const SizedBox(height: 8),

              NeoBox(
                borderWidth: 2.5,
                shadowOffset: 4.0,
                backgroundColor: AppTheme.surfaceWhite,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "SUBJECT",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      update.emailSubject,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "EMAIL SNIPPET",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.bgCream.withOpacity(0.4),
                        border: Border.all(color: AppTheme.borderBlack, width: 1.5),
                      ),
                      child: Text(
                        update.snippet,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Blue NeoButton "OPEN IN GMAIL"
              NeoButton(
                backgroundColor: AppTheme.accentBlue,
                onTap: () => _openGmailMessage(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mail_outline, color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text(
                      "OPEN IN GMAIL",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
    );
  }

  // Labeled Row widget matching Bauhaus Screen 4
  Widget _buildDetailRow({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color bgColor,
  }) {
    return NeoBox(
      borderWidth: 2.5,
      shadowOffset: 0.0,
      backgroundColor: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Icon(icon, color: AppTheme.textPrimary, size: 20),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
