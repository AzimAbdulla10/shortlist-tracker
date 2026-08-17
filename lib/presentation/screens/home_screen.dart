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
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text("PTRACKER"),
        actions: [
          IconButton(
            icon: provider.isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.borderBlack),
                  )
                : const Icon(Icons.sync, color: AppTheme.borderBlack),
            onPressed: provider.isSyncing ? null : () => provider.syncData(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.syncData(),
        color: AppTheme.borderBlack,
        backgroundColor: AppTheme.bgCream,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bauhaus Square Tracker Box (Screen 2)
                BauhausDashboard(
                  totalShortlists: provider.updates.length,
                  statusText: provider.isSyncing ? "Syncing..." : "STATUS: MONITORING ACTIVE",
                  subText: "Last Synced: $lastSyncText",
                  isSyncing: provider.isSyncing,
                ),
                const SizedBox(height: 36),

                // Horizontal Quick Actions (Bauhaus style)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAction(
                      context: context,
                      icon: Icons.sync,
                      label: "Sync",
                      onTap: provider.isSyncing ? null : () => provider.syncData(),
                    ),
                    _buildQuickAction(
                      context: context,
                      icon: Icons.filter_list,
                      label: "Filter",
                      onTap: () {
                        // Toggle filters (or open sheet)
                      },
                    ),
                    _buildQuickAction(
                      context: context,
                      icon: Icons.history,
                      label: "History",
                      onTap: () => provider.setTabIndex(1),
                    ),
                    _buildQuickAction(
                      context: context,
                      icon: Icons.settings,
                      label: "Settings",
                      onTap: () => provider.setTabIndex(2),
                    ),
                  ],
                ),
                const SizedBox(height: 36),

                // Error Message banner if any
                if (provider.errorMessage != null) ...[
                  NeoBox(
                    borderWidth: 2.5,
                    shadowOffset: 3.0,
                    backgroundColor: AppTheme.accentRed.withOpacity(0.08),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.accentRed, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Latest Shortlists Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "LATEST SHORTLISTS",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (provider.updates.isNotEmpty)
                      GestureDetector(
                        onTap: () => provider.setTabIndex(1),
                        child: const Text(
                          "VIEW ALL",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.accentBlue,
                            decoration: TextDecoration.underline,
                            decorationThickness: 2.0,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                if (latest != null) ...[
                  _buildLatestUpdateCard(context, latest),
                  if (provider.updates.length > 1) ...[
                    const SizedBox(height: 16),
                    _buildLatestUpdateCard(context, provider.updates[1]),
                  ]
                ] else
                  _buildEmptyState(context, provider),

                const SizedBox(height: 24),
                
                // Tip info card
                _buildTipCard(context),
                const SizedBox(height: 16),
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
      child: NeoBox(
        borderWidth: 3.0,
        shadowOffset: 4.0,
        backgroundColor: AppTheme.surfaceWhite,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    update.companyName.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    border: Border.all(color: AppTheme.borderBlack, width: 2.0),
                  ),
                  child: Text(
                    update.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
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
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              update.snippet,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            // Custom Separator (brutalist dash/border)
            Container(
              height: 2.0,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderBlack, width: 1.5, style: BorderStyle.solid),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(update.dateReceived).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (update.hasExcelAttachment)
                  Row(
                    children: [
                      const Icon(Icons.table_chart, color: AppTheme.textPrimary, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        "1 ATTACHMENT",
                        style: TextStyle(color: AppTheme.textPrimary.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.w900),
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
    return NeoBox(
      borderWidth: 3.0,
      shadowOffset: 4.0,
      backgroundColor: AppTheme.surfaceWhite,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 44,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            "NO PLACEMENTS FOUND",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "No placement shortlisting emails matching your details were found in your inbox.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          NeoButton(
            onTap: provider.isSyncing ? null : () => provider.syncData(),
            child: const Text(
              "SYNC NOW",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context) {
    return NeoBox(
      borderWidth: 2.5,
      shadowOffset: 0.0,
      backgroundColor: AppTheme.surfaceWhite,
      padding: const EdgeInsets.all(18),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.flash_on, color: AppTheme.accentYellow, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BACKGROUND ACTIVE",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Ptracker monitors your emails every 15 mins in the background. Keep your internet enabled for alerts.",
                  style: TextStyle(
                    fontSize: 11,
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

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeoBox(
            width: 64,
            height: 64,
            borderWidth: 2.5,
            shadowOffset: isEnabled ? 3.0 : 0.0,
            backgroundColor: AppTheme.surfaceWhite,
            child: Icon(
              icon,
              color: AppTheme.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isEnabled ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'offered':
        return AppTheme.accentYellow;
      case 'online test':
        return AppTheme.accentRed;
      case 'interview':
        return AppTheme.accentBlue;
      case 'ppt':
        return Colors.purple;
      case 'shortlisted':
        return Colors.green;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}

// Custom Bauhaus Dashboard Block Widget
class BauhausDashboard extends StatelessWidget {
  final int totalShortlists;
  final String statusText;
  final String subText;
  final bool isSyncing;

  const BauhausDashboard({
    super.key,
    required this.totalShortlists,
    required this.statusText,
    required this.subText,
    required this.isSyncing,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NeoBox(
        width: 250,
        height: 210,
        borderWidth: 3.5,
        shadowOffset: 6.0,
        backgroundColor: AppTheme.surfaceWhite,
        child: Column(
          children: [
            // Status bar at top
            NeoBox(
              width: double.infinity,
              height: 38,
              borderWidth: 0.0,
              shadowOffset: 0.0,
              backgroundColor: AppTheme.accentYellow,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.borderBlack,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusText.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 0.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 3.0, color: AppTheme.borderBlack),
            const Spacer(),
            // Big counter number
            Text(
              "$totalShortlists",
              style: const TextStyle(
                fontSize: 76,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              "ACTIVE TRACKERS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            // Timestamp
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                subText.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
