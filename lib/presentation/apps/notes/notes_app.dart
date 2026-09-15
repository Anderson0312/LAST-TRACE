import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/engines/game_engine.dart';
import '../../../domain/models/models.dart';
import '../../../main.dart';
import '../shared/app_scaffold.dart';

class NotesApp extends StatefulWidget {
  final VoidCallback onClose;
  const NotesApp({super.key, required this.onClose});

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  NoteItem? _open;

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    if (_open != null) {
      return AppScaffold(
        title: _open!.title,
        onClose: () => setState(() => _open = null),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            _open!.body,
            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.45),
            onTap: () {
              engine.revealFromContent(_open!.revealsClueIds);
              autosave(context);
            },
          ),
        ),
      );
    }
    final notes = [...engine.c.notes]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final fmt = DateFormat('dd/MM HH:mm');

    return AppScaffold(
      title: 'Notas',
      onClose: widget.onClose,
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (_, i) {
          final n = notes[i];
          return ListTile(
            leading: Icon(n.locked ? Icons.lock : Icons.note_alt_outlined),
            title: Text(n.title),
            subtitle: Text(n.locked ? 'Protegida' : n.body.split('\n').first, maxLines: 2),
            trailing: Text(fmt.format(n.updatedAt),
                style: const TextStyle(fontSize: 11, color: Colors.white38)),
            onTap: () => setState(() => _open = n),
          );
        },
      ),
    );
  }
}
