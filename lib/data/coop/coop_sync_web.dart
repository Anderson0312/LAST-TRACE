// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;

Future<void> coopPeerBind({
  required bool host,
  required String peerId,
  required void Function(Map<String, dynamic> data) onData,
  required void Function(dynamic peer, dynamic conn) onReady,
}) async {
  final peerCtor = js.context['Peer'];
  if (peerCtor == null) return;

  final completer = Completer<void>();
  final peer = host
      ? js.JsObject(peerCtor, [peerId])
      : js.JsObject(peerCtor);

  peer.callMethod('on', [
    'open',
    js.allowInterop((dynamic id) {
      if (!host) {
        final conn = peer.callMethod('connect', [peerId]);
        _wire(conn, onData);
        onReady(peer, conn);
      } else {
        onReady(peer, null);
      }
      if (!completer.isCompleted) completer.complete();
    }),
  ]);

  peer.callMethod('on', [
    'connection',
    js.allowInterop((dynamic conn) {
      _wire(conn, onData);
      onReady(peer, conn);
    }),
  ]);

  peer.callMethod('on', [
    'error',
    js.allowInterop((dynamic err) {
      html.window.console.warn('PeerJS error: $err');
      if (!completer.isCompleted) completer.complete();
    }),
  ]);

  await completer.future.timeout(const Duration(seconds: 8), onTimeout: () {});
}

void _wire(dynamic conn, void Function(Map<String, dynamic> data) onData) {
  conn.callMethod('on', [
    'data',
    js.allowInterop((dynamic raw) {
      try {
        if (raw is String) {
          onData(jsonDecode(raw) as Map<String, dynamic>);
        } else if (raw is js.JsObject) {
          onData(Map<String, dynamic>.from(js.JsObject.jsify(raw) as Map));
        }
      } catch (_) {
        try {
          final text = js.context['JSON'].callMethod('stringify', [raw]) as String;
          onData(jsonDecode(text) as Map<String, dynamic>);
        } catch (_) {}
      }
    }),
  ]);
}

void coopPeerSend(dynamic conn, Map<String, dynamic> data) {
  if (conn == null) return;
  try {
    conn.callMethod('send', [jsonEncode(data)]);
  } catch (_) {}
}

void coopPeerDestroy(dynamic peer) {
  try {
    peer?.callMethod('destroy', []);
  } catch (_) {}
}
