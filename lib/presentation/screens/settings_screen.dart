import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/placement_provider.dart';
import '../../core/theme/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _placementIdController;
  late TextEditingController _cdcSenderController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _placementIdController = TextEditingController();
    _cdcSenderController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final placementId = await authService.getPlacementId();
    final cdcSender = await authService.getCdcSender();
    
    setState(() {
      _placementIdController.text = placementId;
      _cdcSenderController.text = cdcSender;
    });
  }

  @override
  void dispose() {
    _placementIdController.dispose();
    _cdcSenderController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final provider = Provider.of<PlacementProvider>(context, listen: false);

    await authService.setPlacementId(_placementIdController.text.trim());
    await authService.setCdcSender(_cdcSenderController.text.trim());

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Settings saved successfully!"),
          backgroundColor: AppTheme.primaryNeon,
        ),
      );
      
      // Trigger sync with new settings
      provider.syncData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final provider = Provider.of<PlacementProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Account Section
                _buildSectionHeader("Connected Account"),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderMuted, width: 1),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: authService.currentUser?.photoUrl != null
                            ? Image.network(
                                authService.currentUser!.photoUrl!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 44,
                                      height: 44,
                                      color: AppTheme.accentTeal.withOpacity(0.08),
                                      child: const Icon(Icons.person, color: AppTheme.accentTeal),
                                    ),
                              )
                            : Container(
                                width: 44,
                                height: 44,
                                color: AppTheme.accentTeal.withOpacity(0.08),
                                child: const Icon(Icons.person, color: AppTheme.accentTeal),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authService.currentUser?.displayName ?? "VIT Student",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              authService.currentUser?.email ?? "Not signed in",
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Query Settings Section
                _buildSectionHeader("Criteria Configuration"),
                const SizedBox(height: 8),
                
                // Placement ID Input
                Text(
                  "Placement / NEO ID",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _placementIdController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Placement ID cannot be empty";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "E.g. I1F1A6M5",
                  ),
                ),
                const SizedBox(height: 16),

                // CDC Sender Input
                Text(
                  "CDC Sender Email",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cdcSenderController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "CDC Email cannot be empty";
                    }
                    if (!value.contains('@')) {
                      return "Invalid email address";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "E.g. vitianscdc2027@vitstudent.ac.in",
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _isSaving ? null : _saveSettings,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Text("Save & Apply Settings"),
                ),
                const SizedBox(height: 32),

                // Privacy / Information Section
                _buildSectionHeader("Privacy & Security"),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.darkSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderMuted, width: 1),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "• Direct Communication",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        "Your tokens and email histories remain 100% on this device. No servers, databases, or third-parties receive your data.",
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "• Read-Only Permissions",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        "The app requests Gmail Read-Only scope. It can never send, delete, or compose emails.",
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Disconnect Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text("Disconnect Gmail Account", style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _confirmDisconnect(context, authService, provider),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.accentTeal,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Future<void> _confirmDisconnect(
    BuildContext context,
    AuthService authService,
    PlacementProvider provider,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Disconnect Account?"),
          content: const Text(
            "This will sign you out of your Google account, delete the cached tokens, and erase all local placement histories from this app.",
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
              child: const Text("Disconnect & Erase"),
              onPressed: () async {
                Navigator.of(context).pop();
                await provider.clearAll();
                await authService.logout();
              },
            ),
          ],
        );
      },
    );
  }
}
