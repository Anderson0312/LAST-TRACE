/// Modelos do Modo Cooperativo — DOIS CELULARES. DUAS PERSPECTIVAS. UMA VERDADE.
library;

enum CoopRole { playerA, playerB }

enum CrossClueKind {
  complementary,
  confirmation,
  contradiction,
  sequential,
  cryptographic,
  temporal,
  visual,
  emotional,
}

class CoopDeviceMeta {
  final CoopRole role;
  final String deviceCaseId;
  final String ownerName;
  final String ownerRelation;
  final String tagline;
  final String lockPin;
  final String lockHint;

  const CoopDeviceMeta({
    required this.role,
    required this.deviceCaseId,
    required this.ownerName,
    required this.ownerRelation,
    required this.tagline,
    required this.lockPin,
    required this.lockHint,
  });

  factory CoopDeviceMeta.fromJson(Map<String, dynamic> j, CoopRole role) =>
      CoopDeviceMeta(
        role: role,
        deviceCaseId: j['deviceCaseId'] as String,
        ownerName: j['ownerName'] as String,
        ownerRelation: j['ownerRelation'] as String? ?? '',
        tagline: j['tagline'] as String? ?? '',
        lockPin: j['lockPin'] as String? ?? '0000',
        lockHint: j['lockHint'] as String? ?? '',
      );
}

class CrossClueDef {
  final String id;
  final CrossClueKind kind;
  final String title;
  final String deduction;
  final List<String> requiresClueIds;
  final List<String> revealsClueIds;
  final List<String> unlockContentIds;
  final int scoreBonus;

  const CrossClueDef({
    required this.id,
    required this.kind,
    required this.title,
    required this.deduction,
    required this.requiresClueIds,
    this.revealsClueIds = const [],
    this.unlockContentIds = const [],
    this.scoreBonus = 8,
  });

  factory CrossClueDef.fromJson(Map<String, dynamic> j) => CrossClueDef(
        id: j['id'] as String,
        kind: CrossClueKind.values.firstWhere(
          (e) => e.name == (j['kind'] as String? ?? 'complementary'),
          orElse: () => CrossClueKind.complementary,
        ),
        title: j['title'] as String,
        deduction: j['deduction'] as String,
        requiresClueIds:
            (j['requiresClueIds'] as List?)?.cast<String>() ?? const [],
        revealsClueIds:
            (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
        unlockContentIds:
            (j['unlockContentIds'] as List?)?.cast<String>() ?? const [],
        scoreBonus: (j['scoreBonus'] as num?)?.toInt() ?? 8,
      );
}

class CoopCaseMeta {
  final String id;
  final String title;
  final String slogan;
  final CoopDeviceMeta deviceA;
  final CoopDeviceMeta deviceB;
  final List<CrossClueDef> crossClues;
  final List<String> consensusFields;

  const CoopCaseMeta({
    required this.id,
    required this.title,
    required this.slogan,
    required this.deviceA,
    required this.deviceB,
    required this.crossClues,
    this.consensusFields = const [
      'suspect',
      'motive',
      'place',
      'time',
      'method',
    ],
  });

  factory CoopCaseMeta.fromJson(Map<String, dynamic> j) => CoopCaseMeta(
        id: j['id'] as String,
        title: j['title'] as String,
        slogan: j['slogan'] as String? ??
            'Dois celulares. Duas perspectivas. Uma verdade.',
        deviceA: CoopDeviceMeta.fromJson(
          Map<String, dynamic>.from(j['deviceA'] as Map),
          CoopRole.playerA,
        ),
        deviceB: CoopDeviceMeta.fromJson(
          Map<String, dynamic>.from(j['deviceB'] as Map),
          CoopRole.playerB,
        ),
        crossClues: ((j['crossClues'] as List?) ?? const [])
            .map((e) => CrossClueDef.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        consensusFields:
            (j['consensusFields'] as List?)?.cast<String>() ??
                const ['suspect', 'motive', 'place', 'time', 'method'],
      );

  CoopDeviceMeta deviceFor(CoopRole role) =>
      role == CoopRole.playerA ? deviceA : deviceB;
}

class SharedEvidenceItem {
  final String id;
  final String clueId;
  final CoopRole sharedBy;
  final String title;
  final String summary;
  final DateTime sharedAt;

