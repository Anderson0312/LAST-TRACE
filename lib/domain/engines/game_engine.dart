import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

/// Motor principal — orquestra pistas, desbloqueios, score e finais.
class GameEngine extends ChangeNotifier {
  GameCase? caseData;
  InvestigationProgress progress = InvestigationProgress(caseId: 'case_001');
  final List<PhoneNotification> notifications = [];
  final List<String> recentApps = [];
  String? foregroundApp;
  IslandState islandState = IslandState.idle;
  String islandLabel = '';
  bool debugMode = kDebugMode;
  bool reduceMotion = false;
  double fontScale = 1.0;
  bool hapticsEnabled = true;
  bool soundEnabled = true;

  final _uuid = const Uuid();
  final List<void Function(LiveEvent)> _liveListeners = [];
  Timer? _liveTimer;

  bool get isLoaded => caseData != null;
  GameCase get c => caseData!;

  void loadCase(GameCase data, {InvestigationProgress? saved}) {
    caseData = data;
    progress = saved ??
        InvestigationProgress(
          caseId: data.id,
          suspectSuspicion: {
            for (final ch in data.characters.where((e) => e.role == CharacterRole.suspect))
              ch.id: ch.initialSuspicion,
          },
          unlockedTimeline: {
            for (final t in data.timeline.where((e) => e.initiallyVisible)) t.id,
          },
          batteryPercent: (data.osState['battery'] as int?) ?? 87,
          targetPlaySeconds:
              (data.osState['targetPlaySeconds'] as num?)?.toInt() ?? 1800,
        );

    // pistas iniciais
    for (final clue in data.clues.where((e) => e.initialState != DiscoveryState.hidden)) {
      progress.discoveredClues.add(clue.id);
    }

    notifications
      ..clear()
      ..addAll(data.initialNotifications.map((n) => PhoneNotification(
            id: n.id,
            appId: n.appId,
            title: n.title,
            body: n.body,
            timestamp: n.timestamp,
            revealsClueIds: n.revealsClueIds,
          )));

    _recomputeScores();
    notifyListeners();
  }

  void unlockDevice() {
    progress = progress.copyWith(deviceUnlocked: true);
    _discover('CLUE_LOCK_OPEN');
    _syncDyingBattery();
    notifyListeners();
  }

  bool tryPin(String pin) {
    if (caseData == null) return false;
    if (pin == c.lockPin) {
      unlockDevice();
      return true;
    }
    return false;
  }

  void openApp(String appId) {
    foregroundApp = appId;
    if (!recentApps.contains(appId)) {
      recentApps.insert(0, appId);
      if (recentApps.length > 8) recentApps.removeLast();
    }
    _checkLiveEvents(trigger: 'open_app', extra: {'appId': appId});
    notifyListeners();
  }

  void closeApp() {
    foregroundApp = null;
    islandState = IslandState.idle;
    islandLabel = '';
    notifyListeners();
  }

  void discoverClue(String clueId, {bool analyzed = false}) {
    if (caseData == null) return;
    if (!c.clues.any((e) => e.id == clueId)) return;
    final wasNew = !progress.discoveredClues.contains(clueId);
    progress.discoveredClues.add(clueId);
    if (analyzed) progress.analyzedClues.add(clueId);
    if (wasNew) {
      _applyUnlockRules();
      _recomputeScores();
      _checkLiveEvents(trigger: 'clue', extra: {'clueId': clueId});
      notifyListeners();
    } else if (analyzed) {
      _recomputeScores();
      notifyListeners();
    }
  }

  void _discover(String id) => discoverClue(id);

  void revealFromContent(List<String> clueIds) {
    for (final id in clueIds) {
      discoverClue(id);
    }
  }

  void markConversationOpened(String id) {
    progress.openedConversations.add(id);
    final conv = c.conversations.where((e) => e.id == id).firstOrNull;
    if (conv != null) revealFromContent(conv.revealsClueIds);
    // Limpa badge de notificação do WhatsApp quando a conversa for aberta
    for (final n in notifications.where((n) =>
        (n.appId == 'pulse' || n.appId == 'whatsapp') && !n.read)) {
      n.read = true;
    }
    notifyListeners();
  }

