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
     