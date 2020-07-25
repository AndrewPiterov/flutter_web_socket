import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ws/services/app_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadChat extends ChatEvent {}

class AddMessage extends ChatEvent {
  final String message;

  AddMessage(this.message);
}

class ResetChat extends ChatEvent {}

class ChatState extends Equatable {
  @override
  List<Object> get props => [];
}

class ChatIsNotLoaded extends ChatState {}

class ChatIsLoading extends ChatState {}

class ChatIsLoaded extends ChatState {
  final List<String> lastMessages;

  ChatIsLoaded(this.lastMessages);

  @override
  List<Object> get props => [lastMessages];
}

class ChatCouldNotLoad extends ChatState {
  final _reason;

  ChatCouldNotLoad(this._reason);

  @override
  List<Object> get props => [_reason];
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final AppService _service;
  WebSocketChannel _channel;

  final _newMessageStreamController = StreamController<String>();
  Stream<String> get newMessage => _newMessageStreamController.stream;

  /// The initial state
  ChatBloc(this._service) : super(ChatIsNotLoaded()) {
    _channel = IOWebSocketChannel.connect(_service.webSocketChannel);
    _channel.stream.listen((event) {
      debugPrint('New message $event');
      _newMessageStreamController.add(event.toString());
    });
  }

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is LoadChat) {
      try {
        yield ChatIsLoading();
        // TODO: call repository or API
        await new Future.delayed(const Duration(seconds: 1));
        yield ChatIsLoaded(['Hello', 'Hi', 'How are you???']);
      } catch (e) {
        yield ChatCouldNotLoad(e.toString());
      }
    } else if (event is AddMessage) {
      _channel.sink.add(event.message);
    } else if (event is ResetChat) {
      yield ChatIsNotLoaded();
    }
  }

  void dispose() {
    _newMessageStreamController.close();
    _channel.sink.close();
  }
}
