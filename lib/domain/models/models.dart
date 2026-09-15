/// Modelos de domínio — ÚLTIMO ACESSO
/// Conteúdo narrativo fica em JSON; estes tipos espelham o schema do caso.
library;

class GameCase {
  final String id;
  final String title;
  final String subtitle;
  final String synopsis;
  final String victimId;
  final DateTime deviceFoundAt;
  final String lockPin;
  final String lockHint;
  final List<Character> characters;
  final List<Clue> clues;
  final List<Conversation> conversations;
  final List<PhotoItem> photos;
  final List<CallLog> calls;
  final List<EmailItem> emails;
  final List<NoteItem> notes;
  final List<FileItem> files;
  final List<MapLocation> locations;
  final List<BrowserEntry> browserHistory;
  final List<TimelineEvent> timeline;
  final List<Ending> endings;
  final List<UnlockRule> unlockRules;
  final List<LiveEvent> liveEvents;
  final List<Contradiction> contradictions;
  final List<Puzzle> puzzles;
  final List<ContactItem> contacts;
  final List<CalendarEvent> calendarEvents;
  final List<NotificationSeed> initialNotifications;
  final Map<String, dynamic> settingsHints;
  final Map<String, dynamic> osState;

  const GameCase({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.synopsis,
    required this.victimId,
    required this.deviceFoundAt,
    required this.lockPin,
    required this.lockHint,
    required this.characters,
    required this.clues,
    required this.conversations,
    required this.photos,
    required this.calls,
    required this.emails,
    required this.notes,
    required this.files,
    required this.locations,
    required this.browserHistory,
    required this.timeline,
    required this.endings,
    required this.unlockRules,
    required this.liveEvents,
    required this.contradictions,
    required this.puzzles,
    required this.contacts,
    required this.calendarEvents,
    required this.initialNotifications,
    required this.settingsHints,
    required this.osState,
  });

  factory GameCase.fromJson(Map<String, dynamic> j) => GameCase(
        id: j['id'] as String,
        title: j['title'] as String,
        subtitle: j['subtitle'] as String? ?? '',
        synopsis: j['synopsis'] as String? ?? '',
        victimId: j['victimId'] as String,
        deviceFoundAt: DateTime.parse(j['deviceFoundAt'] as String),
        lockPin: j['lockPin'] as String,
        lockHint: j['lockHint'] as String? ?? '',
        characters: _list(j['characters'], Character.fromJson),
        clues: _list(j['clues'], Clue.fromJson),
        conversations: _list(j['conversations'], Conversation.fromJson),
        photos: _list(j['photos'], PhotoItem.fromJson),
        calls: _list(j['calls'], CallLog.fromJson),
        emails: _list(j['emails'], EmailItem.fromJson),
        notes: _list(j['notes'], NoteItem.fromJson),
        files: _list(j['files'], FileItem.fromJson),
        locations: _list(j['locations'], MapLocation.fromJson),
        browserHistory: _list(j['browserHistory'], BrowserEntry.fromJson),
        timeline: _list(j['timeline'], TimelineEvent.fromJson),
        endings: _list(j['endings'], Ending.fromJson),
        unlockRules: _list(j['unlockRules'], UnlockRule.fromJson),
        liveEvents: _list(j['liveEvents'], LiveEvent.fromJson),
        contradictions: _list(j['contradictions'], Contradiction.fromJson),
        puzzles: _list(j['puzzles'], Puzzle.fromJson),
        contacts: _list(j['contacts'], ContactItem.fromJson),
        calendarEvents: _list(j['calendarEvents'], CalendarEvent.fromJson),
        initialNotifications:
            _list(j['initialNotifications'], NotificationSeed.fromJson),
        settingsHints: Map<String, dynamic>.from(j['settingsHints'] as Map? ?? {}),
        osState: Map<String, dynamic>.from(j['osState'] as Map? ?? {}),
      );
}

List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) f) {
  if (raw is! List) return [];
  return raw.map((e) => f(Map<String, dynamic>.from(e as Map))).toList();
}

enum CharacterRole { victim, suspect, witness, mysterious, contact }

class Character {
  final String id;
  final String name;
  final int? age;
  final String? photoAsset;
  final String? profession;
  final String relationToVictim;
  final String? phone;
  final String? email;
  final String? address;
  final String personality;
  final List<String> secrets;
  final String? alibi;
  final List<String> contradictions;
  final CharacterRole role;
  final int initialSuspicion;

