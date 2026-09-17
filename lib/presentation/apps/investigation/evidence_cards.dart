import 'package:flutter/material.dart';
import '../../../core/assets/game_images.dart';
import '../../../domain/models/models.dart';
import 'board_theme.dart';

/// Alfinete metálico no topo do cartão.
class BoardPin extends StatelessWidget {
  final bool highlight;
  final VoidCallback? onConnectTap;

  const BoardPin({super.key, this.highlight = false, this.onConnectTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onConnectTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 28,
        height: 22,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 10,
              child: Container(
                width: 3,
                height: 10,
                decoration: BoxDecoration(
                  color: BoardTheme.pinMetal,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 2,
              child: Container(
                width: highlight ? 14 : 12,
                height: highlight ? 14 : 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      highlight ? const Color(0xFFFFF8E7) : BoardTheme.pinHead,
                      BoardTheme.pinMetal,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                    if (highlight)
                      BoxShadow(
                        color: BoardTheme.thread.withValues(alpha: 0.55),
                        blurRadius: 8,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PersonBoardCard extends StatelessWidget {
  final Character character;
  final String? ownerBadge;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onConnect;

  const PersonBoardCard({
    super.key,
    required this.character,
    this.ownerBadge,
    this.onTap,
    this.onLongPress,
    this.onConnect,
  });

  Color get _labelColor {
    switch (character.role) {
      case CharacterRole.victim:
        return BoardTheme.labelVictim;
      case CharacterRole.suspect:
      case CharacterRole.mysterious:
        return BoardTheme.labelSuspect;
      case CharacterRole.witness:
        return BoardTheme.labelWitness;
      case CharacterRole.contact:
        return BoardTheme.labelContact;
    }
  }

  String get _roleLabel {
    switch (character.role) {
      case CharacterRole.victim:
        return 'VÍTIMA';
      case CharacterRole.suspect:
        return 'SUSPEITO';
      case CharacterRole.mysterious:
        return 'DESCONHECIDO';
      case CharacterRole.witness:
        return 'TESTEMUNHA';
      case CharacterRole.contact:
        return 'CONTATO';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PolaroidShell(
      width: 132,
      onTap: onTap,
      onLongPress: onLongPress,
      pin: BoardPin(onConnectTap: onConnect),
      badge: ownerBadge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: GameAssetImage(
              assetPath: GameImages.avatar(character.id),
              fit: BoxFit.cover,
              fallback: ColoredBox(
                color: const Color(0xFF2A2420),
                child: Center(
                  child: Text(
                    character.name.characters.first.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            character.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: BoardTheme.polaroidInk,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            character.relationToVictim.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: BoardTheme.polaroidInk.withValues(alpha: 0.55),
              fontSize: 8,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Transform.rotate(
              angle: -0.04,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _labelColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  _roleLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClueBoardCard extends StatelessWidget {
  final Clue clue;
  final String? ownerBadge;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onConnect;

  const ClueBoardCard({
    super.key,
    required this.clue,
    this.ownerBadge,
    this.onTap,
    this.onLongPress,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final critical = clue.importance == ClueImportance.critical;
    final high = clue.importance == ClueImportance.high;

    return _PolaroidShell(
      width: 148,
      paperTone: clue.type == ClueType.note
          ? const Color(0xFFF7F0D8)
          : BoardTheme.paper,
      onTap: onTap,
      onLongPress: onLongPress,
      pin: BoardPin(highlight: critical, onConnectTap: onConnect),
      badge: ownerBadge,
      borderColor: critical
          ? BoardTheme.thread.withValues(alpha: 0.7)
          : high
              ? BoardTheme.labelSuspect.withValues(alpha: 0.5)
              : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconFor(clue.type),
                  size: 14, color: BoardTheme.polaroidInk.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _typeLabel(clue.type),
                  style: TextStyle(
                    color: BoardTheme.polaroidInk.withValues(alpha: 0.55),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (critical || high)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  color: critical
                      ? BoardTheme.thread
                      : BoardTheme.labelSuspect,
                  child: Text(
                    critical ? 'CRÍTICA' : 'ALTA',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (clue.type == ClueType.photo)
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: _photoPreview(clue),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
                border: Border.all(color: BoardTheme.paperLines),
              ),
              child: Text(
                clue.content.isNotEmpty ? clue.content : clue.description,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: BoardTheme.polaroidInk.withValues(alpha: 0.9),
                  fontSize: 10,
                  height: 1.35,
                  fontStyle: clue.type == ClueType.note
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            clue.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: BoardTheme.polaroidInk,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            clue.origin,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: BoardTheme.polaroidInk.withValues(alpha: 0.45),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPreview(Clue clue) {
    // Tenta extrair id de foto do conteúdo/origem.
    final match = RegExp(r'ph\w+', caseSensitive: false)
        .firstMatch('${clue.content} ${clue.origin} ${clue.id}');
    final path = match != null
        ? GameImages.photo(match.group(0)!.toLowerCase())
        : GameImages.photo('ph1');
    return GameAssetImage(
      assetPath: path,
      fit: BoxFit.cover,
      fallback: const ColoredBox(
        color: Color(0xFF2A2420),
        child: Icon(Icons.photo, color: Colors.white24),
      ),
    );
  }

  static IconData _iconFor(ClueType t) {
    switch (t) {
      case ClueType.message:
        return Icons.chat_bubble_outline;
      case ClueType.photo:
        return Icons.photo_camera_outlined;
      case ClueType.location:
        return Icons.place_outlined;
      case ClueType.call:
        return Icons.call_outlined;
      case ClueType.email:
        return Icons.mail_outline;
      case ClueType.note:
        return Icons.sticky_note_2_outlined;
      case ClueType.file:
        return Icons.insert_drive_file_outlined;
      case ClueType.browser:
        return Icons.public;
      case ClueType.audio:
        return Icons.mic_none;
      case ClueType.contradiction:
        return Icons.warning_amber_outlined;
      case ClueType.password:
        return Icons.lock_outline;
      case ClueType.timeline:
        return Icons.schedule;
      case ClueType.metadata:
      case ClueType.environmental:
      case ClueType.system:
        return Icons.info_outline;
    }
  }

  static String _typeLabel(ClueType t) {
    switch (t) {
      case ClueType.message:
        return 'MENSAGEM';
      case ClueType.photo:
        return 'FOTOGRAFIA';
      case ClueType.location:
        return 'LOCALIZAÇÃO';
      case ClueType.call:
        return 'CHAMADA';
      case ClueType.email:
        return 'E-MAIL';
      case ClueType.note:
        return 'NOTA';
      case ClueType.file:
        return 'ARQUIVO';
      case ClueType.browser:
        return 'NAVEGADOR';
      case ClueType.audio:
        return 'ÁUDIO';
      case ClueType.contradiction:
        return 'CONTRADIÇÃO';
      case ClueType.password:
        return 'SENHA';
      case ClueType.timeline:
        return 'EVENTO';
      case ClueType.metadata:
        return 'METADADO';
      case ClueType.environmental:
        return 'AMBIENTE';
      case ClueType.system:
        return 'SISTEMA';
    }
  }
}

class NoteBoardCard extends StatelessWidget {
  final InvestigatorNote note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onConnect;

  const NoteBoardCard({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final bg = BoardTheme.stickyFor(note.colorStyle);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: 120,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
              decoration: BoxDecoration(
                color: bg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: Text(
                note.text,
                maxLines: 7,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: BoardTheme.polaroidInk,
                  fontSize: 11,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(child: BoardPin(onConnectTap: onConnect)),
            ),
          ],
        ),
      ),
    );
  }
}

class TheoryBoardCard extends StatelessWidget {
  final BoardTheory theory;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onConnect;

  const TheoryBoardCard({
    super.key,
    required this.theory,
    this.onTap,
    this.onLongPress,
    this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    return _PolaroidShell(
      width: 168,
      paperTone: BoardTheme.theoryBg,
      borderColor: BoardTheme.theoryBorder.withValues(alpha: 0.55),
      onTap: onTap,
      onLongPress: onLongPress,
      pin: BoardPin(onConnectTap: onConnect),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TEORIA',
            style: TextStyle(
              color: BoardTheme.theoryBorder,
              fontSize: 8,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            theory.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            theory.body,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 10,
              height: 1.35,
            ),
          ),
          if (theory.evidenceIds.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${theory.evidenceIds.length} evidência(s)',
              style: TextStyle(
                color: BoardTheme.theoryBorder.withValues(alpha: 0.9),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PolaroidShell extends StatelessWidget {
  final double width;
  final Widget child;
  final Widget pin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? paperTone;
  final Color? borderColor;
  final String? badge;

  const _PolaroidShell({
    required this.width,
    required this.child,
    required this.pin,
    this.onTap,
    this.onLongPress,
    this.paperTone,
    this.borderColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox(
        width: width,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
              decoration: BoxDecoration(
                color: paperTone ?? BoardTheme.polaroid,
                border: borderColor != null
                    ? Border.all(color: borderColor!, width: 1.2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: child,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(child: pin),
            ),
            if (badge != null)
              Positioned(
                top: 14,
                right: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: badge == 'SHARED'
                        ? BoardTheme.theoryBorder
                        : BoardTheme.corkGrain,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
