import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/models.dart';

class CaseRepository {
  Future<GameCase> loadCase(String caseId) async {
    final path = 'assets/cases/$caseId/case.json';
    final raw = await rootBundle.loadString(path);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return GameCase.fromJson(json);
  }

  Future<List<CaseMeta>> listCases() async {
    // Escalável: no futuro, manifesto JSON. Por ora, caso 01.
    return const [
      CaseMeta(
        id: 'case_001',
        title: 'A Última Mensagem',
        free: true,
        estimatedMinutes: 90,
      ),
    ];
  }
}

class CaseMeta {
  final String id;
  final String title;
  final bool free;
  final int estimatedMinutes;

  const CaseMeta({
    required this.id,
    required this.title,
    required this.free,
    required this.estimatedMinutes,
  });
}

class SaveService {
  static const _prefix = 'ua_save_';

  Future<void> save(InvestigationProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_prefix${progress.caseId}',
      jsonEncode(progress.toJson()),
    );
  }

  Future<InvestigationProgress?> load(String caseId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$caseId');
    if (raw == null) return null;
    return InvestigationProgress.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  Future<void> clear(String caseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$caseId');
  }
}
