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
      return _NoteDetail(note: _open!, onBack: () => setState(() => _open = null));
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
            subtitle: Text(
              n.locked
                  ? 'Protegida · ${n.passwordHint ?? ''}'
                  : n.body.split('\n').first,
              maxLines: 2,
            ),
            trailing: Text(fmt.format(n.updatedAt),
                style: const TextStyle(fontSize: 11, color: Colors.white38)),
            onTap: () => setState(() => _open = n),
          );
        },
      ),
    );
  }
}

class _NoteDetail extends StatefulWidget {
  final NoteItem note;
  final VoidCallback onBack;
  const _NoteDetail({required this.note, required this.onBack});

  @override
  State<_NoteDetail> createState() => _NoteDetailState();
}

class _NoteDetailState extends State<_NoteDetail> {
  bool unlocked = false;
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final locked = widget.note.locked &&
        !unlocked &&
        !engine.progress.unlockedContent.contains(widget.note.id) &&
        !engine.progress.solvedPuzzles.contains('pz_note');

    return AppScaffold(
      title: widget.note.title,
      onClose: widget.onBack,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: locked
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.note.passwordHint ?? 'Senha necessária',
                      style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ctrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _try(engine),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _try(engine),
                    child: const Text('Desbloquear'),
                  ),
                ],
              )
            : SelectableText(
                widget.note.body,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.45),
                onTap: () {
                  engine.revealFromContent(widget.note.revealsClueIds);
                  autosave(context);
                },
              ),
      ),
    );
  }

  void _try(GameEngine engine) {
    if (engine.trySolvePuzzle('pz_note', _ctrl.text)) {
      setState(() => unlocked = true);
      engine.revealFromContent(widget.note.revealsClueIds);
      autosave(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha incorreta')),
      );
    }
  }
}
