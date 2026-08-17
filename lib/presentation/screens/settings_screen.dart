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
  late TextEditingController _cdcEmailController;
  bool _isSaving = false;
  
  // Customizable profile card properties
  String _customRole = "Senior Tracking Engineer";
  String _customClientId = "PT-8492-X";

  // Custom Settings checkboxes (Visual parity with Screen 5)
  bool _verboseLogging = false;
  bool _autoSync = true;

  @override
  void initState() {
    super.initState();
    _placementIdController = TextEditingController();
    _cdcEmailController = TextEditingController();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final placementId = await authService.getPlacementId();
    final cdcEmail = await authService.getCdcSender();
    final role = await authService.getCustomRole();
    final clientId = await authService.getCustomClientId();
    setState(() {
      _placementIdController.text = placementId;
      _cdcEmailController.text = cdcEmail;
      _customRole = role;
      _customClientId = clientId;
    });
  }

  @override
  void dispose() {
    _placementIdController.dispose();
    _cdcEmailController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final provider = Provider.of<PlacementProvider>(context, listen: false);

      await authService.setPlacementId(_placementIdController.text.trim());
      await authService.setCdcSender(_cdcEmailController.text.trim());

      // Force provider refresh with new criteria
      await provider.loadHistory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Settings updated successfully!"),
            backgroundColor: AppTheme.accentYellow,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save settings: $e"),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _showEditProfileDialog(BuildContext context, AuthService auth) async {
    final roleController = TextEditingController(text: _customRole);
    final clientIdController = TextEditingController(text: _customClientId);
    final formKey = GlobalKey<FormState>();

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: Border.all(color: AppTheme.borderBlack, width: 3),
        title: const Text("EDIT PROFILE DETAILS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("CUSTOM ROLE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              TextFormField(
                controller: roleController,
                validator: (value) => value == null || value.trim().isEmpty ? "Role cannot be empty" : null,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: "E.g. Student",
                  filled: true,
                  fillColor: AppTheme.bgCream,
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderBlack, width: 2.0), borderRadius: BorderRadius.zero),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderBlack, width: 2.0), borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(height: 16),
              const Text("CLIENT DEVICE ID", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              TextFormField(
                controller: clientIdController,
                validator: (value) => value == null || value.trim().isEmpty ? "Device ID cannot be empty" : null,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: "E.g. PT-8492-X",
                  filled: true,
                  fillColor: AppTheme.bgCream,
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderBlack, width: 2.0), borderRadius: BorderRadius.zero),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.borderBlack, width: 2.0), borderRadius: BorderRadius.zero),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL", style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          ),
          NeoButton(
            backgroundColor: AppTheme.accentYellow,
            shadowOffset: 0,
            borderWidth: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text("SAVE", style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );

    if (updated == true) {
      final role = roleController.text.trim();
      final clientId = clientIdController.text.trim();
      await auth.setCustomRole(role);
      await auth.setCustomClientId(clientId);
      setState(() {
        _customRole = role;
        _customClientId = clientId;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile details updated successfully!"),
            backgroundColor: AppTheme.accentYellow,
          ),
        );
      }
    }
  }

  Future<void> _confirmDisconnect(BuildContext context, AuthService auth, PlacementProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceWhite,
        shape: Border.all(color: AppTheme.borderBlack, width: 3),
        title: const Text("DISCONNECT ACCOUNT", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        content: const Text(
          "Are you sure you want to disconnect? This will clear your credentials and delete local sync history.",
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCEL", style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold)),
          ),
          NeoButton(
            backgroundColor: AppTheme.accentRed,
            shadowOffset: 0,
            borderWidth: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () => Navigator.pop(context, true),
            child: const Text("DISCONNECT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await auth.logout();
      await provider.loadHistory(); // Reset provider lists
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final provider = Provider.of<PlacementProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text("SETTINGS"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Account Section (Screen 5 User Card)
                _buildSectionHeader("CONNECTED ACCOUNT"),
                const SizedBox(height: 8),
                
                NeoBox(
                  borderWidth: 2.5,
                  shadowOffset: 4.0,
                  backgroundColor: AppTheme.surfaceWhite,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // User photo in frame
                      NeoBox(
                        width: 90,
                        height: 90,
                        borderWidth: 2.0,
                        shadowOffset: 0.0,
                        padding: const EdgeInsets.all(2.0),
                        child: ClipRect(
                          child: authService.currentUser?.photoUrl != null
                              ? Image.network(
                                  authService.currentUser!.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person, size: 40, color: AppTheme.textSecondary),
                                )
                              : const Icon(Icons.person, size: 40, color: AppTheme.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        (authService.currentUser?.displayName ?? "Alex Mercer").toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textPrimary, letterSpacing: 0.5),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _customRole,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authService.currentUser?.email ?? "alex.mercer@ptracker.sys",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "ID: $_customClientId",
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      // Black Edit Profile button (fully interactive now!)
                      NeoButton(
                        backgroundColor: AppTheme.borderBlack,
                        shadowOffset: 0.0,
                        borderWidth: 0.0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        onTap: () => _showEditProfileDialog(context, authService),
                        child: const Text(
                          "EDIT PROFILE",
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Criteria Configuration
                _buildSectionHeader("SYSTEM CONFIG"),
                const SizedBox(height: 8),

                // Placement ID Input
                const Text(
                  "PLACEMENT ID",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _placementIdController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Placement ID cannot be empty";
                    }
                    return null;
                  },
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.badge, color: AppTheme.textPrimary),
                    hintText: "E.g. I1F1A6M5",
                    filled: true,
                    fillColor: AppTheme.surfaceWhite,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderBlack, width: 2.5),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderBlack, width: 2.5),
                      borderRadius: BorderRadius.zero,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentRed, width: 2.5),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentRed, width: 2.5),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // CDC Email Input
                const Text(
                  "CDC SENDER EMAIL",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textPrimary, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _cdcEmailController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "CDC Email cannot be empty";
                    }
                    if (!value.contains('@')) {
                      return "Invalid email address";
                    }
                    return null;
                  },
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.alternate_email, color: AppTheme.textPrimary),
                    hintText: "E.g. vitianscdc2027@vitstudent.ac.in",
                    filled: true,
                    fillColor: AppTheme.surfaceWhite,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderBlack, width: 2.5),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.borderBlack, width: 2.5),
                      borderRadius: BorderRadius.zero,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentRed, width: 2.5),
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.accentRed, width: 2.5),
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Checkboxes
                _buildCheckboxRow(
                  label: "ENABLE VERBOSE LOGGING",
                  value: _verboseLogging,
                  onChanged: (val) => setState(() => _verboseLogging = val ?? false),
                ),
                const SizedBox(height: 8),
                _buildCheckboxRow(
                  label: "AUTO-SYNC DATA",
                  value: _autoSync,
                  onChanged: (val) => setState(() => _autoSync = val ?? false),
                ),
                const SizedBox(height: 28),

                // Save Action Button
                NeoButton(
                  backgroundColor: AppTheme.accentYellow,
                  shadowOffset: 4.0,
                  onTap: _isSaving ? null : _saveSettings,
                  child: _isSaving
                      ? const Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.borderBlack),
                          ),
                        )
                      : const Center(
                          child: Text(
                            "SAVE & APPLY",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Disconnect Button
                NeoButton(
                  backgroundColor: AppTheme.surfaceWhite,
                  shadowOffset: 3.0,
                  onTap: () => _confirmDisconnect(context, authService, provider),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.power_settings_new, color: AppTheme.accentRed, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "DISCONNECT",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.5,
                          color: AppTheme.accentRed,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Privacy/Information Notice Frame
                _buildSectionHeader("PRIVACY & SECURITY NOTICE"),
                const SizedBox(height: 8),
                NeoBox(
                  borderWidth: 2.5,
                  shadowOffset: 0.0,
                  backgroundColor: AppTheme.surfaceWhite,
                  padding: const EdgeInsets.all(18),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "• Direct Communication",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.textPrimary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "All configuration changes are logged and monitored. Placement IDs and CDC configurations directly affect data routing. Ensure compliance with internal security protocols before applying modifications.",
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.4),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "• Read-Only Permissions",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppTheme.textPrimary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "The app requests Gmail Read-Only scope. It can never send, delete, or compose emails.",
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildCheckboxRow({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? AppTheme.accentYellow : AppTheme.surfaceWhite,
              border: Border.all(color: AppTheme.borderBlack, width: 2.5),
            ),
            child: value
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: AppTheme.borderBlack,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
