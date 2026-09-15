import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/coop/coop_models.dart';
import '../../domain/models/models.dart';
import '../repositories/case_repository.dart';

class CoopCaseLoader {
  final CaseRepository cases;

  CoopCaseLoader(this.cases);

  Future<CoopCaseMeta> loadMeta(String coopId) async {
    final raw =
        await rootBundle.loadString('assets/cases/$coopId/meta.json');
    return CoopCaseMeta.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<GameCase> loadDevice(CoopCaseMeta meta, CoopRole role) async {
    final device = meta.deviceFor(role);
    if (device.deviceCaseId == 'case_001') {
      return cases.loadCase('case_001');
    }
    if (device.deviceCaseId == 'case_001_device_b') {
      final raw = await rootBundle
          .loadString('assets/cases/case_001_coop/device_b.json');
      return GameCase.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    return cases.loadCase(device.deviceCaseId);
  }
}
