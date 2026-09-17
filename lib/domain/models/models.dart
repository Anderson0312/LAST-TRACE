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
        displayName: j['displayName'] as String,
        number: j['number'] as String?,
        type: CallType.values.firstWhere(
          (e) => e.name == j['type'],
          orElse: () => CallType.incoming,
        ),
        timestamp: DateTime.parse(j['timestamp'] as String),
        durationSeconds: j['durationSeconds'] as int? ?? 0,
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
        unknown: j['unknown'] as bool? ?? false,
      );
}

class EmailItem {
  final String id;
  final String from;
  final List<String> to;
  final List<String> cc;
  final List<String> bcc;
  final String subject;
  final String body;
  final DateTime timestamp;
  final bool isDraft;
  final bool isTrash;
  final bool isSpam;
  final bool isArchived;
  final List<String> attachments;
  final List<String> revealsClueIds;
  final bool locked;

  const EmailItem({
    required this.id,
    required this.from,
    required this.to,
    this.cc = const [],
    this.bcc = const [],
    required this.subject,
    required this.body,
    required this.timestamp,
    this.isDraft = false,
    this.isTrash = false,
    this.isSpam = false,
    this.isArchived = false,
    this.attachments = const [],
    this.revealsClueIds = const [],
    this.locked = false,
  });

  factory EmailItem.fromJson(Map<String, dynamic> j) => EmailItem(
        id: j['id'] as String,
        from: j['from'] as String,
        to: (j['to'] as List?)?.cast<String>() ?? const [],
        cc: (j['cc'] as List?)?.cast<String>() ?? const [],
        bcc: (j['bcc'] as List?)?.cast<String>() ?? const [],
        subject: j['subject'] as String,
        body: j['body'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        isDraft: j['isDraft'] as bool? ?? false,
        isTrash: j['isTrash'] as bool? ?? false,
        isSpam: j['isSpam'] as bool? ?? false,
        isArchived: j['isArchived'] as bool? ?? false,
        attachments: (j['attachments'] as List?)?.cast<String>() ?? const [],
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
        locked: j['locked'] as bool? ?? false,
      );
}

class NoteItem {
  final String id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool locked;
  final String? passwordHint;
  final List<String> revealsClueIds;
  final bool encrypted;

  const NoteItem({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    this.locked = false,
    this.passwordHint,
    this.revealsClueIds = const [],
    this.encrypted = false,
  });

  factory NoteItem.fromJson(Map<String, dynamic> j) => NoteItem(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        locked: j['locked'] as bool? ?? false,
        passwordHint: j['passwordHint'] as String?,
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
        encrypted: j['encrypted'] as bool? ?? false,
      );
}

class FileItem {
  final String id;
  final String name;
  final String type;
  final String path;
  final String? content;
  final bool corrupted;
  final bool passwordProtected;
  final String? password;
  final bool hidden;
  final DateTime modifiedAt;
  final List<String> revealsClueIds;

  const FileItem({
    required this.id,
    required this.name,
    required this.type,
    required this.path,
    this.content,
    this.corrupted = false,
    this.passwordProtected = false,
    this.password,
    this.hidden = false,
    required this.modifiedAt,
    this.revealsClueIds = const [],
  });