  bool isConversationUnread(Conversation conv) {
    if (!conv.unread) return false;
    return !progress.openedConversations.contains(conv.id);
  }

  int get unreadWhatsAppCount => c.conversations
      .where(isConversationUnread)
      .length;

  void markMessageOpened(String id, List<String> clues) {
    progress.openedMessages.add(id);
    revealFromContent(clues);
    notifyListeners();
  }

  void viewPhoto(String id, List<String> clues) {
    progress.viewedPhotos.add(id);
    revealFromContent(clues);
    notifyListeners();
  }

  void unlockHotspot(PhotoHotspot hs) {
    revealFromContent(hs.revealsClueIds);
  }

  bool isContentUnlocked(String contentId) {
    // conteúdo sem trava = liberado; com trava precisa estar em unlockedContent
    return progress.unlockedContent.contains(contentId);
  }

  bool isMessageReadable(ChatMessage m) {
    if (!m.locked) return true;
    if (m.unlockWithClueIds.isEmpty) {
      return progress.unlockedContent.contains(m.id);
    }
    return m.unlockWithClueIds.every(progress.discoveredClues.contains);
  }

  bool isTimelineVisible(TimelineEvent e) {
    if (e.initiallyVisible) return true;
    if (progress.unlockedTimeline.contains(e.id)) return true;
    if (e.unlockWithClueIds.isEmpty) return false;
    return e.unlockWithClueIds.every(progress.discoveredClues.contains);
  }

  bool trySolvePuzzle(String puzzleId, String attempt) {
    final puzzle = c.puzzles.where((e) => e.id == puzzleId).firstOrNull;
    if (puzzle == null) return false;
    final normalized = attempt.trim().toLowerCase();
    final ok = normalized == puzzle.answer.toLowerCase() ||
        puzzle.alternateAnswers.any((a) => a.toLowerCase() == normalized);
    if (!ok) return false;
    progress.solvedPuzzles.add(puzzleId);
    for (final id in puzzle.unlockOnSolve) {
      progress.unlockedContent.add(id);
      discoverClue(id);
    }
    revealFromContent(puzzle.relatedClueIds);
    _applyUnlockRules();
    _recomputeScores();
    notifyListeners();
    return true;
  }

  void markContradiction(String id) {
    final contra = c.contradictions.where((e) => e.id == id).firstOrNull;
    if (contra == null) return;
    final hasEvidence =
        contra.evidenceClueIds.every(progress.discoveredClues.contains);
    if (!hasEvidence) return;
    progress.markedContradictions.add(id);
    revealFromContent(contra.revealsClueIds);
    _recomputeScores();
    notifyListeners();
  }

  /// Resultado de uma conexão (smart deduction / contradição).
  BoardConnectionResult addBoardConnection(
    String fromId,
    String toId, {
    String? label,
    BoardRelationType? relation,
  }) {
    final inferred = _inferRelation(fromId, toId);
    final conn = BoardConnection(
      id: _uuid.v4(),
      fromId: fromId,
      toId: toId,
      label: label ?? inferred.label,
      relation: relation ?? inferred.relation,
      isSmart: inferred.isSmart,
      deductionText: inferred.deductionText,
    );
    progress.boardConnections.add(conn);

    // Auto-marcar contradições quando as evidências forem ligadas.
    for (final contra in c.contradictions) {
      if (progress.markedContradictions.contains(contra.id)) continue;
      final ids = contra.evidenceClueIds.toSet();
      if (ids.contains(fromId) && ids.contains(toId)) {
        markContradiction(contra.id);
      }
    }

    notifyListeners();
    return BoardConnectionResult(
      connection: conn,
      deductionText: inferred.deductionText,
      isContradiction: inferred.relation == BoardRelationType.contradicts,
    );
  }

