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
    