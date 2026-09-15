import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/engines/game_engine.dart';
import '../../../domain/models/models.dart';
import '../../../main.dart';
import '../shared/app_scaffold.dart';

class CallsApp extends StatelessWidget {
  final VoidCallback onClose;
  const CallsApp({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final fmt = DateFormat('dd/MM HH:mm');
    final calls = [...engine.c.calls]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return AppScaffold(
      title: 'Telefone',
      onClose: onClose,
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Recentes'),
                Tab(text: 'Favoritos'),
                Tab(text: 'Correio'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView.builder(
                    itemCount: calls.length,
                    itemBuilder: (_, i) {
                      final c = calls[i];
                      IconData icon = Icons.call_received;
                      if (c.type == CallType.outgoing) icon = Icons.call_made;
                      if (c.type == CallType.missed) icon = Icons.call_missed;
                      final dur = c.durationSeconds == 0
                          ? ''
                          : '${c.durationSeconds ~/ 60}:${(c.durationSeconds % 60).toString().padLeft(2, '0')}';
                      return ListTile(
                        leading: Icon(icon,
                            color: c.type == CallType.missed
                                ? Colors.redAccent
                                : Colors.greenAccent),
                        title: Text(c.displayName),
                        subtitle: Text(
                          [
                            fmt.format(c.timestamp),
                            if (c.number != null) c.number!,
                            if (dur.isNotEmpty) dur,
                            if (c.unknown) 'desconhecido',
                          ].join(' · '),
                        ),
                        onTap: () {
                          engine.revealFromContent(c.revealsClueIds);
                          if (c.id == 'call4') {
                            engine.setIsland(
                                IslandState.call, '${c.displayName} — 00:48');
                          }
                          autosave(context);
                        },
                      );
                    },
                  ),
                  ListView(
                    children: engine.c.contacts
                        .where((e) => e.favorite)
                        .map((c) => ListTile(
                              title: Text(c.name),
                              subtitle: Text(c.phone ?? ''),
                              leading: const Icon(Icons.star, color: Colors.amber),
                            ))
                        .toList(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.voicemail),
                    title: const Text('Camila Duarte'),
                    subtitle: const Text(
                        'Desculpa. Eu não tinha escolha. Não vá.'),
                    onTap: () {
                      engine.discoverClue('CLUE_VOICEMAIL');
                      autosave(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
