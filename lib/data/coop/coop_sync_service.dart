import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/coop/coop_models.dart';
import 'coop_peer.dart'
    if (dart.library.html) 'coop_sync_web.dart' as peer;

/// Sincronização de sala cooperativa (storage local + PeerJS na web).
class CoopSyncService {
  final _stateCtrl = StreamController<CoopRoomState>.broadcast();
  final _msgCtrl = StreamController<CoopEnvelope>.broadcast();
  CoopRoomState? _state;
  bool _host = false;
  String? _code;
  Timer? _poll;
  dynamic _peer;
  dynamic _conn;
  int _lastMsgTs = 0;

  Stream<CoopRoomState> get states => _stateCtrl.stream;
  Stream<CoopEnvelope> get messages => _msgCtrl.stream;
  bool get isHost => _host;
  String? get roomCode => _code;
  CoopRoomState? get current => _state;

  static String _storageKey(String code) => 'ua_coop_room_${code.toUpperCase()}';

  Future<void> hostRoom(CoopRoomState initial) async {
    _host = true;
    _code = initial.roomCode.toUpperCase();
    _state = initial;
    await _persist(initial);
    _stateCtrl.add(initial);
    _startPolling();
    if (kIsWeb) {
      await _bindPeer(host: true);
    }
  }

  Future<CoopRoomState?> joinRoom(String roomCode) async {
    _host = false;
    _code = roomCode.toUpperCase();
    final existing = await _read(_code!);
    if (existing != null) {
      _state = existing;
      _stateCtrl.add(existing);
    }
    _startPolling();
    if (kIsWeb) {
      await _bindPeer(host: false);
    }
    await send(const CoopEnvelope('hello', {'role': 'playerB'}));
    return existing;
  }

  Future<void> publish(CoopRoomState state) async {
    final next = state.copyWith(revision: state.revision + 1);
    _state = next;
    await _persist(next);
    _stateCtrl.add(next);
    peer.coopPeerSend(_conn, {'type': 'state', 'payload': next.toJson()});
  }

  Future<void> send(CoopEnvelope envelope) async {
    _msgCtrl.add(envelope);
    peer.coopPeerSend(_conn, envelope.toJson());
    if (_code != null) {
      final prefs = await SharedPreferences.getInstance();
      final ts = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString(
        '${_storageKey(_code!)}_msg',
        jsonEncode({...envelope.toJson(), 'ts': ts}),
      );
    }
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(milliseconds: 800), (_) async {
      if (_code == null) return;
      final remote = await _read(_code!);
      if (remote != null &&
          (_state == null || remote.revision > _state!.revision)) {
        _state = remote;
        _stateCtrl.add(remote);
      }
      final prefs = await SharedPreferences.getInstance();
      final rawMsg = prefs.getString('${_storageKey(_code!)}_msg');
      if (rawMsg == null) return;
      try {
        final map = jsonDecode(rawMsg) as Map<String, dynamic>;
        final ts = (map['ts'] as num?)?.toInt() ?? 0;
        if (ts > _lastMsgTs) {
          _lastMsgTs = ts;
          _msgCtrl.add(CoopEnvelope.fromJson(map));
        }
      } catch (_) {}
    });
  }

  Future<void> _persist(CoopRoomState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey(state.roomCode), jsonEncode(state.toJson()));
  }

  Future<CoopRoomState?> _read(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey(code));
    if (raw == null) return null;
    try {
      return CoopRoomState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _bindPeer({required bool host}) async {
    try {
      await peer.coopPeerBind(
        host: host,
        peerId: 'ua-coop-$_code',
        onData: (map) {
          final type = map['type'] as String?;
          if (type == 'state') {
            final st = CoopRoomState.fromJson(
              Map<String, dynamic>.from(map['payload'] as Map),
            );
            if (_state == null || st.revision >= _state!.revision) {
              _state = st;
              _persist(st);
              _stateCtrl.add(st);
            }
          } else if (type != null) {
            _msgCtrl.add(CoopEnvelope.fromJson(map));
          }
        },
        onReady: (p, c) {
          _peer = p;
          if (c != null) _conn = c;
        },
      );
    } catch (e) {
      debugPrint('PeerJS: $e');
    }
  }

  Future<void> dispose() async {
    _poll?.cancel();
    peer.coopPeerDestroy(_peer);
    await _stateCtrl.close();
    await _msgCtrl.close();
  }
}