  SharedEvidenceItem({
    required this.id,
    required this.clueId,
    required this.sharedBy,
    required this.title,
    required this.summary,
    DateTime? sharedAt,
  }) : sharedAt = sharedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'clueId': clueId,
        'sharedBy': sharedBy.name,
        'title': title,
        'summary': summary,
        'sharedAt': sharedAt.toIso8601String(),
      };

  factory SharedEvidenceItem.fromJson(Map<String, dynamic> j) =>
      SharedEvidenceItem(
        id: j['id'] as String,
        clueId: j['clueId'] as String,
        sharedBy: CoopRole.values.firstWhere(
          (e) => e.name == j['sharedBy'],
          orElse: () => CoopRole.playerA,
        ),
        title: j['title'] as String? ?? j['clueId'] as String,
        summary: j['summary'] as String? ?? '',
        sharedAt: j['sharedAt'] != null
            ? DateTime.parse(j['sharedAt'] as String)
            : DateTime.now(),
      );
}

class SharedLink {
  final String id;
  final String fromClueId;
  final String toClueId;
  final String? label;
  final CoopRole createdBy;

  SharedLink({
    required this.id,
    required this.fromClueId,
    required this.toClueId,
    this.label,
    required this.createdBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromClueId': fromClueId,
        'toClueId': toClueId,
        'label': label,
        'createdBy': createdBy.name,
      };

  factory SharedLink.fromJson(Map<String, dynamic> j) => SharedLink(
        id: j['id'] as String,
        fromClueId: j['fromClueId'] as String,
        toClueId: j['toClueId'] as String,
        label: j['label'] as String?,
        createdBy: CoopRole.values.firstWhere(
          (e) => e.name == j['createdBy'],
          orElse: () => CoopRole.playerA,
        ),
      );
}

class AccusationDraft {
  final CoopRole role;
  final String? suspectId;
  final String? motive;
  final String? place;
  final String? time;
  final String? method;
  final int confidence;
  final bool locked;

  const AccusationDraft({
    required this.role,
    this.suspectId,
    this.motive,
    this.place,
    this.time,
    this.method,
    this.confidence = 50,
    this.locked = false,
  });

  AccusationDraft copyWith({
    String? suspectId,
    String? motive,
    String? place,
    String? time,
    String? method,
    int? confidence,
    bool? locked,
  }) =>
      AccusationDraft(
        role: role,
        suspectId: suspectId ?? this.suspectId,
        motive: motive ?? this.motive,
        place: place ?? this.place,
        time: time ?? this.time,
        method: method ?? this.method,
        confidence: confidence ?? this.confidence,
        locked: locked ?? this.locked,
      );

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'suspectId': suspectId,
        'motive': motive,
        'place': place,
        'time': time,
        'method': method,
        'confidence': confidence,
        'locked': locked,
      };

  factory AccusationDraft.fromJson(Map<String, dynamic> j) => AccusationDraft(
        role: CoopRole.values.firstWhere(
          (e) => e.name == j['role'],
          orElse: () => CoopRole.playerA,
        ),
        suspectId: j['suspectId'] as String?,
        motive: j['motive'] as String?,
        place: j['place'] as String?,
        time: j['time'] as String?,
        method: j['method'] as String?,
        confidence: (j['confidence'] as num?)?.toInt() ?? 50,
        locked: j['locked'] as bool? ?? false,
      );
}

class CoopRoomState {
  final String roomCode;
  final String caseId;
  final bool started;
  final bool playerAReady;
  final bool playerBReady;
  final List<SharedEvidenceItem> sharedEvidence;
  final List<SharedLink> sharedLinks;
  final Set<String> resolvedCrossClues;
  final AccusationDraft? draftA;
  final AccusationDraft? draftB;
  final String? chosenEndingId;
  final int revision;