  const Character({
    required this.id,
    required this.name,
    this.age,
    this.photoAsset,
    this.profession,
    required this.relationToVictim,
    this.phone,
    this.email,
    this.address,
    required this.personality,
    this.secrets = const [],
    this.alibi,
    this.contradictions = const [],
    required this.role,
    this.initialSuspicion = 0,
  });

  factory Character.fromJson(Map<String, dynamic> j) => Character(
        id: j['id'] as String,
        name: j['name'] as String,
        age: j['age'] as int?,
        photoAsset: j['photoAsset'] as String?,
        profession: j['profession'] as String?,
        relationToVictim: j['relationToVictim'] as String? ?? '',
        phone: j['phone'] as String?,
        email: j['email'] as String?,
        address: j['address'] as String?,
        personality: j['personality'] as String? ?? '',
        secrets: (j['secrets'] as List?)?.cast<String>() ?? const [],
        alibi: j['alibi'] as String?,
        contradictions: (j['contradictions'] as List?)?.cast<String>() ?? const [],
        role: CharacterRole.values.firstWhere(
          (e) => e.name == j['role'],
          orElse: () => CharacterRole.contact,
        ),
        initialSuspicion: j['initialSuspicion'] as int? ?? 0,
      );
}

enum ClueType {
  message,
  photo,
  metadata,
  location,
  call,
  email,
  note,
  file,
  browser,
  audio,
  environmental,
  contradiction,
  password,
  timeline,
  system,
}

enum ClueImportance { low, medium, high, critical }

enum DiscoveryState { hidden, hinted, discovered, analyzed }

class Clue {
  final String id;
  final String name;
  final ClueType type;
  final String description;
  final String content;
  final String origin;
  final ClueImportance importance;
  final List<String> relatedClueIds;
  final List<String> relatedCharacterIds;
  final List<String> unlockRequirements;
  final bool isRedHerring;
  final DiscoveryState initialState;

  const Clue({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.content,
    required this.origin,
    required this.importance,
    this.relatedClueIds = const [],
    this.relatedCharacterIds = const [],
    this.unlockRequirements = const [],
    this.isRedHerring = false,
    this.initialState = DiscoveryState.hidden,
  });

  factory Clue.fromJson(Map<String, dynamic> j) => Clue(
        id: j['id'] as String,
        name: j['name'] as String,
        type: ClueType.values.firstWhere(
          (e) => e.name == j['type'],
          orElse: () => ClueType.message,
        ),
        description: j['description'] as String? ?? '',
        content: j['content'] as String? ?? '',
        origin: j['origin'] as String? ?? '',
        importance: ClueImportance.values.firstWhere(
          (e) => e.name == j['importance'],
          orElse: () => ClueImportance.medium,
        ),
        relatedClueIds: (j['relatedClueIds'] as List?)?.cast<String>() ?? const [],
        relatedCharacterIds:
            (j['relatedCharacterIds'] as List?)?.cast<String>() ?? const [],
        unlockRequirements:
            (j['unlockRequirements'] as List?)?.cast<String>() ?? const [],
        isRedHerring: j['isRedHerring'] as bool? ?? false,
        initialState: DiscoveryState.values.firstWhere(
          (e) => e.name == j['initialState'],
          orElse: () => DiscoveryState.hidden,
        ),
      );
}

enum MessageKind {
  text,
  image,
  video,
  voice,
  document,
  location,
  deleted,
  edited,
  system,
}

