import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/placement_provider.dart';
import '../../core/theme/theme.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final provider = Provider.of<PlacementProvider>(context);

    // If not authenticated, show login page directly inside the shell
    if (!authService.isAuthenticated) {
      return const LoginScreen();
    }

    return Scaffold(
      body: IndexedStack(
        index: provider.currentTabIndex,
        children: _screens,
      ),
      bottomNavigationBar: NeoBox(
        height: 72,
        borderWidth: 3.0,
        shadowOffset: 0.0,
        backgroundColor: AppTheme.surfaceWhite,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(provider, 0, Icons.dashboard_outlined, Icons.dashboard, "Overview"),
            _buildNavItem(provider, 1, Icons.history_outlined, Icons.history, "History"),
            _buildNavItem(provider, 2, Icons.settings_outlined, Icons.settings, "Settings"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(PlacementProvider provider, int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = provider.currentTabIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => provider.setTabIndex(index),
        child: Container(
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: isSelected
                ? BoxDecoration(
                    color: AppTheme.accentYellow,
                    border: Border.all(color: AppTheme.borderBlack, width: 2.5),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.borderBlack,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      )
                    ],
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? filledIcon : outlineIcon,
                  color: AppTheme.textPrimary,
                  size: 20,
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 0.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Boxed Logo Container (Bauhaus Style)
              Center(
                child: NeoBox(
                  width: 130,
                  height: 130,
                  borderWidth: 3.0,
                  shadowOffset: 6.0,
                  backgroundColor: AppTheme.surfaceWhite,
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/app_icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                "PTRACKER",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "Track VIT Placement Shortlist emails automatically. No spam, just updates.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              if (authService.isLoading)
                const Center(
                  child: CircularProgressIndicator(color: AppTheme.borderBlack),
                )
              else ...[
                // Yellow Brutalist Sign In Button
                NeoButton(
                  backgroundColor: AppTheme.accentYellow,
                  shadowOffset: 4.0,
                  onTap: () async {
                    final success = await authService.login();
                    if (!success) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Authentication Failed. Please try again."),
                            backgroundColor: AppTheme.accentRed,
                          ),
                        );
                      }
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login, color: AppTheme.textPrimary, size: 22),
                      SizedBox(width: 10),
                      Text(
                        "SIGN IN WITH VIT ACCOUNT",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.5,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Footnote Privacy Box
                NeoBox(
                  borderWidth: 2.0,
                  shadowOffset: 0.0,
                  backgroundColor: AppTheme.surfaceWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined, color: AppTheme.textSecondary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Requires read-only Gmail access to match placement IDs.",
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
