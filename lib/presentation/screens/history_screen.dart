import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/placement_provider.dart';
import '../../core/theme/theme.dart';
import '../../data/models/placement_update.dart';
import 'detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlacementProvider>(context);

    // Filter updates based on search query
    final filteredUpdates = provider.updates.where((update) {
      final query = _searchQuery.toLowerCase();
      return update.companyName.toLowerCase().contains(query) ||
          update.emailSubject.toLowerCase().contains(query) ||
          update.snippet.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shortlists History"),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Search company, subject...",
                prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          
          // History List
          Expanded(
            child: filteredUpdates.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    itemCount: filteredUpdates.length,
                    itemBuilder: (context, index) {
                      final update = filteredUpdates[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildHistoryCard(context, update),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, PlacementUpdate update) {
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderMuted, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator circle
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  )
                ]
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
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
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(update.dateReceived),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    update.emailSubject,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    update.snippet,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (update.hasExcelAttachment) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.table_chart_outlined, color: AppTheme.primaryNeon.withOpacity(0.8), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "Excel spreadsheet attached",
                          style: TextStyle(
                            color: AppTheme.primaryNeon.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_outlined,
              size: 48,
              color: AppTheme.borderMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              "No Results Found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Try searching with another company name or check your sync status.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
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

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${date.day} ${months[date.month - 1]}";
  }
}
