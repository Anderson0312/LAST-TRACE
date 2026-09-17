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

  void _centerBoard() {
    final size = MediaQuery.sizeOf(context);
    final scale = 0.42;
    final dx = (size.width - boardW * scale) / 2;
    final dy = (size.height * 0.35 - boardH * scale * 0.2);
    _transform.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  void _fitAll() {
    final size = MediaQuery.sizeOf(context);
    final sx = size.width / boardW;
    final sy = (size.height * 0.72) / boardH;
    final scale = math.min(sx, sy).clamp(0.22, 0.55);
    final dx = (size.width - boardW * scale) / 2;
    final dy = 24.0;
    _transform.value = Matrix4.identity()
      ..translateByDouble(dx, dy, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
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
                minScale: 0.2,
                maxScale: 2.2,
                boundaryMargin: const EdgeInsets.all(600),
                constrained: false,
                child: SizedBox(
                  width: boardW,
                  height: boardH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Positioned.fill(child: _CorkBackground()),
                      Positioned.fill(
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
                      for (final node in nodes)
                        if (_visible(node))
                          Positioned(
                            left: node.layout.x,
                            top: node.layout.y,
                            child: Transform.rotate(
                              angle: node.layout.rotation,
                              child: _draggableNode(engine, coop, node),
                            ),
                          ),
                    ],
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

