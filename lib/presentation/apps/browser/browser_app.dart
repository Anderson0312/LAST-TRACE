import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/engines/game_engine.dart';
import '../../../main.dart';
import '../shared/app_scaffold.dart';

class BrowserApp extends StatelessWidget {
  final VoidCallback onClose;
  const BrowserApp({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final fmt = DateFormat('dd/MM HH:mm');
    final history = [...engine.c.browserHistory]
      ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));

    return AppScaffold(
      title: 'Safari',
      onClose: onClose,
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Buscar ou digitar URL',
                filled: true,
                fillColor: Colors.white10,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Histórico',
                style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w600)),
          ),
          ...history.map((e) => ListTile(
                leading: const Icon(Icons.public, size: 20),
                title: Text(e.title),
                subtitle: Text('${e.url}\n${fmt.format(e.visitedAt)}'),
                isThreeLine: true,
                onTap: () {
                  engine.revealFromContent(e.revealsClueIds);
                  autosave(context);
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF14161C),
                    builder: (_) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        e.snippet ?? e.title,
                        style: const TextStyle(color: Colors.white, height: 1.4),
                      ),
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }
}
