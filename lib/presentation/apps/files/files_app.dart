import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/engines/game_engine.dart';
import '../../../domain/models/models.dart';
import '../../../main.dart';
import '../shared/app_scaffold.dart';

class FilesApp extends StatefulWidget {
  final VoidCallback onClose;
  const FilesApp({super.key, required this.onClose});

  @override
  State<FilesApp> createState() => _FilesAppState();
}

class _FilesAppState extends State<FilesApp> {
  FileItem? _open;

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    if (_open != null) {
      return _FileDetail(file: _open!, onBack: () => setState(() => _open = null));
    }
    final files = engine.c.files.where((f) {
      if (!f.hidden) return true;
      return engine.progress.unlockedContent.contains(f.id) ||
          engine.progress.solvedPuzzles.contains('pz_dat') ||
          engine.progress.discoveredClues.contains('CLUE_FILE_DAT');
    }).toList();
    final fmt = DateFormat('dd/MM HH:mm');

    return AppScaffold(
      title: 'Arquivos',
      onClose: widget.onClose,
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (_, i) {
          final f = files[i];
          return ListTile(
            leading: Icon(_icon(f.type)),
            title: Text(f.name),
            subtitle: Text(
                '${f.path} · ${fmt.format(f.modifiedAt)}${f.passwordProtected ? ' · 🔒' : ''}${f.corrupted ? ' · corrompido' : ''}'),
            onTap: () => setState(() => _open = f),
          );
        },
      ),
    );
  }

  IconData _icon(String t) {
    switch (t) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'xlsx':
        return Icons.table_chart;
      case 'dat':
        return Icons.warning_amber;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class _FileDetail extends StatefulWidget {
  final FileItem file;
  final VoidCallback onBack;
  const _FileDetail({required this.file, required this.onBack});

  @override
  State<_FileDetail> createState() => _FileDetailState();
}

class _FileDetailState extends State<_FileDetail> {
  bool unlocked = false;
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final needPass = widget.file.passwordProtected &&
        !unlocked &&
        !engine.progress.unlockedContent.contains(widget.file.id) &&
        !engine.progress.solvedPuzzles.contains('pz_aurora');

    return AppScaffold(
      title: widget.file.name,
      onClose: widget.onBack,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: needPass
            ? Column(
                children: [
                  const Text('Arquivo protegido por senha',
                      style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  const Text('Dica: aniversário de R. (nota RO)',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      final puzzleId = widget.file.id == 'f3' ? 'pz_dat' : 'pz_aurora';
                      if (widget.file.password != null &&
                          _ctrl.text.trim() == widget.file.password) {
                        engine.trySolvePuzzle(puzzleId, _ctrl.text);
                        setState(() => unlocked = true);
                        engine.revealFromContent(widget.file.revealsClueIds);
                        autosave(context);
                      } else if (engine.trySolvePuzzle(puzzleId, _ctrl.text)) {
                        setState(() => unlocked = true);
                        autosave(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Senha incorreta')),
                        );
                      }
                    },
                    child: const Text('Abrir'),
                  ),
                ],
              )
            : SelectableText(
                widget.file.content ?? '(vazio)',
                style: const TextStyle(color: Colors.white, height: 1.45),
                onTap: () {
                  engine.revealFromContent(widget.file.revealsClueIds);
                  autosave(context);
                },
              ),
      ),
    );
  }
}