  factory FileItem.fromJson(Map<String, dynamic> j) => FileItem(
        id: j['id'] as String,
        name: j['name'] as String,
        type: j['type'] as String? ?? 'txt',
        path: j['path'] as String? ?? '/',
        content: j['content'] as String?,
        corrupted: j['corrupted'] as bool? ?? false,
        passwordProtected: j['passwordProtected'] as bool? ?? false,
        password: j['password'] as String?,
        hidden: j['hidden'] as bool? ?? false,
        modifiedAt: DateTime.parse(j['modifiedAt'] as String),
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class MapLocation {
  final String id;
  final String name;
  final String kind; // favorite, recent, searched, shared, history
  final double lat;
  final double lng;
  final DateTime? visitedAt;
  final String? note;
  final List<String> revealsClueIds;

  const MapLocation({
    required this.id,
    required this.name,
    required this.kind,
    required this.lat,
    required this.lng,
    this.visitedAt,
    this.note,
    this.revealsClueIds = const [],
  });

  factory MapLocation.fromJson(Map<String, dynamic> j) => MapLocation(
        id: j['id'] as String,
        name: j['name'] as String,
        kind: j['kind'] as String? ?? 'history',
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        visitedAt: j['visitedAt'] != null
            ? DateTime.parse(j['visitedAt'] as String)
            : null,
        note: j['note'] as String?,
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
        title: j['title'] as String,
        url: j['url'] as String,
        visitedAt: DateTime.parse(j['visitedAt'] as String),
        snippet: j['snippet'] as String?,
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class TimelineEvent {
  final String id;
  final DateTime timestamp;
  final String? location;
  final String? characterId;
  final String description;
  final String source;
  final double reliability; // 0-1
  final bool initiallyVisible;
  final List<String> unlockWithClueIds;
  final List<String> revealsClueIds;

  const TimelineEvent({
    required this.id,
    required this.timestamp,
    this.location,
    this.characterId,
    required this.description,
    required this.source,
    this.reliability = 0.8,
    this.initiallyVisible = false,
    this.unlockWithClueIds = const [],
    this.revealsClueIds = const [],
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> j) => TimelineEvent(
        id: j['id'] as String,
        timestamp: DateTime.parse(j['timestamp'] as String),
        location: j['location'] as String?,
        characterId: j['characterId'] as String?,
        description: j['description'] as String,
        source: j['source'] as String? ?? '',
        reliability: (j['reliability'] as num?)?.toDouble() ?? 0.8,
        initiallyVisible: j['initiallyVisible'] as bool? ?? false,
        unlockWithClueIds:
            (j['unlockWithClueIds'] as List?)?.cast<String>() ?? const [],
        revealsClueIds: (j['revealsClueIds'] as List?)?.cast<String>() ?? const [],
      );
}

class Ending {
  final String id;
  final String code; // A B C D E
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
    required this.requirements,
  });

  factory Ending.fromJson(Map<String, dynamic> j) => Ending(
        id: j['id'] as String,
        code: j['code'] as String,
        title: j['title'] as String,
        summary: j['summary'] as String,
        epilogue: j['epilogue'] as String,
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
  final String? liveEventId;

  const UnlockRule({
    required this.id,
    required this.requiredClueIds,
    this.minRequired = 0,
    this.unlockClueIds = const [],
    this.unlockTimelineIds = const [],
    this.unlockContentIds = const [],
    this.notificationText,
    this.liveEventId,
  });

  factory UnlockRule.fromJson(Map<String, dynamic> j) => UnlockRule(
        id: j['id'] as String,
        requiredClueIds: (j['requiredClueIds'] as List?)?.cast<String>() ?? const [],
        minRequired: j['minRequired'] as int? ?? 0,
        unlockClueIds: (j['unlockClueIds'] as List?)?.cast<String>() ?? const [],
        unlockTimelineIds:
            (j['unlockTimelineIds'] as List?)?.cast<String>() ?? const [],
        unlockContentIds:
            (j['unlockContentIds'] as List?)?.cast<String>() ?? const [],
        notificationText: j['notificationText'] as String?,
        liveEventId: j['liveEventId'] as String?,
      );
}

class LiveEvent {
  final String id;
  final String trigger; // time | clue | open_app | progress
  final Map<String, dynamic> condition;
  final String type; // notification | message | island | battery | remote
  final Map<String, dynamic> payload;
  final int delaySeconds;

  const LiveEvent({
    required this.id,
    required this.trigger,
    required this.condition,
    required this.type,
    required this.payload,
    this.delaySeconds = 0,
  });

  factory LiveEvent.fromJson(Map<String, dynamic> j) => 