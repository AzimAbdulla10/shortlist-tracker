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

    // Filter updates by query
    final filteredUpdates = provider.updates.where((update) {
      final query = _searchQuery.toLowerCase();
      return update.companyName.toLowerCase().contains(query) ||
          update.emailSubject.toLowerCase().contains(query) ||
          update.snippet.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text("PTRACKER"),
      ),
      body: Column(
        children: [
          // Bauhaus "SHORTLISTS HISTORY" title with yellow highlighted box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Row(
              children: [
                const Text(
                  "SHORTLISTS ",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                NeoBox(
                  borderWidth: 2.0,
                  shadowOffset: 0.0,
                  backgroundColor: AppTheme.accentYellow,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: const Text(
                    "HISTORY",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search Archive Bar (Bauhaus Style with yellow search button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      border: Border.all(color: AppTheme.borderBlack, width: 2.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      decoration: const InputDecoration(
                        hintText: "Search archive...",
                        hintStyle: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                // Search trailing block
                GestureDetector(
                  onTap: () {
                    // Triggers search
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow,
                      border: Border.all(color: AppTheme.borderBlack, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: AppTheme.borderBlack,
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        )
                      ],
                    ),
                    child: const Icon(Icons.search, color: AppTheme.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // History List
          Expanded(
            child: filteredUpdates.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    itemCount: filteredUpdates.length,
                    itemBuilder: (context, index) {
                      final update = filteredUpdates[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
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
      child: NeoBox(
        borderWidth: 2.5,
        shadowOffset: 4.0,
        backgroundColor: AppTheme.surfaceWhite,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checked/Indicator Box on Left (Neo-brutalist status selector mock)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.15),
                border: Border.all(color: AppTheme.borderBlack, width: 2.0),
              ),
              child: Icon(
                Icons.check,
                size: 12,
                color: AppTheme.borderBlack.withOpacity(0.8),
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
                          update.companyName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Flag/Date tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.borderBlack,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDate(update.dateReceived).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    update.emailSubject,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
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
                  if (update.hasExcelAttachment) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.table_chart, color: AppTheme.textPrimary, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          "EXCEL SHORTLIST ATTACHED",
                          style: TextStyle(
                            color: AppTheme.textPrimary.withOpacity(0.8),
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
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
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              "NO SEARCH RESULTS",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "We couldn't find any placement updates matching your query. Try clearing or editing the search bar.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                height: 1.4,
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
    return "${date.day} ${months[date.month - 1]}";
  }
}
