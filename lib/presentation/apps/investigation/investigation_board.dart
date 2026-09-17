import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/osis_theme.dart';
import '../../../domain/coop/coop_engine.dart';
import '../../../domain/coop/coop_models.dart';
import '../../../domain/engines/game_engine.dart';
import '../../../domain/models/models.dart';
import '../../../main.dart';
import 'board_theme.dart';
import 'connection_painter.dart';
import 'evidence_cards.dart';

/// Canvas interativo do Quadro de Investigação (cortiça + fios + cartões).
class InvestigationBoard extends StatefulWidget {
  const InvestigationBoard({super.key});

  @override
  State<InvestigationBoard> createState() => _InvestigationBoardState();
}

class _InvestigationBoardState extends State<InvestigationBoard>
    with TickerProviderStateMixin {
  static const boardW = 2400.0;
  static const boardH = 1800.0;
  static const cardW = 148.0;
  static const cardH = 190.0;

  final _transform = TransformationController();
  final _searchCtrl = TextEditingController();
  BoardFilter _filter = BoardFilter.all;
  String? _connectFrom;
  Offset? _draftCursor;
  String? _selectedId;
  String? _freshConnectionId;
  String? _draggingNodeId;
  String _search = '';
  bool _showTimeline = false;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerBoard());
  }

  @override
  void dispose() {
    _transform.dispose();
    _searchCtrl.dispose();
    _pulse.dispose();
    super.dispose();
  }

  double get _currentScale => _transform.value.getMaxScaleOnAxis();

  void _setTransform({required double scale, required Offset topLeft}) {
    final s = scale.clamp(0.12, 3.0);
    _transform.value = Matrix4.identity()
      ..translateByDouble(topLeft.dx, topLeft.dy, 0, 1)
      ..scaleByDouble(s, s, 1, 1);
  }

  void _centerBoard() {
    final size = MediaQuery.sizeOf(context);
    final isPhone = size.shortestSide < 600;
    final scale = isPhone ? 0.55 : 0.42;
    final dx = (size.width - boardW * scale) / 2;
    final dy = isPhone ? 40.0 : (size.height * 0.35 - boardH * scale * 0.2);
    _setTransform(scale: scale, topLeft: Offset(dx, dy));
  }

  void _fitAll() {
    final size = MediaQuery.sizeOf(context);
    final sx = size.width / boardW;
    final sy = (size.height * 0.72) / boardH;
    final scale = math.min(sx, sy).clamp(0.18, 0.7);
    final dx = (size.width - boardW * scale) / 2;
    final dy = 24.0;
    _setTransform(scale: scale, topLeft: Offset(dx, dy));
  }

  void _zoomBy(double factor) {
    final size = MediaQuery.sizeOf(context);
    final m = _transform.value;
    final oldScale = m.getMaxScaleOnAxis();
    final newScale = (oldScale * factor).clamp(0.12, 3.0);
    // Mantém o centro da tela fixo ao zoomar pelos botões.
    final focal = Offset(size.width / 2, size.height * 0.38);
    final sceneBefore = _transform.toScene(focal);
    final next = Matrix4.identity()
      ..translateByDouble(focal.dx, focal.dy, 0, 1)
      ..scaleByDouble(newScale, newScale, 1, 1)
      ..translateByDouble(-sceneBefore.dx, -sceneBefore.dy, 0, 1);
    _transform.value = next;
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<GameEngine>();
    CoopEngine? coop;
    try {
      coop = context.watch<CoopEngine>();
    } catch (_) {}

    final nodes = _buildNodes(engine, coop);
    final pinCenters = <String, Offset>{
      for (final n in nodes)
        n.id: Offset(n.layout.x + cardW / 2, n.layout.y + 10),
    };

    final snap = engine.boardProgressSnapshot();
    final reduceMotion = engine.reduceMotion;

    return Column(
      children: [
        _header(snap),
        _filters(),
        if (_search.isNotEmpty || _searchCtrl.text.isNotEmpty) _searchBar(),
        Expanded(
          child: Stack(
            children: [
              InteractiveViewer(
                transformationController: _transform,
                minScale: 0.12,
                maxScale: 3.0,
                boundaryMargin: const EdgeInsets.all(1600),
                constrained: false,
                // Um dedo = pan; pinça = zoom. Cartões não capturam pan.
                panEnabled: _draggingNodeId == null,
                scaleEnabled: _draggingNodeId == null,
                trackpadScrollCausesScale: true,
                interactionEndFrictionCoefficient: 0.00012,
                child: SizedBox(
                  width: boardW,
                  height: boardH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Fundo recebe hits em toda a área → pan fácil no mobile.
                      const Positioned.fill(
                        child: _CorkBackground(absorbPointers: true),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: BoardWireLayer(
                            connections: engine.progress.boardConnections,
                            pinCenters: pinCenters,
                            draftFrom: _connectFrom != null
                                ? pinCenters[_connectFrom!]
                                : null,
                            draftTo: _draftCursor,
                            freshConnectionId: _freshConnectionId,
                          ),
                        ),
                      ),
                      for (final node in nodes)
                        if (_visible(node))
                          Positioned(
                            left: node.layout.x,
                            top: node.layout.y,
                            child: Transform.rotate(
                              angle: node.layout.rotation,
                              child: _boardNodeGestures(engine, coop, node),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              if (_draggingNodeId != null)
                Positioned(
                  left: 12,
                  right: 72,
                  top: 8,
                  child: Material(
                    color: BoardTheme.corkGrain.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        'Modo mover · arraste o cartão · solte para fixar',
                        style: TextStyle(fontSize: 11, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 10,
                bottom: 12,
                child: _fabColumn(engine),
              ),
              if (_connectFrom != null)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: _connectBanner(engine, nodes),
                ),
              if (_showTimeline)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 180,
                  child: _timelineStrip(engine),
                ),
            ],
          ),
        ),
        if (!reduceMotion && _freshConnectionId != null)
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _header(BoardProgressSnapshot snap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Conecte as pistas. Revele a verdade.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Arraste para mover o quadro · pinça ou +/- para zoom · segure um cartão para reposicionar',
            style: TextStyle(color: Colors.white30, fontSize: 9),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  'INVESTIGAÇÃO  ${(snap.percent * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                '${snap.foundClues}/${snap.totalClues} evidências · '
                '${snap.smartConnections}/${snap.targetConnections} conexões · '
                '${snap.investigatedSuspects}/${snap.totalSuspects} suspeitos',
                style: const TextStyle(color: Colors.white38, fontSize: 9),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: snap.percent.clamp(0.02, 1),
              minHeight: 3,
              backgroundColor: Colors.white10,
              color: BoardTheme.thread.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          for (final f in BoardFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(f.label, style: const TextStyle(fontSize: 11)),
                selected: _filter == f,
                onSelected: (_) => setState(() => _filter = f),
                selectedColor: BoardTheme.thread.withValues(alpha: 0.35),
                backgroundColor: Colors.white10,
                labelStyle: TextStyle(
                  color: _filter == f ? Colors.white : Colors.white70,
                ),
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
              ),
            ),
          IconButton(
            tooltip: 'Buscar',
            icon: const Icon(Icons.search, size: 18),
            onPressed: () => _promptSearch(),
          ),
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _search = v.trim().toLowerCase()),
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Procurar evidência...',
          isDense: true,
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () {
              _searchCtrl.clear();
              setState(() => _search = '');
            },
          ),
        ),
      ),
    );
  }

  Widget _fabColumn(GameEngine engine) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _miniFab(Icons.add, 'Aproximar', () => _zoomBy(1.28)),
        const SizedBox(height: 8),
        _miniFab(Icons.remove, 'Afastar', () => _zoomBy(1 / 1.28)),
        const SizedBox(height: 8),
        _miniFab(Icons.center_focus_strong, 'Centro', _centerBoard),
        const SizedBox(height: 8),
        _miniFab(Icons.zoom_out_map, 'Ver tudo', _fitAll),
        const SizedBox(height: 8),
        _miniFab(
          _showTimeline ? Icons.timeline : Icons.schedule,
          'Timeline',
          () => setState(() => _showTimeline = !_showTimeline),
        ),
        const SizedBox(height: 8),
        _miniFab(Icons.sticky_note_2_outlined, 'Nota', () => _addNote(engine)),
        const SizedBox(height: 8),
        _miniFab(Icons.lightbulb_outline, 'Teoria', () => _addTheory(engine)),
      ],
    );
  }

  Widget _miniFab(IconData icon, String tip, VoidCallback onTap) {
    return Tooltip(
      message: tip,
      child: Material(
        color: BoardTheme.corkGrain.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 18, color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _connectBanner(GameEngine engine, List<_BoardNode> nodes) {
    final from = nodes.where((e) => e.id == _connectFrom).firstOrNull;
    return Material(
      color: BoardTheme.corkGrain.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.timeline, color: BoardTheme.thread, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                from == null
                    ? 'Selecione outra pista para conectar'
                    : 'Conectar a partir de: ${from.title}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: () => setState(() {
                _connectFrom = null;
                _draftCursor = null;
              }),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineStrip(GameEngine engine) {
    final fmt = MaterialLocalizations.of(context);
    final events = engine.c.timeline.where(engine.isTimelineVisible).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return Material(
      color: const Color(0xEE141018),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                const Text(
                  'TIMELINE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () => setState(() => _showTimeline = false),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: events.length,
              itemBuilder: (_, i) {
                final e = events[i];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 10, bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${e.timestamp.hour.toString().padLeft(2, '0')}:'
                        '${e.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: OsisTheme.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, height: 1.25),
                      ),
                      const Spacer(),
                      Text(
                        e.location ?? e.source,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // silence unused
          Offstage(child: Text(fmt.formatTimeOfDay(TimeOfDay.now()))),
        ],
      ),
    );
  }

  Widget _boardNodeGestures(
    GameEngine engine,
    CoopEngine? coop,
    _BoardNode node,
  ) {
    final moving = _draggingNodeId == node.id;
    return GestureDetector(
      behavior: moving ? HitTestBehavior.opaque : HitTestBehavior.translucent,
      onTap: moving ? null : () => _onTapNode(engine, node),
      onLongPressStart: (_) {
        if (_connectFrom != null) return;
        HapticFeedback.mediumImpact();
        _dragOrigins[node.id] = Offset(node.layout.x, node.layout.y);
        setState(() => _draggingNodeId = node.id);
      },
      onLongPressMoveUpdate: moving
          ? (d) {
              final origin = _dragOrigins[node.id] ??
                  Offset(node.layout.x, node.layout.y);
              final scale = _currentScale;
              engine.moveBoardNode(
                node.id,
                (origin.dx + d.offsetFromOrigin.dx / scale)
                    .clamp(20.0, boardW - cardW - 20),
                (origin.dy + d.offsetFromOrigin.dy / scale)
                    .clamp(20.0, boardH - cardH - 20),
              );
            }
          : null,
      onLongPressEnd: (_) => _endNodeDrag(node.id),
      onLongPressCancel: () => _endNodeDrag(node.id, save: false),
      // Após "Mover" no modal, arraste normal reposiciona o cartão.
      onPanUpdate: moving
          ? (d) {
              final scale = _currentScale;
              engine.moveBoardNode(
                node.id,
                (node.layout.x + d.delta.dx / scale)
                    .clamp(20.0, boardW - cardW - 20),
                (node.layout.y + d.delta.dy / scale)
                    .clamp(20.0, boardH - cardH - 20),
              );
            }
          : null,
      onPanEnd: moving ? (_) => _endNodeDrag(node.id) : null,
      child: AnimatedScale(
        scale: moving ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: _cardFor(engine, coop, node),
      ),
    );
  }

  void _endNodeDrag(String id, {bool save = true}) {
    if (_draggingNodeId != id) return;
    setState(() {
      _draggingNodeId = null;
      _dragOrigins.remove(id);
    });
    if (save) autosave(context);
  }

  final Map<String, Offset> _dragOrigins = {};

  Widget _cardFor(GameEngine engine, CoopEngine? coop, _BoardNode node) {
    final selected = _selectedId == node.id ||
        _connectFrom == node.id ||
        _draggingNodeId == node.id;
    final badge = node.ownerBadge;

    Widget card;
    switch (node.kind) {
      case _NodeKind.person:
        card = PersonBoardCard(
          character: node.character!,
          ownerBadge: badge,
          onConnect: () => _startConnect(node.id),
        );
      case _NodeKind.clue:
        card = ClueBoardCard(
          clue: node.clue!,
          ownerBadge: badge,
          onConnect: () => _startConnect(node.id),
        );
      case _NodeKind.note:
        card = NoteBoardCard(
          note: node.note!,
          onConnect: () => _startConnect(node.id),
        );
      case _NodeKind.theory:
        card = TheoryBoardCard(
          theory: node.theory!,
          onConnect: () => _startConnect(node.id),
        );
    }

    return AnimatedScale(
      scale: selected ? 1.04 : 1.0,
      duration: const Duration(milliseconds: 160),
      child: card,
    );
  }

  void _startConnect(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_connectFrom == null) {
        _connectFrom = id;
        _draftCursor = null;
      } else if (_connectFrom == id) {
        _connectFrom = null;
      } else {
        _finishConnect(id);
      }
    });
  }

  Future<void> _finishConnect(String toId) async {
    final from = _connectFrom!;
    final engine = context.read<GameEngine>();
    final result = engine.addBoardConnection(from, toId);
    setState(() {
      _connectFrom = null;
      _draftCursor = null;
      _freshConnectionId = result.connection.id;
    });
    HapticFeedback.mediumImpact();
    await autosave(context);
    if (!mounted) return;
    if (result.deductionText != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: result.isContradiction
              ? const Color(0xFF4A1A12)
              : BoardTheme.corkGrain,
          content: Text(result.deductionText!),
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pistas conectadas'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _freshConnectionId = null);
    });
  }

  void _onTapNode(GameEngine engine, _BoardNode node) {
    if (_connectFrom != null) {
      if (_connectFrom != node.id) {
        _finishConnect(node.id);
      }
      return;
    }
    setState(() => _selectedId = node.id);
    _openDetail(engine, node);
  }

  Future<void> _openDetail(GameEngine engine, _BoardNode node) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xF0121014),
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.paddingOf(ctx).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      node.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              Text(
                node.subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(
                node.body,
                style: const TextStyle(height: 1.4, fontSize: 14),
              ),
              if (node.related.isNotEmpty) ...[
                const SizedBox(height: 14),
                const Text(
                  'Relacionada a',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: node.related
                      .map((e) => Chip(
                            label: Text(e, style: const TextStyle(fontSize: 11)),
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: BoardTheme.thread,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _startConnect(node.id);
                      },
                      icon: const Icon(Icons.timeline),
                      label: const Text('Conectar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _dragOrigins[node.id] =
                            Offset(node.layout.x, node.layout.y);
                        setState(() => _draggingNodeId = node.id);
                        HapticFeedback.selectionClick();
                      },
                      icon: const Icon(Icons.open_with, size: 18),
                      label: const Text('Mover'),
                    ),
                  ),
                  if (node.kind == _NodeKind.note) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Excluir nota',
                      onPressed: () {
                        engine.removeInvestigatorNote(node.id);
                        Navigator.pop(ctx);
                        autosave(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                  if (node.kind == _NodeKind.theory) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Excluir teoria',
                      onPressed: () {
                        engine.removeBoardTheory(node.id);
                        Navigator.pop(ctx);
                        autosave(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addNote(GameEngine engine) async {
    final text = TextEditingController();
    var tag = NoteTag.theory;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OsisTheme.bgElevated,
        title: const Text('O que você descobriu?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: text,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escreva no post-it…',
              ),
            ),
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
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Fixar no quadro')),
        ],
      ),
    );
    if (!mounted) return;
    if (ok == true && text.text.trim().isNotEmpty) {
      engine.addInvestigatorNote(text.text.trim(), tag);
      await autosave(context);
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _addTheory(GameEngine engine) async {
    final title = TextEditingController();
    final body = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OsisTheme.bgElevated,
        title: const Text('Nova teoria'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(hintText: 'Título'),
            ),
            TextField(
              controller: body,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Hipótese e raciocínio…',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Criar')),
        ],
      ),
    );
    if (!mounted) return;
    if (ok == true && body.text.trim().isNotEmpty) {
      engine.addBoardTheory(
        title: title.text.trim(),
        body: body.text.trim(),
        evidenceIds: engine.progress.discoveredClues.take(3).toList(),
      );
      await autosave(context);
    }
  }

  Future<void> _promptSearch() async {
    setState(() {});
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OsisTheme.bgElevated,
        title: const Text('Buscar no quadro'),
        content: TextField(
          autofocus: true,
          controller: _searchCtrl,
          decoration: const InputDecoration(
            hintText: 'Nome, local, pista, tag…',
          ),
          onSubmitted: (v) {
            setState(() => _search = v.trim().toLowerCase());
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _search = _searchCtrl.text.trim().toLowerCase());
              Navigator.pop(ctx);
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  bool _visible(_BoardNode node) {
    if (_search.isNotEmpty) {
      final hay =
          '${node.title} ${node.subtitle} ${node.body} ${node.tags.join(' ')}'
              .toLowerCase();
      if (!hay.contains(_search)) return false;
    }
    switch (_filter) {
      case BoardFilter.all:
        return true;
      case BoardFilter.people:
        return node.kind == _NodeKind.person;
      case BoardFilter.places:
        return node.kind == _NodeKind.clue &&
            node.clue?.type == ClueType.location;
      case BoardFilter.events:
        return node.kind == _NodeKind.clue &&
            (node.clue?.type == ClueType.call ||
                node.clue?.type == ClueType.timeline ||
                node.clue?.type == ClueType.message);
      case BoardFilter.clues:
        return node.kind == _NodeKind.clue;
      case BoardFilter.theories:
        return node.kind == _NodeKind.theory || node.kind == _NodeKind.note;
    }
  }

  List<_BoardNode> _buildNodes(GameEngine engine, CoopEngine? coop) {
    final nodes = <_BoardNode>[];
    var seed = 0;
    final pendingLayouts = <String, BoardNodeLayout>{};

    BoardNodeLayout layoutOf(String id) {
      final existing = engine.progress.boardLayouts[id];
      if (existing != null) return existing;
      final layout = BoardNodeLayout(
        x: 180 + (seed % 5) * 220.0 + (id.hashCode.abs() % 30).toDouble(),
        y: 160 + ((seed ~/ 5) % 6) * 200.0 + ((id.hashCode.abs() ~/ 3) % 40).toDouble(),
        rotation: ((id.hashCode.abs() % 11) - 5) * 0.012,
      );
      pendingLayouts[id] = layout;
      seed++;
      return layout;
    }

    // Vítima + personagens ligados a pistas descobertas
    final charIds = <String>{engine.c.victimId};
    for (final clueId in engine.progress.discoveredClues) {
      final clue = engine.c.clues.where((e) => e.id == clueId).firstOrNull;
      if (clue != null) charIds.addAll(clue.relatedCharacterIds);
    }
    for (final ch in engine.c.characters) {
      final include = ch.id == engine.c.victimId ||
          ch.role == CharacterRole.suspect ||
          ch.role == CharacterRole.mysterious ||
          charIds.contains(ch.id);
      if (!include) continue;
      final layout = layoutOf(ch.id);
      nodes.add(_BoardNode(
        id: ch.id,
        kind: _NodeKind.person,
        title: ch.name,
        subtitle: ch.relationToVictim,
        body: ch.personality,
        layout: layout,
        character: ch,
        tags: [ch.role.name, ch.name],
        related: engine.c.clues
            .where((c) =>
                engine.progress.discoveredClues.contains(c.id) &&
                c.relatedCharacterIds.contains(ch.id))
            .map((c) => c.name)
            .take(6)
            .toList(),
      ));
    }

    for (final clueId in engine.progress.discoveredClues) {
      final clue = engine.c.clues.where((e) => e.id == clueId).firstOrNull;
      if (clue == null) continue;
      final layout = layoutOf(clue.id);
      String? badge;
      if (coop != null && coop.isCoop) {
        if (coop.sharedClueIds.contains(clue.id)) {
          badge = 'SHARED';
        } else if (coop.role == CoopRole.playerA) {
          badge = 'A';
        } else if (coop.role == CoopRole.playerB) {
          badge = 'B';
        }
      }
      nodes.add(_BoardNode(
        id: clue.id,
        kind: _NodeKind.clue,
        title: clue.name,
        subtitle: '${clue.origin} · ${clue.type.name}',
        body: clue.content.isNotEmpty ? clue.content : clue.description,
        layout: layout,
        clue: clue,
        ownerBadge: badge,
        tags: [
          clue.type.name,
          clue.importance.name,
          ...clue.relatedCharacterIds,
        ],
        related: [
          ...clue.relatedClueIds.map((id) {
            return engine.c.clues.where((e) => e.id == id).firstOrNull?.name ??
                id;
          }),
          ...clue.relatedCharacterIds.map((id) {
            return engine.c.characters
                    .where((e) => e.id == id)
                    .firstOrNull
                    ?.name ??
                id;
          }),
        ],
      ));
    }

    for (final note in engine.progress.investigatorNotes) {
      final layout = engine.progress.boardLayouts[note.id] ??
          BoardNodeLayout(
            x: note.boardX ?? 400,
            y: note.boardY ?? 500,
            rotation: note.rotation,
          );
      if (!engine.progress.boardLayouts.containsKey(note.id)) {
        pendingLayouts[note.id] = layout;
      }
      nodes.add(_BoardNode(
        id: note.id,
        kind: _NodeKind.note,
        title: 'Post-it',
        subtitle: note.tag.name,
        body: note.text,
        layout: layout,
        note: note,
        tags: [note.tag.name, 'nota'],
      ));
    }

    for (final theory in engine.progress.boardTheories) {
      final layout = engine.progress.boardLayouts[theory.id] ??
          BoardNodeLayout(
            x: theory.boardX,
            y: theory.boardY,
            rotation: theory.rotation,
          );
      if (!engine.progress.boardLayouts.containsKey(theory.id)) {
        pendingLayouts[theory.id] = layout;
      }
      nodes.add(_BoardNode(
        id: theory.id,
        kind: _NodeKind.theory,
        title: theory.title,
        subtitle: 'Teoria',
        body: theory.body,
        layout: layout,
        theory: theory,
        tags: ['teoria', ...theory.evidenceIds],
        related: theory.evidenceIds
            .map((id) =>
                engine.c.clues.where((e) => e.id == id).firstOrNull?.name ?? id)
            .toList(),
      ));
    }

    if (pendingLayouts.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final e in pendingLayouts.entries) {
          if (!engine.progress.boardLayouts.containsKey(e.key)) {
            engine.setBoardNodeLayout(e.key, e.value);
          }
        }
      });
    }

    return nodes;
  }
}

