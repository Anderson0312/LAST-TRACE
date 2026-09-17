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
import 'investigation_board.dart';

class InvestigationApp extends StatefulWidget {
  final VoidCallback onClose;
  const InvestigationApp({super.key, required this.onClose});

  @override
  State<InvestigationApp> createState() => _InvestigationAppState();
}

class _InvestigationAppState extends State<InvestigationApp>
    with SingleTickerProviderStateMixin {
  TabController? _tabs;
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
              // Evita que o swipe horizontal das abas “roube” o pan do quadro.
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const InvestigationBoard(),
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

  // Quadro visual vive em [InvestigationBoard].

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
                content: Text(ending?.epilogue ?? ''),
              ),
            );
          },
          child: const Text('Encerrar sem acusação'),
        ),
      ],
    );
  }

  Widget _coopPanel(GameEngine engine, CoopEngine coop) {
    final room = coop.room;
    if (room == null) {
      return const Center(child: Text('Sala cooperativa indisponível'));
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'Sala ${room.roomCode} · você é ${coop.role == CoopRole.playerA ? "Investigador A" : "Investigador B"}',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        const Text('Evidências compartilhadas',
            style: TextStyle(fontWeight: FontWeight.w700)),
        if (room.sharedEvidence.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Ainda vazio. Compartilhe pistas na aba Pistas ou importe um código.',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ...room.sharedEvidence.map((e) {
          final selected = _linkFrom == e.clueId;
          return ListTile(
            selected: selected,
            title: Text(e.title),
            subtitle: Text('${e.sharedBy.name} · ${e.summary}', maxLines: 2),
            trailing: Text(
              coop.encodeShareCode(e.clueId),
              style: const TextStyle(fontSize: 10, color: Colors.white38),
            ),
            onTap: () async {
              if (_linkFrom == null) {
                setState(() => _linkFrom = e.clueId);
              } else if (_linkFrom == e.clueId) {
                setState(() => _linkFrom = null);
              } else {
                await coop.linkShared(_linkFrom!, e.clueId, label: 'relação');
                setState(() => _linkFrom = null);
                if (coop.lastToast != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(coop.lastToast!)),
                  );
                }
              }
            },
          );
        }),
        const Divider(),
        const Text('Importar código do parceiro',
            style: TextStyle(fontWeight: FontWeight.w700)),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _importCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(hintText: 'Ex: NOTER'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                final ok = await coop.importShareCode(_importCtrl.text);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text(coop.lastToast ?? (ok ? 'OK' : 'Falha'))),
                );
                if (ok) _importCtrl.clear();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Cross-clues resolvidas',
            style: TextStyle(fontWeight: FontWeight.w700)),
        ...coop.resolvedCrossClues.map((c) => ListTile(
              leading:
                  const Icon(Icons.auto_awesome, color: Colors.amberAccent),
              title: Text(c.title),
              subtitle: Text(c.deduction),
            )),
        const Text('Pendentes', style: TextStyle(fontWeight: FontWeight.w700)),
        ...coop.pendingCrossClues.map((c) => ListTile(
              dense: true,
              title: Text(c.title),
              subtitle: Text('Precisa: ${c.requiresClueIds.join(" + ")}',
                  style:
                      const TextStyle(fontSize: 11, color: Colors.white38)),
            )),
      ],
    );
  }

  Widget _coopEnding(GameEngine engine, CoopEngine coop) {
    final suspects = engine.c.characters
        .where((c) => c.role == CharacterRole.suspect)
        .toList();
    final draft = coop.role == CoopRole.playerA
        ? (coop.room?.draftA ?? AccusationDraft(role: CoopRole.playerA))
        : (coop.room?.draftB ?? AccusationDraft(role: CoopRole.playerB));
    final other =
        coop.role == CoopRole.playerA ? coop.room?.draftB : coop.room?.draftA;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _urgencyBanner(engine),
        const SizedBox(height: 12),
        const Text(
          'A decisão final exige consenso. Trave sua teoria; se as duas convergirem, confirmem juntos.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        ...suspects.map((s) => RadioListTile<String>(
              value: s.id,
              groupValue: draft.suspectId,
              title: Text(s.name),
              onChanged: draft.locked
                  ? null
                  : (v) => coop.updateDraft(draft.copyWith(suspectId: v)),
            )),
        DropdownButtonFormField<String>(
          initialValue: draft.motive,
          decoration: const InputDecoration(labelText: 'Motivo'),
          items: const [
            DropdownMenuItem(
                value: 'silenciar_materia',
                child: Text('Silenciar a matéria Aurora')),
            DropdownMenuItem(value: 'divida', child: Text('Dívida / coação')),
            DropdownMenuItem(value: 'passional', child: Text('Crime passional')),
            DropdownMenuItem(value: 'outro', child: Text('Outro')),
          ],
          onChanged: draft.locked
              ? null
              : (v) => coop.updateDraft(draft.copyWith(motive: v)),
        ),
        DropdownButtonFormField<String>(
          initialValue: draft.place,
          decoration: const InputDecoration(labelText: 'Onde'),
          items: const [
            DropdownMenuItem(
                value: 'sao_lucas',
                child: Text('Estacionamento São Lucas')),
            DropdownMenuItem(value: 'lume', child: Text('Restaurante Lume')),
            DropdownMenuItem(value: 'casa', child: Text('Casa da vítima')),
            DropdownMenuItem(value: 'outro', child: Text('Outro')),
          ],
          onChanged: draft.locked
              ? null
              : (v) => coop.updateDraft(draft.copyWith(place: v)),
        ),
        const SizedBox(height: 12),
        Text(
          other?.locked == true
              ? 'Parceiro travou: ${other?.suspectId ?? "?"} / ${other?.motive ?? "?"} / ${other?.place ?? "?"}'
              : 'Aguardando o parceiro travar a teoria…',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () async {
            await coop.updateDraft(draft.copyWith(locked: true));
          },
          child: const Text('Travar minha teoria'),
        ),
        OutlinedButton(
          onPressed: () async {
            final ending = await coop.tryConfirmConsensus();
            if (!mounted) return;
            if (ending == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(coop.lastToast ??
                      'AS INVESTIGAÇÕES NÃO CONVERGEM'),
                ),
              );
              return;
            }
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: OsisTheme.bgElevated,
                title: Text('FINAL ${ending.code}: ${ending.title}'),
                content: Text('${ending.summary}\n\n${ending.epilogue}'),
              ),
            );
          },
          child: const Text('Confirmar consenso'),
        ),
      ],
    );
  }
}
