import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/osis_theme.dart';
import '../../../domain/engines/game_engine.dart';
import '../../../main.dart';
import '../shared/app_scaffold.dart';

class TrashApp extends StatelessWidget {
  final VoidCallback onClose;
  const TrashApp({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final deleted = engine.c.photos.where((p) => p.deleted).toList();
    return AppScaffold(
      title: 'Lixeira',
      onClose: onClose,
      body: ListView(
        children: [
          ...deleted.map((p) => ListTile(
                title: Text(p.title),
                subtitle: Text(p.caption),
                onTap: () {
                  engine.viewPhoto(p.id, p.revealsClueIds);
                  autosave(context);
                },
              )),
          ListTile(
            title: const Text('backup_pulse_partial.bak'),
            subtitle: const Text('Recuperar fragmento de mensagem'),
            onTap: () {
              engine.discoverClue('CLUE_RECOVERED_FRAGMENT');
              engine.openApp('files');
              autosave(context);
            },
          ),
        ],
      ),
    );
  }
}

class CameraApp extends StatelessWidget {
  final VoidCallback onClose;
  const CameraApp({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Câmera',
      onClose: onClose,
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            const Expanded(
              child: Center(
                child: Text(
                  'Visor simulado · VANTA Optics\n(sem acesso à câmera real)',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.flash_off, color: Colors.white54),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                  ),
                  const Icon(Icons.cameraswitch, color: Colors.white54),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecorderApp extends StatelessWidget {
  final VoidCallback onClose;
  const RecorderApp({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    return AppScaffold(
      title: 'Ditafone',
      onClose: onClose,
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.graphic_eq),
            title: const Text('gravacao_2347.m4a'),
            subtitle: const Text('00:03:41 · recuperado'),
            onTap: () {
              engine.discoverClue('CLUE_AUDIO_THREAT');
              engine.discoverClue('CLUE_FILE_DAT');
              autosave(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('"Você não deveria estar olhando isso."'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text('nota_voz_marina.m4a'),
            subtitle: const Text('Lembrete: pasta Aurora'),
            onTap: () => engine.discoverClue('CLUE_FILE_AURORA'),
          ),
        ],
      ),
    );
  }
}

class BankApp extends StatelessWidget {
  final VoidCallback onClose;
  const BankApp({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    return AppScaffold(
      title: 'Nubank',
      onClose: onClose,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00695C),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Conta pessoal', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text('R\$ 2.418,90',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Comprovante salvo — AV Services'),
            subtitle: const Text('R\$ 80.000 · D. Rocha'),
            onTap: () {
              engine.discoverClue('CLUE_DANIEL_MONEY');
              autosave(context);
            },
          ),
          const ListTile(
            title: Text('Pagamento Pix — café'),
            subtitle: Text('R\$ 18,00'),
          ),
        ],
      ),
    );
  }
}

class VibeApp extends StatelessWidget {
  final VoidCallback onClose;
  const VibeApp({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Instagram',
      onClose: onClose,
      body: GridView.count(
        crossAxisCount: 2,
        children: List.generate(
          6,
          (i) => Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 236, 64 + (i * 8) % 40, 122),
                  const Color(0xFF8E24AA),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                i == 0 ? 'Marina & Camila' : 'Post $i',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MysteryApp extends StatefulWidget {
  final VoidCallback onClose;
  const MysteryApp({super.key, required this.onClose});

  @override
  State<MysteryApp> createState() => _MysteryAppState();
}

class _MysteryAppState extends State<MysteryApp> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final open = engine.progress.solvedPuzzles.contains('pz_dat') ||
        engine.progress.discoveredClues.contains('CLUE_FILE_DAT');

    return AppScaffold(
      title: '???',
      onClose: widget.onClose,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: open
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Canal criptografado ativo',
                      style: TextStyle(color: OsisTheme.danger)),
                  const SizedBox(height: 12),
                  const Text(
                    'Sessão remota detectada.\nOrigem: AV Services proxy.\n\n"Você não deveria estar olhando isso."',
                    style: TextStyle(height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      engine.triggerRemoteAccess();
                      autosave(context);
                    },
                    child: const Text('Inspecionar sessão'),
                  ),
                ],
              )
            : Column(
                children: [
                  const Text(
                    'Aplicativo bloqueado.\nSenha = horário da última carga (4 dígitos).',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Código',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      if (engine.trySolvePuzzle('pz_dat', _ctrl.text)) {
                        setState(() {});
                        autosave(context);
                      }
                    },
                    child: const Text('Entrar'),
                  ),
                ],
              ),
      ),
    );
  }
}

class SearchApp extends StatelessWidget {
  final VoidCallback onClose;
  const SearchApp({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final ctrl = TextEditingController();
    final results = <String>[];

    return AppScaffold(
      title: 'Busca',
      onClose: onClose,
      body: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: ctrl,
                  decoration: InputDecoration(
                    hintText: 'Rafael, estacionamento, Aurora…',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (q) {
                    final query = q.toLowerCase();
                    results
                      ..clear()
                      ..addAll(engine.c.conversations
                          .where((c) =>
                              c.displayName.toLowerCase().contains(query) ||
                              c.messages.any(
                                  (m) => m.body.toLowerCase().contains(query)))
                          .map((c) => 'Pulse · ${c.displayName}'))
                      ..addAll(engine.c.photos
                          .where((p) =>
                              p.title.toLowerCase().contains(query) ||
                              p.visualDescription.toLowerCase().contains(query))
                          .map((p) => 'Fotos · ${p.title}'))
                      ..addAll(engine.c.notes
                          .where((n) =>
                              n.title.toLowerCase().contains(query) ||
                              n.body.toLowerCase().contains(query))
                          .map((n) => 'Notas · ${n.title}'))
                      ..addAll(engine.c.locations
                          .where((l) => l.name.toLowerCase().contains(query))
                          .map((l) => 'Atlas · ${l.name}'));
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  children: results
                      .map((r) => ListTile(
                            title: Text(r),
                            onTap: () {
                              if (r.contains('Pulse')) engine.openApp('pulse');
                              if (r.contains('Fotos')) engine.openApp('gallery');
                              if (r.contains('Notas')) engine.openApp('notes');
                              if (r.contains('Atlas')) engine.openApp('atlas');
                            },
                          ))
                      .toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
