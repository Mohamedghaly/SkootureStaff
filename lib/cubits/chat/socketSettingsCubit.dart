import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' show min;

import 'package:eschool_saas_staff/data/models/chatMessage.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketSettingState {}

class SocketConnectSuccess extends SocketSettingState {}

class SocketReconnectSuccess extends SocketSettingState {}

class SocketConnectFailure extends SocketSettingState {}

class SocketMessageReceived extends SocketSettingState {
  final String from;
  final String to;
  final ChatMessage message;

  SocketMessageReceived({
    required this.from,
    required this.to,
    required this.message,
  });
}

class SocketSettingCubit extends Cubit<SocketSettingState> {
  SocketSettingCubit() : super(SocketSettingState());

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _streamSubscription;
  int? _userId;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  bool _isReconnecting = false;

  Future<void> init({required int userId}) async {
    _userId = userId;
    _reconnectAttempts = 0;
    _connect();
  }

  void _connect() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(reverbUrl),
      );

      // Wait for the WebSocket connection to be ready
      _channel!.ready.then((_) {
        log('[Reverb] WebSocket connected, waiting for connection_established...');

        // IMPORTANT: Set up listener FIRST, then wait for connection_established
        // before subscribing. This follows the correct Pusher protocol flow.
        _streamSubscription?.cancel();
        _streamSubscription = _channel!.stream.listen(
          (raw) {
            try {
              log('[Reverb] Raw message: $raw');
              final data = Map.from(jsonDecode(raw.toString()));
              final event = data['event'] as String?;

              log('[Reverb] Event received: $event');

              // Log errors from Reverb
              if (event == 'pusher:error') {
                log('[Reverb] ⚠️ ERROR from server: ${data['data']}');
                return;
              }

              // When connection is established, NOW subscribe and start pinging
              if (event == 'pusher:connection_established') {
                log('[Reverb] ✅ Connection established!');
                if (_isReconnecting) {
                  _isReconnecting = false;
                  emit(SocketReconnectSuccess());
                } else {
                  emit(SocketConnectSuccess());
                }
                _reconnectAttempts = 0;

                // Subscribe to the user's private channel
                final subscribeMsg = jsonEncode({
                  "event": "pusher:subscribe",
                  "data": {"channel": "user.$_userId"}
                });
                log('[Reverb] Sending subscribe: $subscribeMsg');
                _channel!.sink.add(subscribeMsg);
                return;
              }

              // Subscription confirmed
              if (event == 'pusher_internal:subscription_succeeded') {
                log('[Reverb] ✅ Subscribed to channel: user.$_userId');
                return;
              }

              // Server sends ping, we respond with pong to keep alive
              if (event == 'pusher:ping') {
                _channel?.sink.add(
                  jsonEncode({"event": "pusher:pong", "data": "{}"}),
                );
                log('[Reverb] Responded with pong');
                return;
              }

              // Handle new message event from Reverb
              if (event == 'NewMessage') {
                final payload =
                    jsonDecode(data['data'] as String) as Map<String, dynamic>;

                log('[Reverb] NewMessage payload: $payload');

                // Extract the message data from the payload
                final messageData = payload['message'] as Map<String, dynamic>?;

                if (messageData != null) {
                  final message = ChatMessage.fromJson(messageData);

                  emit(
                    SocketMessageReceived(
                      from: message.senderId.toString(),
                      to: _userId.toString(),
                      message: message,
                    ),
                  );
                }
              }
            } catch (e) {
              log('[Reverb] Error parsing event: $e');
            }
          },
          onDone: () {
            log('[Reverb] Connection closed, reconnecting...');
            _reconnect();
          },
          onError: (error) {
            log('[Reverb] Connection error: $error, reconnecting...');
            _reconnect();
          },
        );
      }).catchError((error) {
        log('[Reverb] Connection failed: $error');
        emit(SocketConnectFailure());
        _reconnect();
      });
    } catch (e) {
      log('[Reverb] Connection exception: $e');
      emit(SocketConnectFailure());
      _reconnect();
    }
  }

  void _reconnect() {
    _streamSubscription?.cancel();
    _channel = null;

    if (!isClosed && _userId != null) {
      _reconnectAttempts++;

      if (_reconnectAttempts > _maxReconnectAttempts) {
        log('[Reverb] Max reconnection attempts ($_maxReconnectAttempts) reached. Giving up.');
        emit(SocketConnectFailure());
        return;
      }

      // Exponential backoff: 3s, 6s, 12s, 24s, ... capped at 60s
      final delay = Duration(
        seconds: min(
          reverbReconnectDelay.inSeconds * (1 << (_reconnectAttempts - 1)),
          60,
        ),
      );

      log('[Reverb] Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts/$_maxReconnectAttempts)...');

      Future.delayed(delay, () {
        if (!isClosed) {
          _connect();
        }
      });
    }
  }

  /// Call this when the app resumes from background to ensure a fresh connection.
  void reconnect() {
    log('[Reverb] 🔄 Force reconnecting (app resumed)...');
    _streamSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    _reconnectAttempts = 0;
    _isReconnecting = true;
    _connect();
  }

  @override
  Future<void> close() async {
    _streamSubscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    super.close();
  }
}
