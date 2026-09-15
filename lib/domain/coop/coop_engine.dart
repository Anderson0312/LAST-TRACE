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
    room = room!.copyWith(sharedEvidence: [...room!.sharedEvidence, item]);
    await sync.publish(room!);
    lastToast = 'Evidência compartilhada: ${item.title}';
    notifyListeners();
    return item;
  }

  void _listen() {
    _stateSub?.cancel();
    _msgSub?.cancel();
    _stateSub = sync.states.listen((s) {
      room = s;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _msgSub?.cancel();
    sync.dispose();
    super.dispose();
  }
}
