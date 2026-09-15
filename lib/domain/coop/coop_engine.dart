import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../engines/game_engine.dart';
import '../models/models.dart';
import 'coop_models.dart';
import '../../data/coop/coop_sync_service.dart';

/// Orquestra sessão cooperativa sobre o [GameEngine] local.
class CoopEngine extends ChangeNotifier {
  final GameEngine game;
  final CoopSyncService sync;
  final _uuid = const Uuid();

  CoopCaseMeta? meta;
  CoopRole? role;
  CoopRoomState? room;
  String? lastToast;
  StreamSubscription? _stateSub;
  StreamSubscription? _msgSub;

  CoopEngine({required this.game, CoopSyncService? sync})
      : sync = sync ?? CoopSyncService();

  bool get isCoop => role != null && room != null;
  bool get isHost => sync.isHost;
  String? get roomCode => room?.roomCode ?? sync.roomCode;

  Set<String> get sharedClueIds =>
      room?.sharedEvidence.map((e) => e.clueId).toSet() ?? {};

  Future<void> attachMeta(CoopCaseMeta m) async {
    meta = m;
    notifyListeners();
  }

  String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = Random();
    return List.generate(6, (_) => chars[r.nextInt(chars.length)]).join();
  }

  Future<String> createRoom({required CoopCaseMeta caseMeta}) async {
    meta = caseMeta;
    role = CoopRole.playerA;
    final code = generateRoomCode();
    final state = CoopRoomState(
      roomCode: code,
      caseId: caseMeta.id,
      playerAReady: true,
      draftA: AccusationDraft(role: CoopRole.playerA),
      draftB: AccusationDraft(role: CoopRole.playerB),
    );
    room = state;
    await sync.hostRoom(state);
    _listen();
    notifyListeners();
    return code;
  }

  Future<bool> joinRoom({
    required String code,
    required CoopCaseMeta caseMeta,
  }) async {
    meta = caseMeta;
    role = CoopRole.playerB;
    final existing = await sync.joinRoom(code);
    room = existing ??
        CoopRoomState(
          roomCode: code.toUpperCase(),
          caseId: caseMeta.id,
          playerBReady: true,
          draftA: AccusationDraft(role: CoopRole.playerA),
          draftB: AccusationDraft(role: CoopRole.playerB),
        );
    if (existing == null) {
      // Sala ainda não espelhada neste dispositivo — cria espelho local B.
      room = room!.copyWith(playerBReady: true);
      await sync.publish(room!);
    } else {
      room = existing.copyWith(playerBReady: true);
      await sync.publish(room!);
    }
    _listen();
    notifyListeners();
    return true;
  }

  Future<void> markReady() async {
    if (room == null || role == null) return;
    room = role == CoopRole.playerA
        ? room!.copyWith(playerAReady: true)
        : room!.copyWith(playerBReady: true);
    await sync.publish(room!);
    notifyListeners();
  }

  Future<void> startInvestigation() async {
    if (room == null) return;
    room = room!.copyWith(started: true);
    await sync.publish(room!);
    notifyListeners();
  }

  /// Compartilha uma pista descoberta localmente para o painel comum.
  Future<SharedEvidenceItem?> shareClue(String clueId) async {
    if (room == null || role == null || meta == null) return null;
    if (!game.progress.discoveredClues.contains(clueId)) {
      lastToast = 'Você ainda não descobriu essa pista.';
      notifyListeners();
      return null;
    }
    if (room!.sharedEvidence.any((e) => e.clueId == clueId)) {
      lastToast = 'Essa pista já está nas evidências compartilhadas.';
      notifyListeners();
      return null;
    }

    final clue = game.c.clues.where((e) => e.id == clueId).firstOrNull;
    final item = SharedEvidenceItem(
      id: _uuid.v4(),
      clueId: clueId,
      sharedBy: role!,
      title: clue?.name ?? clueId,
      summary: clue?.content ?? clue?.description ?? '',
    );
    final list = [...room!.sharedEvidence, item];
    room = room!.copyWith(sharedEvidence: list);
    await sync.publish(room!);
    await _tryResolveCrossClues();
    lastToast = 'Evidência compartilhada: ${item.title}';
    notifyListeners();
    return item;
  }

  /// Importa evidência pelo código verbal (funciona sem rede).
  Future<bool> importShareCode(String code) async {
    if (meta == null || room == null || role == null) return false;
    final clueId = decodeShareCode(code.trim().toUpperCase());
    if (clueId == null) {
      lastToast = 'Código inválido.';
      notifyListeners();
      return false;
    }
    if (room!.sharedEvidence.any((e) => e.clueId == clueId)) {
      lastToast = 'Já está no painel compartilhado.';
      notifyListeners();
      return true;
    }
    final clue = game.caseData?.clues.where((e) => e.id == clueId).firstOrNull;
    final catalogTitle = _shareTitles[clueId];
    final item = SharedEvidenceItem(
      id: _uuid.v4(),
      clueId: clueId,
      sharedBy: role == CoopRole.playerA ? CoopRole.playerB : CoopRole.playerA,
      title: clue?.name ?? catalogTitle ?? clueId,
      summary: clue?.content ??
          catalogTitle ??
          'Evidência importada do outro investigador · $clueId',
    );
    room = room!.copyWith(sharedEvidence: [...room!.sharedEvidence, item]);
    await sync.publish(room!);
    await _tryResolveCrossClues();
    lastToast = 'Importou: ${item.title}';
    notifyListeners();
    return true;
  }

  static const _shareTitles = <String, String>{
    'CLUE_NOTE_IF': 'Se alguma coisa acontecer comigo…',
    'CLUE_NOTE_R': 'Lembrete: R. = RO',
    'CLUE_BRUNO_PRESSURE': 'Pressão de Bruno',
    'CLUE_PHOTO_PLATE': 'Placa parcial',
    'CLUE_EMAIL_DANIEL': 'E-mail: segura a matéria',
    'CLUE_CALL_UNKNOWN': 'Ligação 23:41 — desconhecido',
    'CLUE_REMOTE_ACCESS': 'Acesso remoto',
    'CLUE_B_LOC_PARKING': 'Camila no São Lucas às 23:24',
    'CLUE_B_BRUNO_ORDER': 'Bruno manda Camila ao pilar B',
    'CLUE_B_PHOTO_CAR': 'Foto nítida da placa ValeLog',
    'CLUE_B_RITA_BDAY': 'Aniversário Rita 0403',
    'CLUE_B_AUDIO_DANIEL': 'Áudio: Daniel pressiona Camila',
    'CLUE_B_GUILT_NOTE': 'Nota de culpa de Camila',
    'CLUE_CROSS_LURE_TIME': 'Encontro armado',
    'CLUE_CROSS_BRUNO_LIE': 'Bruno mentiu sobre a reunião',
  };

  String encodeShareCode(String clueId) {
    // Código estável e digitável a partir do id da pista.
    final compact = clueId.replaceAll('CLUE_', '').replaceAll('_', '');
    final slice = compact.length <= 8
        ? compact
        : compact.substring(0, 4) + compact.substring(compact.length - 4);
    return slice.toUpperCase();
  }

  String? decodeShareCode(String code) {
    final clues = <String>{
      ...?game.caseData?.clues.map((e) => e.id),
      ...?meta?.crossClues.expand((c) => c.requiresClueIds),
      ...?meta?.crossClues.expand((c) => c.revealsClueIds),
      ..._shareTitles.keys,
    };
    for (final id in clues) {
      if (encodeShareCode(id) == code) return id;
    }
    if (clues.contains(code) || clues.contains('CLUE_$code')) {
      return clues.contains(code) ? code : 'CLUE_$code';
    }
    return null;
  }

  Future<void> linkShared(String fromId, String toId, {String? label}) async {
    if (room == null || role == null) return;
    final link = SharedLink(
      id: _uuid.v4(),
      fromClueId: fromId,
      toClueId: toId,
      label: label,
      createdBy: role!,
    );
    room = room!.copyWith(sharedLinks: [...room!.sharedLinks, link]);
    await sync.publish(room!);
    await _tryResolveCrossClues();
    notifyListeners();
  }

  Future<void> _tryResolveCrossClues() async {
    if (meta == null || room == null) return;
    final have = sharedClueIds;
    final resolved = {...room!.resolvedCrossClues};
    var changed = false;

    for (final cross in meta!.crossClues) {
      if (resolved.contains(cross.id)) continue;
      if (!cross.requiresClueIds.every(have.contains)) continue;

      // Precisa de um vínculo explícito OU todas as pistas já compartilhadas.
      final linked = room!.sharedLinks.any((l) =>
          cross.requiresClueIds.contains(l.fromClueId) &&
          cross.requiresClueIds.contains(l.toClueId));
      final auto = cross.requiresClueIds.length <= 2 || linked;
      if (!auto && !linked) continue;

      resolved.add(cross.id);
      changed = true;
      for (final id in cross.revealsClueIds) {
        if (game.c.clues.any((e) => e.id == id)) {
          game.discoverClue(id, analyzed: true);
        } else {
          game.progress.discoveredClues.add(id);
          game.progress.analyzedClues.add(id);
        }
      }
      for (final id in cross.unlockContentIds) {
        game.progress.unlockedContent.add(id);
      }
      game.progress = game.progress.copyWith(
        investigationScore: game.progress.investigationScore + cross.scoreBonus,
      );
      lastToast = 'CROSS-CLUE: ${cross.title}';
      await sync.send(CoopEnvelope('cross_resolved', {
        'id': cross.id,
        'title': cross.title,
        'deduction': cross.deduction,
      }));
    }

    if (changed) {
      room = room!.copyWith(resolvedCrossClues: resolved);
      await sync.publish(room!);
      notifyListeners();
    }
  }

  Future<void> updateDraft(AccusationDraft draft) async {
    if (room == null) return;
    room = draft.role == CoopRole.playerA
        ? room!.copyWith(draftA: draft)
        : room!.copyWith(draftB: draft);
    await sync.publish(room!);
    notifyListeners();
  }

  Future<Ending?> tryConfirmConsensus() async {
    if (room == null || !room!.consensusReady) {
      lastToast = 'As investigações não convergem ainda.';
      notifyListeners();
      return null;
    }
    final suspect = room!.draftA!.suspectId!;
    final ending = game.evaluateEnding(accusedId: suspect);
    room = room!.copyWith(chosenEndingId: ending?.id);
    await sync.publish(room!);
    notifyListeners();
    return ending;
  }

  void _listen() {
    _stateSub?.cancel();
    _msgSub?.cancel();
    _stateSub = sync.states.listen((s) {
      room = s;
      notifyListeners();
    });
    _msgSub = sync.messages.listen((m) {
      if (m.type == 'cross_resolved') {
        lastToast = 'Parceiro resolveu: ${m.payload['title']}';
        notifyListeners();
      } else if (m.type == 'hello' && isHost) {
        // Host republica estado.
        if (room != null) sync.publish(room!);
      }
    });
  }

  List<CrossClueDef> get pendingCrossClues {
    if (meta == null || room == null) return const [];
    return meta!.crossClues
        .where((c) => !room!.resolvedCrossClues.contains(c.id))
        .toList();
  }

  List<CrossClueDef> get resolvedCrossClues {
    if (meta == null || room == null) return const [];
    return meta!.crossClues
        .where((c) => room!.resolvedCrossClues.contains(c.id))
        .toList();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _msgSub?.cancel();
    sync.dispose();
    super.dispose();
  }
}
