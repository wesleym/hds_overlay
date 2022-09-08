import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:hds_overlay/firebase/rtd_constants.dart';
import 'package:hds_overlay/model/log_message.dart';
import 'package:hds_overlay/services/connection/cloud_connection.dart';
import 'package:hds_overlay/services/connection/connection.dart';

class RtdConnection extends Connection with CloudConnection {
  static final _ref = FirebaseDatabase.instance.ref('/');

  StreamSubscription? _sub;

  @override
  Future<void> start(String ip, int port, String overlayId) async {
    log(LogLevel.hdsCloud, 'Connecting to HDS Cloud RTD Fallback...');

    overlayId = await handleCidCollision(overlayId, log);
    _sub = _ref
        .child(RtdConstants.overlays)
        .child(overlayId)
        .child(RtdConstants.message)
        .onValue
        .skip(1)
        .listen(handleEvent);

    log(LogLevel.hdsCloud, 'Connected to HDS Cloud RTD Fallback');
  }

  void handleEvent(DatabaseEvent event) {
    final message = event.snapshot.value as Map<String, dynamic>;
    final type = message['type'];
    final value = message['value'];
    final source = message['source'];

    handleMessage('$type:$value', source);
  }

  @override
  Future<void> stop() async {
    await _sub?.cancel();
  }
}