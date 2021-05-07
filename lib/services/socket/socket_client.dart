import 'package:flutter/foundation.dart';
import 'package:hds_overlay/model/log_message.dart';
import 'package:hds_overlay/services/socket/socket_base.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketClient extends SocketBase {
  WebSocketChannel? _channel;

  Future<WebSocketChannel> connect(String clientName, String ip) async {
    try {
      Uri uri;
      if (ip.startsWith('ws')) {
        uri = Uri.parse('$ip');
      } else {
        uri = Uri.parse('ws://$ip');
      }
      if (!uri.hasPort) {
        uri = Uri.parse('${uri.toString()}:3476');
      }
      final channel = WebSocketChannel.connect(uri);
      channel.sink.add('clientName:$clientName');
      logStreamController
          .add(LogMessage(LogLevel.good, 'Connecting to server: $ip'));

      reconnectOnDisconnect(channel, clientName, ip);
      return Future.value(channel);
    } catch (e) {
      print(e.toString());
      logStreamController
          .add(LogMessage(LogLevel.error, 'Unable to connect to server: $ip'));
      Future.delayed(Duration(seconds: 10), () => connect(clientName, ip));
      return Future.error('Unable to connect to server: $ip');
    }
  }

  void reconnectOnDisconnect(
    WebSocketChannel channel,
    String clientName,
    String ip,
  ) async {
    // This channel is used for sending data on desktop and receiving data on web
    final channelSubscription = channel.stream.listen((message) {
      if (kIsWeb) {
        handleMessage(channel, message, 'watch');
      }
    });
    channelSubscription.onDone(() {
      channelSubscription.cancel();
      reconnect(clientName, ip);
    });
    channelSubscription.onError((error) {
      print(error);
      channelSubscription.cancel();
      reconnect(clientName, ip);
    });
  }

  void reconnect(String clientName, String ip) {
    logStreamController
        .add(LogMessage(LogLevel.warn, 'Disconnected from server: $ip'));
    Future.delayed(Duration(seconds: 5), () => connect(clientName, ip));
  }

  @override
  Future<void> start(
    int port,
    String clientName,
    List<String> serverIps,
  ) async {
    _channel = await connect('browser', 'ws://localhost:$port');
  }

  @override
  Future<void> stop() {
    _channel?.sink.close();
    return Future.value();
  }
}
