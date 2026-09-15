import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultimo_acesso/domain/coop/coop_models.dart';
import 'package:ultimo_acesso/domain/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Coop meta and device B parse', () async {
    final metaRaw =
        await rootBundle.loadString('assets/cases/case_001_coop/meta.json');
    final meta = CoopCaseMeta.fromJson(jsonDecode(metaRaw) as Map<String, dynamic>);
    expect(meta.crossClues.length, greaterThanOrEqualTo(5));
    expect(meta.deviceA.deviceCaseId, 'case_001');
    expect(meta.deviceB.lockPin, '2308');

    final bRaw = await rootBundle
        .loadString('assets/cases/case_001_coop/device_b.json');
    final b = GameCase.fromJson(jsonDecode(bRaw) as Map<String, dynamic>);
    expect(b.id, 'case_001_device_b');
    expect(b.conversations, isNotEmpty);
    expect(b.clues.any((c) => c.id == 'CLUE_B_BRUNO_ORDER'), isTrue);
  });
}
