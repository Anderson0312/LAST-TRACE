import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/osis_theme.dart';
import '../../../domain/coop/coop_engine.dart';
import '../../../domain/coop/coop_models.dart';
import '../../../domain/engines/game_engine.dart';
import '../../../domain/models/models.dart';
import '../../../main.dart';
import '../shared/app_scaffold.dart';

class InvestigationApp extends StatefulWidget {
  final VoidCallback onClose;
  const InvestigationApp({super.key, required this.onClose});

  @override
  State<InvestigationApp> createState() => _InvestigationAppState();
}

class _InvestigationAppState extends State<InvestigationApp>
    with SingleTickerProviderStateMixin {
  TabController? _tabs;
  String? _selectedA;
  String? _selectedB;
  final _importCtrl = TextEditingController();
  String? _linkFrom;

  bool get _coop {
    try {
      return context.read<CoopEngine>().isCoop;
    } catch (_) {
      return false;
    }
  }

  int get _tabCount => _coop ? 6 : 5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tabs == null || _tabs!.length != _tabCount) {
      _tabs?.dispose();
      _tabs = TabController(length: _tabCount, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabs?.dispose();
    _importCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    final coop = context.watch<CoopEngine>();
    final fmt = DateFormat('HH:mm');
    final tabs = _tabs!;

    return AppScaffold(
      title: 'Quadro de Investigação',
      onClose: widget.onClose,
      body: Column(
        children: [
          TabBar(
            controller: tabs,
            isScrollable: true,
            tabs: [
              const Tab(text: 'Quadro'),
              const Tab(text: 'Pistas'),
              const Tab(text: 'Timeline'),
              const Tab(text: 'Contradições'),
              if (coop.isCoop) const Tab(text: 'Coop'),
              const Tab(text: 'Conclusão'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabs,
              children: [
                _board(engine),
                _clues(engine, coop),
                _timeline(engine, fmt),
                _contras(engine),
                if (coop.isCoop) _coopPanel(engine, coop),
                coop.isCoop ? _coopEnding(engine, coop) : _ending(engine),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _board(GameEngine engine) {
    final people = engine.c.characters
        .where((c) =>
            c.role == CharacterRole.suspect ||
            c.role == CharacterRole.victim ||
            c.role == CharacterRole.mysterious)
        .toList();
    final clues = engine.c.clues
        .where((c) => engine.progress.discoveredClues.contains(c.id))
        .take(12)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _urgencyBanner(engine),
        const SizedBox(height: 10),
        Text(
          'Score: ${engine.progress.investigationScore.toStringAsFixed(0)} · '
          'Pistas ${(engine.progress.clueCompletion * 100).toStringAsFixed(0)}% · '
          'Timeline ${(engine.progress.timelineCompletion * 100).toStringAsFixed(0)}%',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        const Text('Pessoas', style: TextStyle(fontWeight: FontWeight.w600)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: people
              .map((p) => ActionChip(
                    label: Text(p.name.split(' ').first),
                    backgroundColor: _selectedA == p.id || _selectedB == p.id
                        ? OsisTheme.accent.withValues(alpha: 0.4)
                        : Colors.white10,
                    onPressed: () => _pick(p.id),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        const Text('Pistas descobertas',
            style: TextStyle(fontWeight: FontWeight.w600)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: clues
              .map((c) => ActionChip(
                    label: Text(c.name, style: const TextStyle(fontSize: 11)),
                    onPressed: () => _pick(c.id),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
        if (_selectedA != null && _selectedB != null)
          FilledButton(
            onPressed: () {
              engine.addBoardConnection(_selectedA!, _selectedB!);
              setState(() {
                _selectedA = null;
                _selectedB = null;
              });
              autosave(context);
            },
            child: Text('Conectar $_selectedA → $_selectedB'),
          )
        else
          Text(
            _selectedA == null
                ? 'Selecione dois elementos para conectar. O jogo não confirma se está certo.'
                : 'Selecione o segundo elemento.',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        const SizedBox(height: 16),
        const Text('Conexões', style: TextStyle(fontWeight: FontWeight.w600)),
        ...engine.progress.boardConnections.map((c) => ListTile(
              dense: true,
              title: Text('${c.fromId} → ${c.toId}'),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => engine.removeBoardConnection(c.id),
              ),
            )),
        const Divider(),
        const Text('Minhas Anotações',
            style: TextStyle(fontWeight: FontWeight.w600)),
        ...engine.progress.investigatorNotes.map((n) => ListTile(
              dense: true,
              leading: Icon(_tagIcon(n.tag), size: 18),
              title: Text(n.text),
              subtitle: Text(n.tag.name),
            )),
        TextButton.icon(
          onPressed: () => _addNote(engine),
          icon: const Icon(Icons.edit_note),
          label: const Text('Nova anotação'),
        ),
      ],
    );
  }

  Widget _urgencyBanner(GameEngine engine) {
    final hint = engine.suggestedNextHint;
    final battery = engine.progress.batteryPercent;
    final pressure = engine.progress.timePressure;
    final critical = battery <= 15 || pressure >= 0.78;
    final low = battery <= 35 || pressure >= 0.55;
    final accent = critical
        ? OsisTheme.danger
        : low
            ? const Color(0xFFFFB020)
            : const Color(0xFF8BE09A);
    final title = critical
        ? 'Bateria crítica · $battery%'
        : low
            ? 'Bateria caindo · $battery%'
            : 'Bateria do aparelho · $battery%';
    final subtitle = critical
        ? 'O telefone pode apagar a qualquer momento. Conclua no Quadro.'
        : 'Enquanto a bateria morre, as mensagens dos conhecidos ainda podem ajudar.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                critical ? Icons.battery_alert : Icons.battery_3_bar,
                size: 16,
                color: accent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (battery / 100).clamp(0.02, 1.0),
              minHeight: 4,
              backgroundColor: Colors.white12,
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              height: 1.3,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 8),
            Text(
              hint,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _pick(String id) {
    setState(() {
      if (_selectedA == null) {
        _selectedA = id;
      } else if (_selectedB == null && id != _selectedA) {
        _selectedB = id;
      } else {
        _selectedA = id;
        _selectedB = null;
      }
    });
  }

  IconData _tagIcon(NoteTag t) {
    switch (t) {
      case NoteTag.suspect:
        return Icons.person_search;
      case NoteTag.evidence:
        return Icons.fingerprint;
      case NoteTag.theory:
        return Icons.lightbulb_outline;
      case NoteTag.location:
        return Icons.place;
      case NoteTag.question:
        return Icons.help_outline;
      case NoteTag.other:
        return Icons.notes;
    }
  }

  Future<void> _addNote(GameEngine engine) async {
    final text = TextEditingController();
    var tag = NoteTag.theory;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: OsisTheme.bgElevated,
        title: const Text('Anotação'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: text, maxLines: 3),
            DropdownButtonFormField<NoteTag>(
              initialValue: tag,
              items: NoteTag.values
                  .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) tag = v;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Salvar')),
        ],
      ),
    );
    if (!mounted) return;
    if (ok == true && text.text.trim().isNotEmpty) {
      engine.addInvestigatorNote(text.text.trim(), tag);
      await autosave(context);
    }
  }

  Widget _clues(GameEngine engine, CoopEngine coop) {
    final clues = engine.c.clues
        .where((c) => engine.progress.discoveredClues.contains(c.id))
        .toList();
    return ListView.builder(
      itemCount: clues.length,
      itemBuilder: (_, i) {
        final c = clues[i];
        final shared = coop.isCoop && coop.sharedClueIds.contains(c.id);
        return ListTile(
          leading: Icon(
            Icons.circle,
            size: 12,
            color: c.importance == ClueImportance.critical
                ? OsisTheme.danger
                : OsisTheme.accent,
          ),
          title: Text(c.name),
          subtitle: Text('${c.origin}\n${c.content}', maxLines: 3),
          isThreeLine: true,
          trailing: coop.isCoop
              ? IconButton(
                  tooltip: shared
                      ? 'Já compartilhada'
                      : 'Compartilhar (${coop.encodeShareCode(c.id)})',
                  icon: Icon(
                    shared ? Icons.check_circle : Icons.ios_share,
                    color: shared ? Colors.greenAccent : OsisTheme.accent,
                  ),
                  onPressed: shared
                      ? null
                      : () async {
                          final item = await coop.shareClue(c.id);
                          if (!mounted || item == null) return;
                          final code = coop.encodeShareCode(c.id);
                          await Clipboard.setData(ClipboardData(text: code));
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Compartilhada. Código para o parceiro: $code',
                              ),
                            ),
                          );
                        },
                )
              : (engine.debugMode
                  ? Text(c.id,
                      style:
                          const TextStyle(fontSize: 9, color: Colors.white30))
                  : null),
          onTap: () => engine.discoverClue(c.id, analyzed: true),
        );
      },
    );
  }

  Widget _timeline(GameEngine engine, DateFormat fmt) {
    final events = engine.c.timeline.where(engine.isTimelineVisible).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: events.length,
      itemBuilder: (_, i) {
        final e = events[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              child: Text(fmt.format(e.timestamp),
                  style: const TextStyle(
                      color: OsisTheme.accent, fontWeight: FontWeight.w600)),
            ),
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(top: 4, right: 10),
              decoration: const BoxDecoration(
                color: Colors.white54,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.description),
                    Text(
                      [
                        if (e.location != null) e.location!,
                        e.source,
                        'conf ${(e.reliability * 100).round()}%',
                      ].join(' · '),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _contras(GameEngine engine) {
    return ListView(
      children: engine.c.contradictions.map((c) {
        final ready =
            c.evidenceClueIds.every(engine.progress.discoveredClues.contains);
        final marked = engine.progress.markedContradictions.contains(c.id);
        return ListTile(
          title: Text(c.statement),
          subtitle: Text(ready
              ? (marked ? c.resolution : 'Evidências prontas — confrontar')
              : 'Faltam evidências'),
          trailing: marked
              ? const Icon(Icons.check, color: Colors.greenAccent)
              : IconButton(
                  icon: const Icon(Icons.gavel),
                  onPressed: ready
                      ? () {
                          engine.markContradiction(c.id);
                          autosave(context);
                        }
                      : null,
                ),
        );
      }).toList(),
    );
  }

  Widget _ending(GameEngine engine) {
    final suspects = engine.c.characters
        .where((c) => c.role == CharacterRole.suspect)
        .toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _urgencyBanner(engine),
        const SizedBox(height: 12),
        const Text(
          'Quando estiver pronto, escolha quem acusar. O jogo avalia evidências — não há confirmação prévia.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        const SizedBox(height: 12),
        ...suspects.map((s) => ListTile(
              title: Text(s.name),
              subtitle: Text(s.profession ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                final ending = engine.evaluateEnding(accusedId: s.id);
                autosave(context);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: OsisTheme.bgElevated,
                    title: Text('FINAL ${ending?.code}: ${ending?.title}'),
                    content: SingleChildScrollView(
                      child: Text(
                        '${ending?.summary}\n\n${ending?.epilogue}',
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Continuar investigando'),
                      ),
                    ],
                  ),
                );
              },
            )),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            final ending = engine.evaluateEnding(accusedId: null);
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: OsisTheme.bgElevated,
                title: Text('FINAL ${ending?.code}'),
                content: Text(ending?.epilog