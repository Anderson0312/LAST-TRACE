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

  void addBoardConnection(String fromId, String toId, {String? label}) {
    progress.boardConnections.add(BoardConnection(
      id: _uuid.v4(),
      fromId: fromId,
      toId: toId,
      label: label,
    ));
    notifyListeners();
  }

  void removeBoardConnection(String id) {
    progress.boardConnections.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addInvestigatorNote(String text, NoteTag tag) {
    progress.investigatorNotes.insert(
      0,
      InvestigatorNote(id: _uuid.v4(), text: text, tag: tag),
    );
    notifyListeners();
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
        miss('CLUE_CALL_DANIEL') ||
        miss('CLUE_VOICEMAIL')) {
      return 'Abra Chamadas: há uma linha desconhecida e um correio de voz.';
    }
    if (miss('CLUE_NOTE_IF') || miss('CLUE_NOTE_R') || miss('CLUE_R_THREAD')) {
      return 'Notas e Contatos: procure "R." e a anotação "se alguma coisa acontecer".';
    }
    if (miss('CLUE_EMAIL_DANIEL') ||
        miss('CLUE_FILE_AURORA') ||
        miss('CLUE_CONTRACT_AURORA')) {
      return 'Mail e Arquivos: procure Aurora, contratos e e-mails do Daniel.';
    }
    if (miss('CLUE_PHOTO_PLATE') ||
        miss('CLUE_PHOTO_REFLECTION') ||
        miss('CLUE_META_MISMATCH')) {
      return 'Galeria: toque nas fotos e explore os pontos quentes (placa, reflexo, metadados).';
    }
    if (miss('CLUE_REMOTE_ACCESS') || miss('CLUE_FILE_DAT')) {
      return 'Ajustes / Arquivos: arquivo_00017.dat e sinais de acesso remoto.';
    }
    if (progress.investigationScore < 55) {
      return 'Monte o Quadro: ligue pistas, marque contradições e depois vá em Conclusão.';
    }
    return 'Você já tem material. Abra Quadro → Conclusão e escolha quem acusar.';
  }

  /// Drena a bateria conforme o tempo de jogo — sem cronômetro na Island.
  void _syncDyingBattery() {
    if (!progress.deviceUnlocked || progress.chosenEndingId != null) return;

    final start = (caseData?.osState['battery'] as int?) ?? 87;
    final t = progress.timePressure.clamp(0.0, 1.0);
    // Queda lenta no começo, acelerada no final (celular “morrendo”).
    final drain = math.pow(t, 1.35).toDouble();
    var level = (start * (1.0 - drain)).round();
    if (progress.remoteAccessDetected) {
      level -= 8;
    }
    if (t >= 0.92) {
      level = math.min(level, 4);
    } else if (t >= 0.78) {
      le