  CoopRoomState({
    required this.roomCode,
    required this.caseId,
    this.started = false,
    this.playerAReady = false,
    this.playerBReady = false,
    List<SharedEvidenceItem>? sharedEvidence,
    List<SharedLink>? sharedLinks,
    Set<String>? resolvedCrossClues,
    this.draftA,
    this.draftB,
    this.chosenEndingId,
    this.revision = 0,
  })  : sharedEvidence = sharedEvidence ?? [],
        sharedLinks = sharedLinks ?? [],
        resolvedCrossClues = resolvedCrossClues ?? {};

  bool get bothReady => playerAReady && playerBReady;

  bool get consensusReady {
    final a = draftA;
    final b = draftB;
    if (a == null || b == null) return false;
    if (!a.locked || !b.locked) return false;
    return a.suspectId != null &&
        a.suspectId == b.suspectId &&
        a.motive != null &&
        a.motive == b.motive &&
        a.place != null &&
        a.place == b.place;
  }

  CoopRoomState copyWith({
    bool? started,
    bool? playerAReady,
    bool? playerBReady,
    List<SharedEvidenceItem>? sharedEvidence,
    List<SharedLink>? sharedLinks,
    Set<String>? resolvedCrossClues,
    AccusationDraft? draftA,
    AccusationDraft? draftB,
    String? chosenEndingId,
    int? revision,
    bool clearEnding = false,
  }) =>
      CoopRoomState(
        roomCode: roomCode,
        caseId: caseId,
        started: started ?? this.started,
        playerAReady: playerAReady ?? this.playerAReady,
        playerBReady: playerBReady ?? this.playerBReady,
        sharedEvidence: sharedEvidence ?? this.sharedEvidence,
        sharedLinks: sharedLinks ?? this.sharedLinks,
        resolvedCrossClues: resolvedCrossClues ?? this.resolvedCrossClues,
        draftA: draftA ?? this.draftA,
        draftB: draftB ?? this.draftB,
        chosenEndingId:
            clearEnding ? null : (chosenEndingId ?? this.chosenEndingId),
        revision: revision ?? this.revision,
      );

  Map<String, dynamic> toJson() => {
        'roomCode': roomCode,
        'caseId': caseId,
        'started': started,
        'playerAReady': playerAReady,
        'playerBReady': playerBReady,
        'sharedEvidence': sharedEvidence.map((e) => e.toJson()).toList(),
        'sharedLinks': sharedLinks.map((e) => e.toJson()).toList(),
        'resolvedCrossClues': resolvedCrossClues.toList(),
        'draftA': draftA?.toJson(),
        'draftB': draftB?.toJson(),
        'chosenEndingId': chosenEndingId,
        'revision': revision,
      };

  factory CoopRoomState.fromJson(Map<String, dynamic> j) => CoopRoomState(
        roomCode: j['roomCode'] as String,
        caseId: j['caseId'] as String? ?? 'case_001_coop',
        started: j['started'] as bool? ?? false,
        playerAReady: j['playerAReady'] as bool? ?? false,
        playerBReady: j['playerBReady'] as bool? ?? false,
        sharedEvidence: ((j['sharedEvidence'] as List?) ?? const [])
            .map((e) =>
                SharedEvidenceItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        sharedLinks: ((j['sharedLinks'] as List?) ?? const [])
            .map((e) => SharedLink.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        resolvedCrossClues: {
          ...((j['resolvedCrossClues'] as List?) ?? const []).cast<String>()
        },
        draftA: j['draftA'] != null
            ? AccusationDraft.fromJson(Map<String, dynamic>.from(j['draftA']))
            : null,
        draftB: j['draftB'] != null
            ? AccusationDraft.fromJson(Map<String, dynamic>.from(j['draftB']))
            : null,
        chosenEndingId: j['chosenEndingId'] as String?,
        revision: (j['revision'] as num?)?.toInt() ?? 0,
      );
}

class CoopEnvelope {
  final String type;
  final Map<String, dynamic> payload;

  const CoopEnvelope(this.type, this.payload);

  Map<String, dynamic> toJson() => {'type': type, 'payload': payload};

  factory CoopEnvelope.fromJson(Map<String, dynamic> j) => CoopEnvelope(
        j['type'] as String,
        Map<String, dynamic>.from(j['payload'] as Map? ?? {}),
      );
}
