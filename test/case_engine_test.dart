import 'package:flutter_test/flutter_test.dart';
import 'package:ultimo_acesso/domain/models/models.dart';
import 'package:ultimo_acesso/domain/engines/game_engine.dart';
import 'dart:convert';
import 'dart:io';

void main() {
  test('Case 01 JSON parses and loads into engine', () async {
    final file = File('assets/cases/case_001/case.json');
    expect(file.existsSync(), true);
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final gameCase = GameCase.fromJson(json);
    expect(gameCase.id, 'case_001');
    expect(gameCase.clues.length, greaterThanOrEqualTo(30));
    expect(gameCase.conversations.length, greaterThanOrEqualTo(15));
    expect(gameCase.endings.length, 5);
    expect(gameCase.lockPin, '0912');

    final engine = GameEngine();
    engine.loadCase(gameCase);
    expect(engine.tryPin('0000'), false);
    expect(engine.tryPin('0912'), true);
    expect(engine.progress.deviceUnlocked, true);

    engine.discoverClue('CLUE_NOTE_R');
    engine.discoverClue('CLUE_EMAIL_RITA');
    expect(engine.progress.discoveredClues.contains('CLUE_R_IDENTITY'), true);

    final ending = engine.evaluateEnding(accusedId: 'char_bruno');
    expect(ending, isNotNull);
  });
}
