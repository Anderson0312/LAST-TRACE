import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/assets/game_images.dart';
import '../../../domain/engines/game_engine.dart';
import '../../../main.dart';
import '../shared/app_scaffold.dart';

class ContactsApp extends StatelessWidget {
  final VoidCallback onClose;
  const ContactsApp({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final contacts = [...engine.c.contacts]
      ..sort((a, b) => a.name.compareTo(b.name));

    return AppScaffold(
      title: 'Contatos',
      onClose: onClose,
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (_, i) {
          final c = contacts[i];
          return ListTile(
            leading: GameAvatar(
              characterId: c.id,
              fallbackLetter: c.name,
            ),
            title: Text(c.name),
            subtitle: Text([
              if (c.phone != null) c.phone!,
              if (c.notes != null && c.notes!.isNotEmpty) c.notes!,
            ].join('\n')),
            isThreeLine: c.notes != null && c.notes!.isNotEmpty,
            onTap: () {
              if (c.name == 'R.' || c.id == 'char_rita') {
                engine.discoverClue('CLUE_R_THREAD');
                engine.discoverClue('CLUE_NOTE_R');
              }
              if (c.name.contains('Não atender') || c.id == 'char_unknown') {
                engine.discoverClue('CLUE_CALL_UNKNOWN');
              }
              autosave(context);
            },
          );
        },
      ),
    );
  }
}

class CalendarApp extends StatelessWidget {
  final VoidCallback onClose;
  const CalendarApp({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    return AppScaffold(
      title: 'Calendário',
      onClose: onClose,
      body: ListView(
        children: engine.c.calendarEvents
            .map((e) => ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(e.title),
                  subtitle: Text(
                      '${e.start}\n${e.location ?? ''} ${e.notes ?? ''}'),
                  isThreeLine: true,
                  onTap: () {
                    engine.revealFromContent(e.revealsClueIds);
                    autosave(context);
                  },
                ))
            .toList(),
      ),
    );
  }
}