  void removeBoardConnection(String id) {
    progress.boardConnections.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void setBoardNodeLayout(String nodeId, BoardNodeLayout layout) {
    progress.boardLayouts[nodeId] = layout;
    notifyListeners();
  }

  void moveBoardNode(String nodeId, double x, double y) {
    final prev = progress.boardLayouts[nodeId];
    progress.boardLayouts[nodeId] = (prev ?? const BoardNodeLayout(x: 0, y: 0))
        .copyWith(x: x, y: y, pinnedToBoard: true);
    notifyListeners();
  }

  BoardNodeLayout ensureBoardLayout(String nodeId, {int seed = 0}) {
    final existing = progress.boardLayouts[nodeId];
    if (existing != null) return existing;
    final layout = _defaultLayoutFor(nodeId, seed);
    progress.boardLayouts[nodeId] = layout;
    return layout;
  }

  BoardNodeLayout _defaultLayoutFor(String nodeId, int seed) {
    final h = nodeId.hashCode.abs() + seed * 17;
    final col = h % 5;
    final row = (h ~/ 5) % 6;
    final rot = ((h % 11) - 5) * 0.012;
    return BoardNodeLayout(
      x: 180 + col * 220.0 + (h % 30).toDouble(),
      y: 160 + row * 200.0 + ((h ~/ 3) % 40).toDouble(),
      rotation: rot,
    );
  }

  void addInvestigatorNote(
    String text,
    NoteTag tag, {
    double? boardX,
    double? boardY,
  }) {
    final idx = progress.investigatorNotes.length;
    progress.investigatorNotes.insert(
      0,
      InvestigatorNote(
        id: _uuid.v4(),
        text: text,
        tag: tag,
        boardX: boardX ?? (320 + (idx % 4) * 40.0),
        boardY: boardY ?? (520 + (idx % 3) * 50.0),
        colorStyle: idx % 4,
        rotation: -0.05 + (idx % 5) * 0.02,
      ),
    );
    notifyListeners();
  }

  void updateInvestigatorNote(InvestigatorNote note) {
    final i = progress.investigatorNotes.indexWhere((e) => e.id == note.id);
    if (i < 0) return;
    progress.investigatorNotes[i] = note;
    notifyListeners();
  }

  void removeInvestigatorNote(String id) {
    progress.investigatorNotes.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addBoardTheory({
    required String title,
    required String body,
    List<String> evidenceIds = const [],
  }) {
    final n = progress.boardTheories.length + 1;
    progress.boardTheories.add(BoardTheory(
      id: _uuid.v4(),
      title: title.isEmpty ? 'Teoria #$n' : title,
      body: body,
      evidenceIds: evidenceIds,
      boardX: 700 + (n % 3) * 40.0,
      boardY: 280 + (n % 4) * 60.0,
    ));
    notifyListeners();
  }

  void updateBoardTheory(BoardTheory theory) {
    final i = progress.boardTheories.indexWhere((e) => e.id == theory.id);
    if (i < 0) return;
    progress.boardTheories[i] = theory;
    notifyListeners();
  }

  void removeBoardTheory(String id) {
    progress.boardTheories.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  _InferredRelation _inferRelation(String fromId, String toId) {
    final fromClue = c.clues.where((e) => e.id == fromId).firstOrNull;
    final toClue = c.clues.where((e) => e.id == toId).firstOrNull;
    final fromChar = c.characters.where((e) => e.id == fromId).firstOrNull;
    final toChar = c.characters.where((e) => e.id == toId).firstOrNull;

    // Contradição narrativa
    for (final contra in c.contradictions) {
      final ids = contra.evidenceClueIds.toSet();
      if ((ids.contains(fromId) && ids.contains(toId)) ||
          (fromChar != null &&
              contra.characterId == fromChar.id &&
              ids.contains(toId)) ||
          (toChar != null &&
              contra.characterId == toChar.id &&
              ids.contains(fromId))) {
        return _InferredRelation(
          relation: BoardRelationType.contradicts,
          label: 'CONTRADIÇÃO',
          isSmart: true,
          deductionText:
              '⚠ Contradição detectada: ${contra.statement}',
        );
      }
    }

    if (fromClue != null && toClue != null) {
      final related = fromClue.relatedClueIds.contains(toId) ||
          toClue.relatedClueIds.contains(fromId);
      final samePeople = fromClue.relatedCharacterIds
          .toSet()
          .intersection(toClue.relatedCharacterIds.toSet())
          .isNotEmpty;
      if (related &&
          fromClue.type == ClueType.location &&
          toClue.type == ClueType.message) {
        return _InferredRelation(
          relation: BoardRelationType.sameTime,
          label: 'CORROBORA',
          isSmart: true,
          deductionText:
              'Nova dedução: ${fromClue.name} e ${toClue.name} se reforçam no mesmo intervalo.',
        );
      }
      if (related) {
        return _InferredRelation(
          relation: BoardRelationType.confirms,
          label: 'CORROBORA',
          isSmart: true,
          deductionText:
              'Nova dedução desbloqueada entre ${fromClue.name} e ${toClue.name}.',
        );
      }
      if (samePeople) {
        return _InferredRelation(
          relation: BoardRelationType.samePerson,
          label: 'MESMA PESSOA',
          isSmart: true,
          deductionText: 'As pistas apontam para as mesmas pessoas.',
        );
      }
      if (fromClue.type == ClueType.location &&
          toClue.type == ClueType.location) {
        return const _InferredRelation(
          relation: BoardRelationType.samePlace,
          label: 'MESMO LOCAL',
        );
      }
    }

    if ((fromChar != null && toClue != null) ||
        (toChar != null && fromClue != null)) {
      final char = fromChar ?? toChar!;
      final clue = fromClue ?? toClue!;
      if (clue.relatedCharacterIds.contains(char.id)) {
        return _InferredRelation(
          relation: BoardRelationType.evidence,
          label: 'EVIDÊNCIA',
          isSmart: true,
          deductionText: '${clue.name} liga-se a ${char.name}.',
        );
      }
    }

    return const _InferredRelation(
      relation: BoardRelationType.related,
      label: 'RELACIONADO',
    );
  }

  /// Contagens para o painel de progresso do quadro.
  BoardProgressSnapshot boardProgressSnapshot() {
    final totalClues = c.clues.where((e) => !e.isRedHerring).length;
    final found = progress.discoveredClues
        .where((id) => c.clues.any((e) => e.id == id && !e.isRedHerring))
        .length;
    final importantLinks = progress.boardConnections
        .where((e) =>
            e.isSmart ||
            e.relation == BoardRelationType.confirms ||
            e.relation == BoardRelationType.contradicts)
        .length;
    final suspects = c.characters.where((e) => e.role == CharacterRole.suspect);
    final investigated = suspects.where((s) {
      return progress.discoveredClues.any((id) {
        final clue = c.clues.where((e) => e.id == id).firstOrNull;
        return clue?.relatedCharacterIds.contains(s.id) ?? false;
      });
    }).length;
    final pct = totalClues == 0 ? 0.0 : found / totalClues;
    return BoardProgressSnapshot(
      percent: pct,
      foundClues: found,
      totalClues: totalClues,
      smartConnections: importantLinks,
      targetConnections: math.max(8, (totalClues / 4).round()),
      investigatedSuspects: investigated,
      totalSuspects: suspects.length,
    );
  }

  void pushNotification(PhoneNotification n) {
    notifications.insert(0, n);
    revealFromContent(n.revealsClueIds);
    islandState = IslandState.notification;
    islandLabel = n.title;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      if (islandState == IslandState.notification) {
        islandState = IslandState.idle;
        islandLabel = '';
        notifyListeners();
      }
    });
  }

  void setIsland(IslandState state, String label) {
    islandState = state;
    islandLabel = label;
    notifyListeners();
  }

  void setFlag(String key, dynamic value) {
    progress.flags[key] = value;
    notifyListeners();
  }

  bool getFlag(String key) => progress.flags[key] == true;

  void triggerRemoteAccess() {
    if (progress.remoteAccessDetected) return;
    progress = progress.copyWith(
      remoteAccessDetected: true,
      batteryPercent: (progress.batteryPercent - 6).clamp(1, 100),
    );
    progress.flags['unknown_device'] = true;
    discoverClue('CLUE_REMOTE_ACCESS');
    pushNotification(PhoneNotification(
      id: _uuid.v4(),
      appId: 'settings',
      title: 'OSIS Segurança',
      body: 'Acesso remoto detectado',
      revealsClueIds: const ['CLUE_REMOTE_ACCESS'],
    ));
    setIsland(IslandState.unknownActivity, 'atividade desconhecida');
  }

  void _applyUnlockRules() {
    for (final rule in c.unlockRules) {
      final have = rule.requiredClueIds.where(progress.discoveredClues.contains).length;
      final need = rule.minRequired > 0 ? rule.minRequired : rule.requiredClueIds.length;
      if (have < need) continue;
      for (final id in rule.unlockClueIds) {
        progress.discoveredClues.add(id);
      }
      for (final id in rule.unlockTimelineIds) {
        progress.unlockedTimeline.add(id);
      }
      for (final id in rule.unlockContentIds) {
        progress.unlockedContent.add(id);
      }
      if (rule.notificationText != null &&
          !progress.flags.containsKey('rule_notif_${rule.id}')) {
        progress.flags['rule_notif_${rule.id}'] = true;
        pushNotification(PhoneNotification(
          id: _uuid.v4(),
          appId: 'system',
          title: 'Arquivo recuperado',
          body: rule.notificationText!,
        ));
      }
    }
  }

  void _recomputeScores() {
    final totalClues = c.clues.where((e) => !e.isRedHerring).length;
    final found = c.clues
        .where((e) => !e.isRedHerring && progress.discoveredClues.contains(e.id))
        .length;
    final cluePct = totalClues == 0 ? 0.0 : found / totalClues;

    final totalTl = c.timeline.length;
    final foundTl = c.timeline.where(isTimelineVisible).length;
    final tlPct = totalTl == 0 ? 0.0 : foundTl / totalTl;

    final critical = c.clues.where((e) => e.importance == ClueImportance.critical);
    final critFound =
        critical.where((e) => progress.discoveredClues.contains(e.id)).length;
    final evidence = critical.isEmpty ? 0.0 : critFound / critical.length;

    final contraPct = c.contradictions.isEmpty
        ? 0.0
        : progress.markedContradictions.length / c.contradictions.length;

    final score = (cluePct * 40) + (tlPct * 25) + (evidence * 25) + (contraPct * 10);

    progress = progress.copyWith(
      clueCompletion: cluePct,
      timelineCompletion: tlPct,
      evidenceQuality: evidence,
      investigationScore: score,
    );
  }

  void setReduceMotion(bool v) {
    reduceMotion = v;
    notifyListeners();
  }

  void setHaptics(bool v) {
    hapticsEnabled = v;
    notifyListeners();
  }

  void setFontScale(double v) {
    fontScale = v;
    notifyListeners();
  }

  void startLiveLoop() {
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (progress.deviceUnlocked && progress.chosenEndingId == null) {
        progress = progress.copyWith(
          playSeconds: progress.playSeconds + 4,
        );
        _syncDyingBattery();
      }
      _checkLiveEvents(trigger: 'time');
      _checkLiveEvents(trigger: 'progress');
      notifyListeners();
    });
  }

  void stopLiveLoop() {
    _liveTimer?.cancel();
  }

  /// Contagem restante (uso interno / Quadro).
  String get remainingClockLabel {
    final s = progress.remainingSeconds;
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final r = (s % 60).toString().padLeft(2, '0');
    return '$m:$r';
  }

  /// Nível narrativo da bateria (cai ao longo dos 30 min).
  int get narrativeBatteryLevel => progress.batteryPercent;

  /// Dica contextual com base no que ainda falta descobrir.
  String? get suggestedNextHint {
    if (!progress.deviceUnlocked || caseData == null) return null;
    if (progress.chosenEndingId != null) return null;
    final d = progress.discoveredClues;
    bool miss(String id) => !d.contains(id);

    if (miss('CLUE_LAST_MSG') ||
        miss('CLUE_RAFAEL_WHERE') ||
        miss('CLUE_MSG_DELETED')) {
      return 'Abra o WhatsApp e leia as conversas recentes — especialmente Rafael e R.';
    }
    if (miss('CLUE_PARKING') || miss('CLUE_LOC_OFF') || miss('CLUE_LOC_RESTAURANT')) {
      return 'Confira Mapas e Ajustes → Localização. O aparelho foi achado no São Lucas.';
    }
    if (miss('CLUE_CALL_UNKNOWN') ||
        miss('CLU