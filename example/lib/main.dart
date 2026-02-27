import 'dart:developer' as developer;

import 'package:check_app_version/check_app_version.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExampleApp());

/// Endpoint URL pointing to the JSON version config.
const _endpointUrl = 'https://besimsoft.com/example.json';

/// Example app demonstrating check_app_version.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check App Version Demo',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      home: const DemoPage(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0052CC),
        brightness: brightness,
      ),
      useMaterial3: true,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: brightness == Brightness.light
                ? Colors.black.withAlpha(13) // ~0.05 opacity
                : Colors.white.withAlpha(13),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final List<String> _logs = [];
  bool _showOverlay = false;
  UpdateDecision? _overlayDecision;
  bool _isLoading = false;

  void _appendLog(String text) {
    setState(() => _logs.insert(0, text));
    developer.log(text, name: 'check_app_version.example');
  }

  Future<UpdateDecision> _runCheck() async {
    setState(() => _isLoading = true);
    final decision = await CheckAppVersion.get(
      _endpointUrl,
      policy: const UpdatePolicy(forceRefresh: true, debugMode: true),
    );
    setState(() => _isLoading = false);
    return decision;
  }

  void _logDecision(UpdateDecision decision, String action) {
    _appendLog(
      '[$action] Result: ${decision.reason.name} | '
      'Update required: ${decision.shouldUpdate} | '
      'Force: ${decision.isForceUpdate}',
    );
  }

  // 1. Silent Check
  Future<void> _demoSilent() async {
    _appendLog('── Starting Silent Check ──');
    final decision = await _runCheck();
    _logDecision(decision, 'Silent');
  }

  // 2. Dialog
  Future<void> _demoDialog() async {
    _appendLog('── Starting Dialog Check ──');
    final decision = await _runCheck();
    _logDecision(decision, 'Dialog');

    if (decision.shouldUpdate && mounted) {
      await CheckAppVersion.showUpdateDialog(
        context,
        decision: decision,
        onOpenStore: () {
          _appendLog('User tapped Update in Dialog');
          Navigator.of(context).pop();
        },
      );
    }
  }

  // 3. Modal
  Future<void> _demoModal() async {
    _appendLog('── Starting Modal Check ──');
    final decision = await _runCheck();
    _logDecision(decision, 'Modal');

    if (decision.shouldUpdate && mounted) {
      await CheckAppVersion.showUpdateModal(
        context,
        decision: decision,
        onOpenStore: () {
          _appendLog('User tapped Update in Modal');
          Navigator.of(context).pop();
        },
      );
    }
  }

  // 4. Overlay
  Future<void> _demoOverlay() async {
    _appendLog('── Starting Overlay Check ──');
    final decision = await _runCheck();
    _logDecision(decision, 'Overlay');

    if (decision.shouldUpdate && mounted) {
      setState(() {
        _showOverlay = true;
        _overlayDecision = decision;
      });
    }
  }

  // 5. Route
  Future<void> _demoRoute() async {
    _appendLog('── Starting Route Check ──');
    final decision = await _runCheck();
    _logDecision(decision, 'Route');

    if (decision.shouldUpdate && mounted) {
      await CheckAppVersion.showUpdatePage(
        context,
        decision: decision,
        onOpenStore: () {
          _appendLog('User tapped Update in Route');
          Navigator.of(context).pop();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Version Check'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_rounded),
            tooltip: 'Clear Logs',
            onPressed: () => setState(_logs.clear),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildHeaderCard(context, colorScheme),
              ),
              const SizedBox(height: 16),

              // Action Grid
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _ActionCard(
                        title: 'Silent Check',
                        icon: Icons.sync_rounded,
                        color: colorScheme.primary,
                        onTap: _demoSilent,
                      ),
                      _ActionCard(
                        title: 'Dialog UI',
                        icon: Icons.info_outline_rounded,
                        color: colorScheme.secondary,
                        onTap: _demoDialog,
                      ),
                      _ActionCard(
                        title: 'Modal Sheet',
                        icon: Icons.call_to_action_rounded,
                        color: colorScheme.tertiary,
                        onTap: _demoModal,
                      ),
                      _ActionCard(
                        title: 'Overlay Banner',
                        icon: Icons.post_add_rounded,
                        color: colorScheme.error,
                        onTap: _demoOverlay,
                      ),
                      _ActionCard(
                        title: 'Full Page Route',
                        icon: Icons.fullscreen_rounded,
                        color: Colors.teal,
                        onTap: _demoRoute,
                      ),
                    ],
                  ),
                ),
              ),

              // Log Console Drawer/Section
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.terminal_rounded,
                                color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Activity Log',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (_isLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: _logs.isEmpty
                            ? Center(
                                child: Text(
                                  'Ready to check versions...',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface
                                        .withAlpha(128), // ~0.5
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(16),
                                itemCount: _logs.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _logs[index],
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showOverlay && _overlayDecision != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: UpdateOverlay(
                  decision: _overlayDecision!,
                  onOpenStore: () {
                    _appendLog('Overlay: user tapped Update');
                    setState(() => _showOverlay = false);
                  },
                  onDismiss: () {
                    setState(() => _showOverlay = false);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.system_update_rounded,
                  color: colorScheme.onPrimaryContainer, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Check App Version',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Demonstrating unified API checks via HTTP endpoint.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer.withAlpha(204), // ~0.8
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withAlpha(26), // ~0.1
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withAlpha(51), // ~0.2
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
