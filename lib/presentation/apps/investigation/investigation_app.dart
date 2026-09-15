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

  void _pick(String id