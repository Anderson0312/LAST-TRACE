import 'package:flutter/material.dart';
import '../../../core/theme/osis_theme.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Color accent;
  final VoidCallback onClose;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floating;

  const AppScaffold({
    super.key,
    required this.title,
    required this.onClose,
    required this.body,
    this.accent = OsisTheme.accent,
    this.actions,
    this.floating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OsisTheme.bgDeep,
      floatingActionButton: floating,
      appBar: AppBar(
        backgroundColor: OsisTheme.bgElevated,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: onClose,
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        actions: actions,
      ),
      body: body,
    );
  }
}
