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
            action: SnackBarAction(
              label: 'Copy',
              textColor: AppTheme.primaryNeon,
              onPressed: () {
                // Copy logic is optional, but snackbar informs user
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor(update.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shortlist Details"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderMuted, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: statusColor.withOpacity(0.5)),
                          ),
                          child: Text(
                            update.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          _formatFullDate(update.dateReceived),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      update.companyName,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Email Subject
              Text(
                "Subject",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                update.emailSubject,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Divider(height: 32),

              // Email content snippet
              Text(
                "Email Snippet",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderMuted, width: 1),
                ),
                child: Text(
                  update.snippet,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 15,
                        color: AppTheme.textPrimary.withOpacity(0.9),
                      ),
                ),
              ),
              const SizedBox(height: 24),

              // Excel indicator if applicable
              if (update.hasExcelAttachment) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNeon.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryNeon.withOpacity(0.2), width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.table_chart, color: AppTheme.primaryNeon, size: 24),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Spreadsheet Attached",
                              style: TextStyle(
                                color: AppTheme.primaryNeon,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "VIT CDC attached a shortlist Excel sheet. Open the email in Gmail to view or download it.",
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Open in Gmail Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
                icon: const Icon(Icons.mail_outline, color: Colors.black),
                label: const Text("Open Original Email in Gmail"),
                onPressed: () => _openGmailMessage(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'offered':
        return AppTheme.primaryNeon;
      case 'online test':
        return AppTheme.secondaryGold;
      case 'interview':
        return AppTheme.accentTeal;
      case 'ppt':
        return Colors.indigoAccent;
      case 'shortlisted':
        return Colors.lightGreenAccent;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatFullDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]} ${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
