Future<void> coopPeerBind({
  required bool host,
  required String peerId,
  required void Function(Map<String, dynamic> data) onData,
  required void Function(dynamic peer, dynamic conn) onReady,
}) async {}

void coopPeerSend(dynamic conn, Map<String, dynamic> data) {}

void coopPeerDestroy(dynamic peer) {}