class ChatMessage {
  final String id;
  final String senderId; // 'self' = Marina
  final MessageKind kind;
  final String body;
  final DateTime timestamp;
  final bool isDeleted;
  final String? deletedPreview;
  final bool isEdited;
  final String? replyToId;
  final String? attachmentId;
  final List<String> revealsClueIds;
  final bool locked;
  final List<String> unlockWithClueIds;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.kind,
    required this.body,
    required this.timestamp,
    this.isDeleted = false,
    this.deletedPreview,
    this.isEdited = false,
    this.replyToId,
    this.attachmentId,
    this.revealsClueIds = const [],
    this.locked = false,
    this.unlockWithClueIds = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        senderId: j['senderId'] as String,
        kind: MessageKind.values.firstWhere(
          (e) => e.name == j['kind'],
          orElse: () => MessageKind.text,
        ),
        body: j['body'] as String? ?? '',
        timestamp: DateTime.parse(j['timestamp'] as String),
        isDeleted: j['isDeleted'] as bool? ?? false,
        deletedPreview: j['deletedPreview'] as String?,
        isEdited: j['isEdited'] as bool? ?? false,
        replyToId: j['replyToId'] as String?,
        attachmentId: j['attachmentId'] as String?,
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
        locked: j['locked'] as bool? ?? false,
        unlockWithClueIds:
            (j['unlockWithClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class Conversation {
  final String id;
  final String contactId;
  final String displayName;
  final bool archived;
  final bool blocked;
  final bool unread;
  final List<ChatMessage> messages;
  final List<String> revealsClueIds;

  const Conversation({
    required this.id,
    required this.contactId,
    required this.displayName,
    this.archived = false,
    this.blocked = false,
    this.unread = false,
    required this.messages,
    this.revealsClueIds = const [],
  });

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
        id: j['id'] as String,
        contactId: j['contactId'] as String,
        displayName: j['displayName'] as String,
        archived: j['archived'] as bool? ?? false,
        blocked: j['blocked'] as bool? ?? false,
        unread: j['unread'] as bool? ?? false,
        messages: _list(j['messages'], ChatMessage.fromJson),
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class PhotoHotspot {
  final String id;
  final double x;
  final double y;
  final double w;
  final double h;
  final String label;
  final List<String> revealsClueIds;

  const PhotoHotspot({
    required this.id,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.label,
    this.revealsClueIds = const [],
  });

  factory PhotoHotspot.fromJson(Map<String, dynamic> j) => PhotoHotspot(
        id: j['id'] as String,
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
        w: (j['w'] as num).toDouble(),
        h: (j['h'] as num).toDouble(),
        label: j['label'] as String? ?? '',
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class PhotoItem {
  final String id;
  final String title;
  final String caption;
  final String visualDescription;
  final DateTime takenAt;
  final DateTime? metadataTakenAt;
  final String? locationName;
  final double? lat;
  final double? lng;
  final String? deviceName;
  final bool deleted;
  final bool corrupted;
  final bool isScreenshot;
  final bool isVideo;
  final List<PhotoHotspot> hotspots;
  final List<String> revealsClueIds;
  final String colorSeed; // for generated placeholder art

  const PhotoItem({
    required this.id,
    required this.title,
    required this.caption,
    required this.visualDescription,
    required this.takenAt,
    this.metadataTakenAt,
    this.locationName,
    this.lat,
    this.lng,
    this.deviceName,
    this.deleted = false,
    this.corrupted = false,
    this.isScreenshot = false,
    this.isVideo = false,
    this.hotspots = const [],
    this.revealsClueIds = const [],
    this.colorSeed = 'A0',
  });

  factory PhotoItem.fromJson(Map<String, dynamic> j) => PhotoItem(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        caption: j['caption'] as String? ?? '',
        visualDescription: j['visualDescription'] as String? ?? '',
        takenAt: DateTime.parse(j['takenAt'] as String),
        metadataTakenAt: j['metadataTakenAt'] != null
            ? DateTime.parse(j['metadataTakenAt'] as String)
            : null,
        locationName: j['locationName'] as String?,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
        deviceName: j['deviceName'] as String?,
        deleted: j['deleted'] as bool? ?? false,
        corrupted: j['corrupted'] as bool? ?? false,
        isScreenshot: j['isScreenshot'] as bool? ?? false,
        isVideo: j['isVideo'] as bool? ?? false,
        hotspots: _list(j['hotspots'], PhotoHotspot.fromJson),
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
        colorSeed: j['colorSeed'] as String? ?? 'A0',
      );
}

enum CallType { incoming, outgoing, missed }

class CallLog {
  final String id;
  final String contactId;
  final String displayName;
  final String? number;
  final CallType type;
  final DateTime timestamp;
  final int durationSeconds;
  final List<String> revealsClueIds;
  final bool unknown;

  const CallLog({
    required this.id,
    required this.contactId,
    required this.displayName,
    this.number,
    required this.type,
    required this.timestamp,
    this.durationSeconds = 0,
    this.revealsClueIds = const [],
    this.unknown = false,
  });

  factory CallLog.fromJson(Map<String, dynamic> j) => CallLog(
        id: j['id'] as String,
        contactId: j['contactId'] as String? ?? '',
        displayName: j['displayName'] as String? ?? j['contactId'] as String? ?? '',
        number: j['number'] as String?,
        type: CallType.values.firstWhere(
          (e) => e.name == j['type'],
          orElse: () => CallType.incoming,
        ),
        timestamp: DateTime.parse(j['timestamp'] as String),
        durationSeconds: (j['durationSeconds'] as num?)?.toInt() ?? 0,
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
        unknown: j['unknown'] as bool? ?? false,
      );
}

class EmailItem {
  final String id;
  final String from;
  final List<String> to;
  final String subject;
  final String body;
  final DateTime timestamp;
  final bool isDraft;
  final bool isTrash;
  final bool isSpam;
  final List<String> revealsClueIds;

  const EmailItem({
    required this.id,
    required this.from,
    this.to = const [],
    required this.subject,
    required this.body,
    required this.timestamp,
    this.isDraft = false,
    this.isTrash = false,
    this.isSpam = false,
    this.revealsClueIds = const [],
  });

  factory EmailItem.fromJson(Map<String, dynamic> j) => EmailItem(
        id: j['id'] as String,
        from: j['from'] as String? ?? '',
        to: (j['to'] as List?)?.cast<String>() ?? const [],
        subject: j['subject'] as String? ?? '',
        body: j['body'] as String? ?? '',
        timestamp: DateTime.parse(j['timestamp'] as String),
        isDraft: j['isDraft'] as bool? ?? false,
        isTrash: j['isTrash'] as bool? ?? false,
        isSpam: j['isSpam'] as bool? ?? false,
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class NoteItem {
  final String id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool locked;
  final List<String> revealsClueIds;

  const NoteItem({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    this.locked = false,
    this.revealsClueIds = const [],
  });

  factory NoteItem.fromJson(Map<String, dynamic> j) => NoteItem(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        locked: j['locked'] as bool? ?? false,
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class FileItem {
  final String id;
  final String name;
  final String path;
  final String type;
  final DateTime modifiedAt;
  final bool hidden;
  final bool passwordProtected;
  final String? password;
  final bool corrupted;
  final String? content;
  final String? sizeLabel;
  final List<String> revealsClueIds;

  const FileItem({
    required this.id,
    required this.name,
    this.path = '',
    this.type = 'file',
    required this.modifiedAt,
    this.hidden = false,
    this.passwordProtected = false,
    this.password,
    this.corrupted = false,
    this.content,
    this.sizeLabel,
    this.revealsClueIds = const [],
  });

  factory FileItem.fromJson(Map<String, dynamic> j) => FileItem(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        path: j['path'] as String? ?? '',
        type: j['type'] as String? ?? 'file',
        modifiedAt: j['modifiedAt'] != null
            ? DateTime.parse(j['modifiedAt'] as String)
            : DateTime.fromMillisecondsSinceEpoch(0),
        hidden: j['hidden'] as bool? ?? false,
        passwordProtected:
            j['passwordProtected'] as bool? ?? j['locked'] as bool? ?? false,
        password: j['password'] as String?,
        corrupted: j['corrupted'] as bool? ?? false,
        content: j['content'] as String?,
        sizeLabel: j['sizeLabel'] as String?,
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class MapLocation {
  final String id;
  final String name;
  final String kind;
  final DateTime? visitedAt;
  final String? note;
  final double? lat;
  final double? lng;
  final List<String> revealsClueIds;

  const MapLocation({
    required this.id,
    required this.name,
    this.kind = 'history',
    this.visitedAt,
    this.note,
    this.lat,
    this.lng,
    this.revealsClueIds = const [],
  });

  factory MapLocation.fromJson(Map<String, dynamic> j) => MapLocation(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        kind: j['kind'] as String? ?? 'history',
        visitedAt: j['visitedAt'] != null
            ? DateTime.parse(j['visitedAt'] as String)
            : null,
        note: j['note'] as String?,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class BrowserEntry {
  final String id;
  final String title;
  final String url;
  final DateTime visitedAt;
  final String? snippet;
  final List<String> revealsClueIds;

  const BrowserEntry({
    required this.id,
    required this.title,
    required this.url,
    required this.visitedAt,
    this.snippet,
    this.revealsClueIds = const [],
  });

  factory BrowserEntry.fromJson(Map<String, dynamic> j) => BrowserEntry(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        url: j['url'] as String? ?? '',
        visitedAt: DateTime.parse(j['visitedAt'] as String),
        snippet: j['snippet'] as String?,
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class TimelineEvent {
  final String id;
  final DateTime timestamp;
  final String description;
  final String source;
  final double reliability;
  final bool initiallyVisible;
  final List<String> unlockWithClueIds;

  const TimelineEvent({
    required this.id,
    required this.timestamp,
    required this.description,
    this.source = '',
    this.reliability = 0.5,
    this.initiallyVisible = false,
    this.unlockWithClueIds = const [],
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> j) => TimelineEvent(
        id: j['id'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        description: j['description'] as String? ?? '',
        source: j['source'] as String? ?? '',
        reliability: (j['reliability'] as num?)?.toDouble() ?? 0.5,
        initiallyVisible: j['initiallyVisible'] as bool? ?? false,
        unlockWithClueIds:
            (j['unlockWithClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class Ending {
  final String id;
  final String code;
  final String title;
  final String summary;
  final String epilogue;
  final Map<String, dynamic> requirements;

  const Ending({
    required this.id,
    required this.code,
    required this.title,
    required this.summary,
    required this.epilogue,
    this.requirements = const {},
  });

  factory Ending.fromJson(Map<String, dynamic> j) => Ending(
        id: j['id'] as String,
        code: j['code'] as String? ?? '',
        title: j['title'] as String? ?? '',
        summary: j['summary'] as String? ?? '',
        epilogue: j['epilogue'] as String? ?? '',
        requirements: Map<String, dynamic>.from(j['requirements'] as Map? ?? {}),
      );
}

class UnlockRule {
  final String id;
  final List<String> requiredClueIds;
  final int minRequired;
  final List<String> unlockClueIds;
  final List<String> unlockTimelineIds;
  final List<String> unlockContentIds;
  final String? notificationText;

  const UnlockRule({
    required this.id,
    this.requiredClueIds = const [],
    this.minRequired = 0,
    this.unlockClueIds = const [],
    this.unlockTimelineIds = const [],
    this.unlockContentIds = const [],
    this.notificationText,
  });

  factory UnlockRule.fromJson(Map<String, dynamic> j) => UnlockRule(
        id: j['id'] as String,
        requiredClueIds:
            (j['requiredClueIds'] as List?)?.cast<String>() ?? const [],
        minRequired: (j['minRequired'] as num?)?.toInt() ?? 0,
        unlockClueIds: (j['unlockClueIds'] as List?)?.cast<String>() ?? const [],
        unlockTimelineIds:
            (j['unlockTimelineIds'] as List?)?.cast<String>() ?? const [],
        unlockContentIds:
            (j['unlockContentIds'] as List?)?.cast<String>() ?? const [],
        notificationText: j['notificationText'] as String?,
      );
}

class LiveEvent {
  final String id;
  final String trigger;
  final int delaySeconds;
  final Map<String, dynamic> condition;
  final String type;
  final Map<String, dynamic> payload;

  const LiveEvent({
    required this.id,
    required this.trigger,
    this.delaySeconds = 0,
    this.condition = const {},
    required this.type,
    this.payload = const {},
  });

  factory LiveEvent.fromJson(Map<String, dynamic> j) => LiveEvent(
        id: j['id'] as String,
        trigger: j['trigger'] as String? ?? 'time',
        delaySeconds: (j['delaySeconds'] as num?)?.toInt() ?? 0,
        condition: Map<String, dynamic>.from(j['condition'] as Map? ?? {}),
        type: j['type'] as String? ?? 'notification',
        payload: Map<String, dynamic>.from(j['payload'] as Map? ?? {}),
      );
}

class Contradiction {
  final String id;
  final String statement;
  final String? characterId;
  final List<String> evidenceClueIds;
  final String resolution;
  final List<String> revealsClueIds;

  const Contradiction({
    required this.id,
    required this.statement,
    this.characterId,
    this.evidenceClueIds = const [],
    this.resolution = '',
    this.revealsClueIds = const [],
  });

  factory Contradiction.fromJson(Map<String, dynamic> j) => Contradiction(
        id: j['id'] as String,
        statement: j['statement'] as String? ?? '',
        characterId: j['characterId'] as String?,
        evidenceClueIds:
            (j['evidenceClueIds'] as List?)?.cast<String>() ?? const [],
        resolution: j['resolution'] as String? ?? '',
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class Puzzle {
  final String id;
  final String answer;
  final List<String> alternateAnswers;
  final List<String> unlockOnSolve;
  final List<String> relatedClueIds;

  const Puzzle({
    required this.id,
    required this.answer,
    this.alternateAnswers = const [],
    this.unlockOnSolve = const [],
    this.relatedClueIds = const [],
  });

  factory Puzzle.fromJson(Map<String, dynamic> j) => Puzzle(
        id: j['id'] as String,
        answer: j['answer'] as String? ?? '',
        alternateAnswers:
            (j['alternateAnswers'] as List?)?.cast<String>() ?? const [],
        unlockOnSolve: (j['unlockOnSolve'] as List?)?.cast<String>() ?? const [],
        relatedClueIds:
            (j['relatedClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class ContactItem {
  final String id;
  final String name;
  final String? phone;
  final String? notes;
  final bool favorite;

  const ContactItem({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    this.favorite = false,
  });

  factory ContactItem.fromJson(Map<String, dynamic> j) => ContactItem(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String?,
        notes: j['notes'] as String?,
        favorite: j['favorite'] as bool? ?? false,
      );
}

class CalendarEvent {
  final String id;
  final String title;
  final DateTime start;
  final DateTime? end;
  final String? location;
  final String? notes;
  final List<String> revealsClueIds;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.start,
    this.end,
    this.location,
    this.notes,
    this.revealsClueIds = const [],
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> j) => CalendarEvent(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        start: DateTime.parse(j['start'] as String),
        end: j['end'] != null ? DateTime.parse(j['end'] as String) : null,
        location: j['location'] as String?,
        notes: j['notes'] as String?,
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class NotificationSeed {
  final String id;
  final String appId;
  final String title;
  final String body;
  final DateTime timestamp;
  final List<String> revealsClueIds;

  const NotificationSeed({
    required this.id,
    required this.appId,
    required this.title,
    required this.body,
    required this.timestamp,
    this.revealsClueIds = const [],
  });

  factory NotificationSeed.fromJson(Map<String, dynamic> j) => NotificationSeed(
        id: j['id'] as String,
        appId: j['appId'] as String? ?? 'system',
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        timestamp: j['timestamp'] != null
            ? DateTime.parse(j['timestamp'] as String)
            : DateTime.fromMillisecondsSinceEpoch(0),
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

enum NoteTag { suspect, evidence, theory, location, question, other }

class InvestigatorNote {
  final String id;
  final String text;
  final NoteTag tag;

  const InvestigatorNote({
    required this.id,
    required this.text,
    required this.tag,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'tag': tag.name,
      };

  factory InvestigatorNote.fromJson(Map<String, dynamic> j) => InvestigatorNote(
        id: j['id'] as String,
        text: j['text'] as String? ?? '',
        tag: NoteTag.values.firstWhere(
          (e) => e.name == j['tag'],
          orElse: () => NoteTag.other,
        ),
      );
}

class BoardConnection {
  final String id;
  final String fromId;
  final String toId;
  final String? label;

  const BoardConnection({
    required this.id,
    required this.fromId,
    required this.toId,
    this.label,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromId': fromId,
        'toId': toId,
        'label': label,
      };

  factory BoardConnection.fromJson(Map<String, dynamic> j) => BoardConnection(
        id: j['id'] as String,
        fromId: j['fromId'] as String,
        toId: j['toId'] as String,
        label: j['label'] as String?,
      );
}

class PhoneNotification {
  final String id;
  final String appId;
  final String title;
  final String body;
  final DateTime timestamp;
  final List<String> revealsClueIds;
  bool read;

  PhoneNotification({
    required this.id,
    required this.appId,
    required this.title,
    required this.body,
    DateTime? timestamp,
    this.revealsClueIds = const [],
    this.read = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

class InvestigationProgress {
  final String caseId;
  bool deviceUnlocked;
  final Set<String> discoveredClues;
  final Set<String> analyzedClues;
  final Set<String> openedConversations;
  final Set<String> openedMessages;
  final Set<String> viewedPhotos;
  final Set<String> unlockedContent;
  final Set<String> unlockedTimeline;
  final Set<String> solvedPuzzles;
  final Set<String> markedContradictions;
  final List<BoardConnection> boardConnections;
  final List<InvestigatorNote> investigatorNotes;
  final Map<String, dynamic> flags;
  final Map<String, int> suspectSuspicion;
  bool remoteAccessDetected;
  int batteryPercent;
  int playSeconds;
  int targetPlaySeconds;
  String? chosenEndingId;
  String? accusedCharacterId;
  final Set<String> unlockedEndings;
  final Set<String> firedLiveEvents;
  double clueCompletion;
  double timelineCompletion;
  double evidenceQuality;
  double investigationScore;

  InvestigationProgress({
    required this.caseId,
    this.deviceUnlocked = false,
    Set<String>? discoveredClues,
    Set<String>? analyzedClues,
    Set<String>? openedConversations,
    Set<String>? openedMessages,
    Set<String>? viewedPhotos,
    Set<String>? unlockedContent,
    Set<String>? unlockedTimeline,
    Set<String>? solvedPuzzles,
    Set<String>? markedContradictions,
    List<BoardConnection>? boardConnections,
    List<InvestigatorNote>? investigatorNotes,
    Map<String, dynamic>? flags,
    Map<String, int>? suspectSuspicion,
    this.remoteAccessDetected = false,
    this.batteryPercent = 87,
    this.playSeconds = 0,
    this.targetPlaySeconds = 1800,
    this.chosenEndingId,
    this.accusedCharacterId,
    Set<String>? unlockedEndings,
    Set<String>? firedLiveEvents,
    this.clueCompletion = 0,
    this.timelineCompletion = 0,
    this.evidenceQuality = 0,
    this.investigationScore = 0,
  })  : discoveredClues = discoveredClues ?? {},
        analyzedClues = analyzedClues ?? {},
        openedConversations = openedConversations ?? {},
        openedMessages = openedMessages ?? {},
        viewedPhotos = viewedPhotos ?? {},
        unlockedContent = unlockedContent ?? {},
        unlockedTimeline = unlockedTimeline ?? {},
        solvedPuzzles = solvedPuzzles ?? {},
        markedContradictions = markedContradictions ?? {},
        boardConnections = boardConnections ?? [],
        investigatorNotes = investigatorNotes ?? [],
        flags = flags ?? {},
        suspectSuspicion = suspectSuspicion ?? {},
        unlockedEndings = unlockedEndings ?? {},
        firedLiveEvents = firedLiveEvents ?? {};

  int get remainingSeconds =>
      (targetPlaySeconds - playSeconds).clamp(0, targetPlaySeconds);

  double get timePressure =>
      targetPlaySeconds <= 0 ? 0 : (playSeconds / targetPlaySeconds).clamp(0.0, 1.0);

  InvestigationProgress copyWith({
    bool? deviceUnlocked,
    bool? remoteAccessDetected,
    int? batteryPercent,
    int? playSeconds,
    int? targetPlaySeconds,
    String? chosenEndingId,
    String? accusedCharacterId,
    double? clueCompletion,
    double? timelineCompletion,
    double? evidenceQuality,
    double? investigationScore,
  }) {
    this.deviceUnlocked = deviceUnlocked ?? this.deviceUnlocked;
    this.remoteAccessDetected = remoteAccessDetected ?? this.remoteAccessDetected;
    this.batteryPercent = batteryPercent ?? this.batteryPercent;
    this.playSeconds = playSeconds ?? this.playSeconds;
    this.targetPlaySeconds = targetPlaySeconds ?? this.targetPlaySeconds;
    this.chosenEndingId = chosenEndingId ?? this.chosenEndingId;
    this.accusedCharacterId = accusedCharacterId ?? this.accusedCharacterId;
    this.clueCompletion = clueCompletion ?? this.clueCompletion;
    this.timelineCompletion = timelineCompletion ?? this.timelineCompletion;
    this.evidenceQuality = evidenceQuality ?? this.evidenceQuality;
    this.investigationScore = investigationScore ?? this.investigationScore;
    return this;
  }

  Map<String, dynamic> toJson() => {
        'caseId': caseId,
        'deviceUnlocked': deviceUnlocked,
        'discoveredClues': discoveredClues.toList(),
        'analyzedClues': analyzedClues.toList(),
        'openedConversations': openedConversations.toList(),
        'openedMessages': openedMessages.toList(),
        'viewedPhotos': viewedPhotos.toList(),
        'unlockedContent': unlockedContent.toList(),
        'unlockedTimeline': unlockedTimeline.toList(),
        'solvedPuzzles': solvedPuzzles.toList(),
        'markedContradictions': markedContradictions.toList(),
        'boardConnections': boardConnections.map((e) => e.toJson()).toList(),
        'investigatorNotes': investigatorNotes.map((e) => e.toJson()).toList(),
        'flags': flags,
        'suspectSuspicion': suspectSuspicion,
        'remoteAccessDetected': remoteAccessDetected,
        'batteryPercent': batteryPercent,
        'playSeconds': playSeconds,
        'targetPlaySeconds': targetPlaySeconds,
        'chosenEndingId': chosenEndingId,
        'accusedCharacterId': accusedCharacterId,
        'unlockedEndings': unlockedEndings.toList(),
        'firedLiveEvents': firedLiveEvents.toList(),
        'clueCompletion': clueCompletion,
        'timelineCompletion': timelineCompletion,
        'evidenceQuality': evidenceQuality,
        'investigationScore': investigationScore,
      };

  factory InvestigationProgress.fromJson(Map<String, dynamic> j) =>
      InvestigationProgress(
        caseId: j['caseId'] as String,
        deviceUnlocked: j['deviceUnlocked'] as bool? ?? false,
        discoveredClues: {...((j['discoveredClues'] as List?) ?? const []).cast<String>()},
        analyzedClues: {...((j['analyzedClues'] as List?) ?? const []).cast<String>()},
        openedConversations: {
          ...((j['openedConversations'] as List?) ?? const []).cast<String>()
        },
        openedMessages: {...((j['openedMessages'] as List?) ?? const []).cast<String>()},
        viewedPhotos: {...((j['viewedPhotos'] as List?) ?? const []).cast<String>()},
        unlockedContent: {...((j['unlockedContent'] as List?) ?? const []).cast<String>()},
        unlockedTimeline: {
          ...((j['unlockedTimeline'] as List?) ?? const []).cast<String>()
        },
        solvedPuzzles: {...((j['solvedPuzzles'] as List?) ?? const []).cast<String>()},
        markedContradictions: {
          ...((j['markedContradictions'] as List?) ?? const []).cast<String>()
        },
        boardConnections: ((j['boardConnections'] as List?) ?? const [])
            .map((e) => BoardConnection.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        investigatorNotes: ((j['investigatorNotes'] as List?) ?? const [])
            .map((e) => InvestigatorNote.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        flags: Map<String, dynamic>.from(j['flags'] as Map? ?? {}),
        suspectSuspicion: {
          for (final e in (j['suspectSuspicion'] as Map? ?? {}).entries)
            e.key.toString(): (e.value as num).toInt(),
        },
        remoteAccessDetected: j['remoteAccessDetected'] as bool? ?? false,
        batteryPercent: (j['batteryPercent'] as num?)?.toInt() ?? 87,
        playSeconds: (j['playSeconds'] as num?)?.toInt() ?? 0,
        targetPlaySeconds: (j['targetPlaySeconds'] as num?)?.toInt() ?? 1800,
        chosenEndingId: j['chosenEndingId'] as String?,
        accusedCharacterId: j['accusedCharacterId'] as String?,
        unlockedEndings: {
          ...((j['unlockedEndings'] as List?) ?? const []).cast<String>()
        },
        firedLiveEvents: {
          ...((j['firedLiveEvents'] as List?) ?? const []).cast<String>()
        },
        clueCompletion: (j['clueCompletion'] as num?)?.toDouble() ?? 0,
        timelineCompletion: (j['timelineCompletion'] as num?)?.toDouble() ?? 0,
        evidenceQuality: (j['evidenceQuality'] as num?)?.toDouble() ?? 0,
        investigationScore: (j['investigationScore'] as num?)?.toDouble() ?? 0,
      );
}
