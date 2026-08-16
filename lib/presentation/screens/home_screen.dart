import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/placement_provider.dart';
import '../../core/theme/theme.dart';
import '../../data/models/placement_update.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlacementProvider>(context);

    // Latest Update
    final PlacementUpdate? latest = provider.updates.isNotEmpty ? provider.updates.first : null;

    final lastSyncText = provider.lastSyncTime != null
        ? "${provider.lastSyncTime!.hour.toString().padLeft(2, '0')}:${provider.lastSyncTime!.minute.toString().padLeft(2, '0')}"
        : "Never";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ptracker"),
        actions: [
          IconButton(
            icon: provider.isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryNeon),
                  )
                : const Icon(Icons.refresh),
            onPressed: provider.isSyncing ? null : () => provider.syncData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.syncData(),
        color: AppTheme.primaryNeon,
        backgroundColor: AppTheme.darkSurface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header label
                Center(
                  child: Text(
                    "TOTAL SHORTLISTS",
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Large Heart-Rate style Circular Dashboard (Screen 3 style)
                CircularDashboard(
                  totalShortlists: provider.updates.length,
                  statusText: provider.isSyncing ? "Syncing..." : "Monitoring",
                  subText: "Last Synced: $lastSyncText",
                  isSyncing: provider.isSyncing,
                ),
                const SizedBox(height: 32),

                // Status Banner or Error message
                if (provider.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.errorRed.withOpacity(0.2), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.errorRed, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: AppTheme.errorRed, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Latest Alert Banner
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Latest shortlists",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                    ),
                    if (provider.updates.isNotEmpty)
                      Text(
                        "1 of ${provider.updates.length}",
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (latest != null)
                  _buildLatestUpdateCard(context, latest)
                else
                  _buildEmptyState(context, provider),
                
                const SizedBox(height: 24),

                // Background service tip card (Pill styled like Screen tips)
                _buildTipCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLatestUpdateCard(BuildContext context, PlacementUpdate update) {
    final Color badgeColor = _getStatusColor(update.status);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(update: update),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderMuted, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    update.companyName,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    update.status.toUpperCase(),
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              update.emailSubject,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              update.snippet,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(update.dateReceived),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (update.hasExcelAttachment)
                  Row(
                    children: [
                      Icon(Icons.table_chart_outlined, color: AppTheme.primaryNeon.withOpacity(0.8), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "Excel Shortlist",
                        style: TextStyle(color: AppTheme.primaryNeon.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, PlacementProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderMuted, width: 1),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 40,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            "No Placements Found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "No placement shortlisting emails matching your details were found in your inbox.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: provider.isSyncing ? null : () => provider.syncData(),
            child: const Text("Perform Sync"),
          )
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderMuted, width: 1),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flash_on, color: AppTheme.primaryNeon, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Background Fetching Active",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "To receive instant shortlist alerts, ensure battery optimization is set to Unrestricted in your system settings.",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        ],
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

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]} ${date.year} • ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}

// Custom gauge style widget matching Screen 3 layout
class CircularDashboard extends StatelessWidget {
  final int totalShortlists;
  final String statusText;
  final String subText;
  final bool isSyncing;

  const CircularDashboard({
    super.key,
    required this.totalShortlists,
    required this.statusText,
    required this.subText,
    required this.isSyncing,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 240,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: const Size(240, 220),
              painter: GaugePainter(isSyncing: isSyncing),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Indicator status (ZONE 3 style)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNeon.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryNeon.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryNeon,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.primaryNeon,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Large statistic number
                Text(
                  "$totalShortlists",
                  style: const TextStyle(
                    fontSize: 76,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                // Subtitle
                Text(
                  subText.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// Custom Painter to draw Screen 3's circular progress arc
class GaugePainter extends CustomPainter {
  final bool isSyncing;

  GaugePainter({required this.isSyncing});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 5);
    final radius = size.width / 2 - 16;

    final basePaint = Paint()
      ..color = const Color(0xFF1B202D) // Dark blue-grey base arc
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = AppTheme.primaryNeon // Clean cyan active arc
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Start angle is at 135 degrees (2.35 rad) and sweeps 270 degrees (4.71 rad)
    const double startAngle = 2.35;
    const double sweepAngle = 4.71;

    // Base Arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      basePaint,
    );

    // Active progress arc
    final double progressPct = isSyncing ? 0.9 : 0.65;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progressPct,
      false,
      progressPaint,
    );

    // Indicator dot
    final double endAngle = startAngle + (sweepAngle * progressPct);
    final double dotX = center.dx + radius * cos(endAngle);
    final double dotY = center.dy + radius * sin(endAngle);

    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(dotX, dotY), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
