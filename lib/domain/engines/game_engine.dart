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
    final evidence = critical.isEmpty ? 0.0 : critFound / critical.