enum _NodeKind { person, clue, note, theory }

class _BoardNode {
  final String id;
  final _NodeKind kind;
  final String title;
  final String subtitle;
  final String body;
  final BoardNodeLayout layout;
  final Character? character;
  final Clue? clue;
  final InvestigatorNote? note;
  final BoardTheory? theory;
  final String? ownerBadge;
  final List<String> tags;
  final List<String> related;

  _BoardNode({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.layout,
    this.character,
    this.clue,
    this.note,
    this.theory,
    this.ownerBadge,
    this.tags = const [],
    this.related = const [],
  });
}

class _CorkBackground extends StatelessWidget {
  final bool absorbPointers;

  const _CorkBackground({this.absorbPointers = false});

  @override
  Widget build(BuildContext context) {
    final paint = CustomPaint(
      painter: _CorkPainter(),
      child: const SizedBox.expand(),
    );
    // Área vazia precisa ser “hit-testável” para o pan do InteractiveViewer.
    if (!absorbPointers) return paint;
    return Listener(
      behavior: HitTestBehavior.opaque,
      child: paint,
    );
  }
}

class _CorkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2B1E14),
          Color(0xFF3A291C),
          Color(0xFF241810),
          Color(0xFF332418),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, base);

    final grain = Paint()..color = const Color(0x14F0E6D2);
    final rng = math.Random(42);
    for (var i = 0; i < 900; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 1.8 + 0.4, grain);
    }

    final groove = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 6), groove);
    }

    // Vinheta
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.45),
        ],
        stops: const [0.55, 1],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
