import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultimo_acesso/domain/engines/game_engine.dart';
import 'package:ultimo_acesso/domain/models/models.dart';

void main() {
  test('Board connections infer relations and persist layouts', () async {
    final file = File('assets/cases/case_001/case.json');
    expect(file.existsSync(), true);
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final data = GameCase.fromJson(json);
    final engine = GameEngine()..loadCase(data);

    for (final clue in data.clues.take(8)) {
      engine.discoverClue(clue.id);
    }

    final a = data.clues.first.id;
    final b = data.clues[1].id;
    final result = engine.addBoardConnection(a, b);
    expect(result.connection.fromId, a);
    expect(result.connection.toId, b);
    expect(result.connection.label, isNotNull);
    expect(engine.progress.boardConnections, isNotEmpty);

    engine.moveBoardNode(a, 320, 410);
    expect(engine.progress.boardLayouts[a]?.x, 320);
    expect(engine.progress.boardLayouts[a]?.y, 410);

    engine.addInvestigatorNote('Rafael mentiu sobre o horário.', NoteTag.theory);
    expect(engine.progress.investigatorNotes, isNotEmpty);
    expect(engine.progress.investigatorNotes.first.boardX, isNotNull);

    engine.addBoardTheory(
      title: 'Teoria #1',
      body: 'Encontro às 23:30 e mensagens apagadas.',
      evidenceIds: [a, b],
    );
    expect(engine.progress.boardTheories.length, 1);

    final snap = engine.boardProgressSnapshot();
    expect(snap.foundClues, greaterThan(0));
    expect(snap.totalClues, greaterThan(0));

    final restored = InvestigationProgress.fromJson(engine.progress.toJson());
    expect(restored.boardConnections.length, 1);
    expect(restored.boardLayouts.containsKey(a), isTrue);
    expect(restored.boardTheories.length, 1);
    expect(restored.investigatorNotes.first.text, contains('Rafael'));
  });
}
