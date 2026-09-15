import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/assets/game_images.dart';
import '../../core/theme/osis_theme.dart';
import '../../domain/engines/game_engine.dart';
import '../../main.dart';
import '../phone/phone_shell.dart';

/// Introdução narrativa na 1ª abertura — Sofia Alves pede ajuda.
class IntroScreen extends StatefulWidget {
  final bool coopBriefing;
  const IntroScreen({super.key, this.coopBriefing = false});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int _step = 0;
  bool _skipBriefing = false;

  static const _pages = <_BriefPage>[
    _BriefPage(
      eyebrow: 'Chamada perdida · Sofia Alves',
      title: 'Preciso da sua ajuda.',
      body:
          'Meu nome é Sofia. Marina Alves é minha filha — 27 anos, jornalista. '
          'Ela sumiu depois do dia 13 de agosto. A polícia fala em “desaparecimento voluntário”. Eu não acredito.',
    ),
    _BriefPage(
      eyebrow: '14 de agosto · Estacionamento São Lucas',
      title: 'Encontraram o celular dela.',
      body:
          'O telefone estava no chão, perto de um pilar do estacionamento. '
          'Bateria ainda tinha carga. Ninguém sabe a senha — e a polícia devolveu o aparelho pra mim como se não houvesse mais o que fazer.',
    ),
    _BriefPage(
      eyebrow: 'Por que você',
      title: 'Eu não consigo olhar sozinha.',
      body:
          'Toda vez que abro uma conversa, travo. Mensagens apagadas, um contato só como “R.”, fotos que não fazem sentido… '
          'Me disseram que você entende de investigar pelos rastros digitais. Eu te entrego o telefone. Por favor: descubra o que aconteceu com a Marina.',
    ),
    _BriefPage(
      eyebrow: 'Como investigar',
      title: 'O celular é a cena do crime.',
      body:
          'Leia WhatsApp, Mail, Notas, Mapas, Fotos, Safari, Arquivos. '
          'Anote contradições no Quadro. Monte a linha do tempo. '
          'Alguém está mentindo — e alguém ainda pode estar olhando esse aparelho junto com você.',
    ),
  ];

  static const _coopPages = <_BriefPage>[
    _BriefPage(
      eyebrow: 'Modo cooperativo',
      title: 'Dois celulares. Uma verdade.',
      body:
          'Você e seu parceiro investigam aparelhos diferentes. '
          'Nenhum de vocês tem a história completa — e isso é proposital.',
    ),
    _BriefPage(
      eyebrow: 'Informação assimétrica',
      title: 'O que você achar é seu.',
      body:
          'Mensagens, fotos e arquivos não aparecem automaticamente no outro celular. '
          'Contem um ao outro. Compartilhem evidências no Quadro. Digitem códigos de pista se estiverem longe.',
    ),
    _BriefPage(
      eyebrow: 'Cross-clues',
      title: 'A pista só fecha em dois.',
      body:
          'Quando duas evidências complementares estiverem no painel compartilhado, o sistema pode revelar uma contradição ou uma nova linha do tempo. '
          'No fim, a acusação exige consenso.',
    ),
  ];

  List<_BriefPage> get _activePages =>
      widget.coopBriefing ? _coopPages : _pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final engine = context.read<GameEngine>();
      if (!widget.coopBriefing &&
          engine.progress.flags['briefing_done'] == true) {
        setState(() => _skipBriefing = true);
      } else {
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_step < _activePages.length - 1) {
      setState(() => _step++);
    } else {
      _enterPhone();
    }
  }

  Future<void> _enterPhone() async {
    final engine = context.read<GameEngine>();
    engine.setFlag('briefing_done', true);
    await autosave(context);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const PhoneShell(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_skipBriefing) {
      return const PhoneShell();
    }

    final page = _activePages[_step];
    final isLast = _step == _activePages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF07080C),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'ÚLTIMO ACESSO',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_step + 1}/${_pages.length}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_step + 1) / _pages.length,
                  minHeight: 3,
                  backgroundColor: Colors.white12,
                  color: OsisTheme.accent,
                ),
              ),
              const Spacer(flex: 1),
              // avatar / contact card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const GameAvatar(
                      characterId: 'char_sofia',
                      fallbackLetter: 'S',
                      radius: 26,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sofia Alves',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Mãe de Marina · mensagem de voz transcrita',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: Column(
                  key: ValueKey(_step),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      page.eyebrow,
                      style: TextStyle(
                        color: OsisTheme.accent.withValues(alpha: 0.9),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      page.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      page.body,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 16,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              if (_step == 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Algumas pessoas deixam mensagens. Outras deixam pistas.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: OsisTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _next,
                  child: Text(
                    isLast ? 'ACEITAR O CELULAR' : 'CONTINUAR',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                TextButton(
                  onPressed: _enterPhone,
                  child: Text(
                    'Pular introdução',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BriefPage {
  final String eyebrow;
  final String title;
  final String body;
  const _BriefPage({
    required this.eyebrow,
    required this.title,
    required this.body,
  });
}
