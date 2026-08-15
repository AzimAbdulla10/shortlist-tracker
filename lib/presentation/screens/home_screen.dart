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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Placement Watch"),
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
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Welcome Card
                _buildOverviewCard(context, provider),
                const SizedBox(height: 24),

                // Latest Alert Banner
                Text(
                  "Latest Shortlist Alert",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (latest != null)
                  _buildLatestUpdateCard(context, latest)
                else
                  _buildEmptyState(context, provider),
                
                const SizedBox(height: 24),
                // Instructions / Tips Card
                _buildTipCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context, PlacementProvider provider) {
    final lastSyncText = provider.lastSyncTime != null
        ? "${provider.lastSyncTime!.hour.toString().padLeft(2, '0')}:${provider.lastSyncTime!.minute.toString().padLeft(2, '0')}"
        : "Never";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderMuted, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Overview",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryNeon,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Monitoring Active",
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ],
              ),
              if (provider.isSyncing)
                const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryNeon),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(
                context,
                provider.updates.length.toString(),
                "Shortlists",
                Icons.check_circle_outline,
              ),
              _buildStatItem(
                context,
                lastSyncText,
                "Last Synced",
                Icons.sync,
              ),
            ],
          ),
          if (provider.errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.accentTeal, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        )
      ],
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    update.status.toUpperCase(),
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              update.emailSubject,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              update.snippet,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(update.dateReceived),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                ),
                if (update.hasExcelAttachment)
                  const Row(
                    children: [
                      Icon(Icons.table_chart_outlined, color: AppTheme.primaryNeon, size: 16),
                      SizedBox(width: 4),
                      Text(
                        "Excel Shortlist",
                        style: TextStyle(color: AppTheme.primaryNeon, fontSize: 12),
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
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderMuted, width: 1),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.drafts_outlined,
            size: 48,
            color: AppTheme.borderMuted,
          ),
          const SizedBox(height: 16),
          Text(
            "No Placements Found",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "We haven't detected any shortlist emails matching your placement criteria yet.",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.sync, size: 20, color: Colors.black),
            label: const Text("Perform Initial Sync"),
            onPressed: provider.isSyncing ? null : () => provider.syncData(),
          )
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryNeon.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryNeon.withOpacity(0.15), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppTheme.primaryNeon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Background Monitoring",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  "To receive instant alerts in the background, make sure battery optimization is disabled for Placement Watch in your system settings.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary.withOpacity(0.8),
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
