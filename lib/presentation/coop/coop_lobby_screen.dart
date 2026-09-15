import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/osis_theme.dart';
import '../../data/coop/coop_case_loader.dart';
import '../../data/repositories/case_repository.dart';
import '../../domain/coop/coop_engine.dart';
import '../../domain/coop/coop_models.dart';
import '../../domain/engines/game_engine.dart';
import '../intro/intro_screen.dart';

class CoopLobbyScreen extends StatefulWidget {
  const CoopLobbyScreen({super.key});

  @override
  State<CoopLobbyScreen> createState() => _CoopLobbyScreenState();
}

class _CoopLobbyScreenState extends State<CoopLobbyScreen> {
  final _codeCtrl = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _createdCode;
  CoopCaseMeta? _meta;

  @override
  void initState() {
    super.initState();
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    final loader = CoopCaseLoader(context.read<CaseRepository>());
    final meta = await loader.loadMeta('case_001_coop');
    setState(() => _meta = meta);
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _host() async {
    if (_meta == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final coop = context.read<CoopEngine>();
      final engine = context.read<GameEngine>();
      final loader = CoopCaseLoader(context.read<CaseRepository>());
      final code = await coop.createRoom(caseMeta: _meta!);
      final device = await loader.loadDevice(_meta!, CoopRole.playerA);
      if (!mounted) return;
      engine.loadCase(device);
      engine.startLiveLoop();
      setState(() => _createdCode = code);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _join() async {
    if (_meta == null) return;
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length < 4) {
      setState(() => _error = 'Digite o código da sala.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final coop = context.read<CoopEngine>();
      final engine = context.read<GameEngine>();
      final loader = CoopCaseLoader(context.read<CaseRepository>());
      await coop.joinRoom(code: code, caseMeta: _meta!);
      final device = await loader.loadDevice(_meta!, CoopRole.playerB);
      if (!mounted) return;
      engine.loadCase(device);
      engine.startLiveLoop();
      await coop.markReady();
      if (!mounted) return;
      await _enter();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _enter() async {
    final coop = context.read<CoopEngine>();
    await coop.startInvestigation();
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => IntroScreen(coopBriefing: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coop = context.watch<CoopEngine>();
    final meta = _meta;

    return Scaffold(
      backgroundColor: const Color(0xFF07090D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Cooperativo'),
      ),
      body: meta == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  meta.slogan,
                  style: TextStyle(
                    color: OsisTheme.accent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Cada um recebe um celular diferente. Compartilhem pistas — verbalmente ou pelo painel — para montar a verdade.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 22),
                _deviceCard(meta.deviceA, 'Investigador A'),
                const SizedBox(height: 10),
                _deviceCard(meta.deviceB, 'Investigador B'),
                const SizedBox(height: 28),
                if (_createdCode == null) ...[
                  FilledButton(
                    onPressed: _busy ? null : _host,
                    child: const Text('Criar investigação (sou A)'),
                  ),
                  const SizedBox(height: 18),
                  const Text('Já tem código?',
                      style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(
                      letterSpacing: 4,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'ABC123',
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _busy ? null : _join,
                    child: const Text('Entrar como Investigador B'),
                  ),
                ] else ...[
                  const Text('Código da sala',
                      style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 8),
                  SelectableText(
                    _createdCode!,
                    style: TextStyle(
                      color: OsisTheme.accent,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    coop.room?.playerBReady == true
                        ? 'Investigador B conectou.'
                        : 'Mostre o código ao parceiro. Em outro celular/aba, entre como B.\n(Abas no mesmo navegador sincronizam na hora; celulares diferentes usam PeerJS.)',
                    style: const TextStyle(color: Colors.white54, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            await coop.markReady();
                            await _enter();
                          },
                    child: Text(
                      coop.room?.playerBReady == true
                          ? 'Começar juntos'
                          : 'Começar mesmo assim (A)',
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                ],
              ],
            ),
    );
  }

  Widget _deviceCard(CoopDeviceMeta d, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          const SizedBox(height: 4),
          Text(d.ownerName,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
          Text(d.ownerRelation,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 6),
          Text(d.tagline,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
