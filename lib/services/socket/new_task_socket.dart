import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class NewTaskSocket {
  static WebSocketChannel? _socketChannel;

  void connectSocketChannel(String socketURL) {
    _socketChannel = IOWebSocketChannel.connect(socketURL);
  }

  Stream<dynamic>? get subscribeToSocketStream {
    return _socketChannel?.stream;
  }

  Future<dynamic>? closeSocketChannel() {
    return _socketChannel?.sink.close(status.goingAway);
  }
}
