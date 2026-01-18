import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer';
import '../../../../domain/repositories/data_repository.dart';
import '../../../../core/exceptions.dart';
import '../../../../core/data.dart';

// Events
abstract class CoachEvent extends Equatable {
  const CoachEvent();
  @override
  List<Object> get props => [];
}

class LoadCoach extends CoachEvent {}

class SendQuery extends CoachEvent {
  final String query;
  final String lang;
  const SendQuery(this.query, this.lang);
  @override
  List<Object> get props => [query, lang];
}

class SendVoice extends CoachEvent {
  final String filePath;
  final String lang;
  const SendVoice(this.filePath, this.lang);
  @override
  List<Object> get props => [filePath, lang];
}

class ResetChat extends CoachEvent {}

// State
enum CoachStatus { initial, loading, success, failure }

class ChatMessage extends Equatable {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  List<Object> get props => [text, isUser, timestamp];
}

class CoachState extends Equatable {
  final CoachStatus status;
  final List<ChatMessage> messages;

  const CoachState({
    this.status = CoachStatus.initial,
    this.messages = const [],
  });

  CoachState copyWith({CoachStatus? status, List<ChatMessage>? messages}) {
    return CoachState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object> get props => [status, messages];
}

// Bloc
class CoachBloc extends Bloc<CoachEvent, CoachState> {
  final DataRepository _repo;

  CoachBloc(this._repo) : super(const CoachState()) {
    on<LoadCoach>((event, emit) {
      // Potentially load history if needed, for now just ready
      emit(state.copyWith(status: CoachStatus.success));
    });

    on<ResetChat>((event, emit) {
      emit(const CoachState(status: CoachStatus.initial, messages: []));
    });

    on<SendQuery>((event, emit) async {
      final query = event.query;
      if (query.isEmpty) return;

      // Add user message
      final newMessages = List<ChatMessage>.from(
        state.messages,
      )..add(ChatMessage(text: query, isUser: true, timestamp: DateTime.now()));

      emit(state.copyWith(messages: newMessages, status: CoachStatus.loading));

      try {
        final response = await _repo.askCoach(query, event.lang);
        final newerMessages = List<ChatMessage>.from(state.messages)
          ..add(
            ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        emit(
          state.copyWith(messages: newerMessages, status: CoachStatus.success),
        );
      } catch (e) {
        log('CoachBloc Error: $e', name: 'CoachBloc', error: e);
        String errorMessage;
        if (e is ConnectionTimeoutException) {
          errorMessage = t(event.lang, 'error.timeout');
        } else if (e is NetworkException) {
          errorMessage = t(event.lang, 'error.noInternet');
        } else if (e is ServerException) {
          errorMessage = t(event.lang, 'error.server');
        } else {
          // Use generic unknown error without raw exception details
          errorMessage = t(event.lang, 'error.unknown');
        }

        // Add error message as bot response
        final newerMessages = List<ChatMessage>.from(state.messages)
          ..add(
            ChatMessage(
              text: errorMessage,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        emit(
          state.copyWith(messages: newerMessages, status: CoachStatus.failure),
        );
      }
    });

    on<SendVoice>((event, emit) async {
      final newMessages = List<ChatMessage>.from(state.messages)
        ..add(
          ChatMessage(
            text: '🎤 Voice Message',
            isUser: true,
            timestamp: DateTime.now(),
          ),
        );

      emit(state.copyWith(messages: newMessages, status: CoachStatus.loading));

      try {
        final response = await _repo.chatWithVoice(event.filePath, event.lang);
        final newerMessages = List<ChatMessage>.from(state.messages)
          ..add(
            ChatMessage(
              text: response,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        emit(
          state.copyWith(messages: newerMessages, status: CoachStatus.success),
        );
      } catch (e) {
        log('CoachBloc Voice Error: $e', name: 'CoachBloc', error: e);
        String errorMessage;
        if (e is ConnectionTimeoutException) {
          errorMessage = t(event.lang, 'error.timeout');
        } else if (e is NetworkException) {
          errorMessage = t(event.lang, 'error.noInternet');
        } else if (e is ServerException) {
          errorMessage = t(event.lang, 'error.server');
        } else {
          errorMessage = t(event.lang, 'error.unknown');
        }

        final newerMessages = List<ChatMessage>.from(state.messages)
          ..add(
            ChatMessage(
              text: errorMessage,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
        emit(
          state.copyWith(messages: newerMessages, status: CoachStatus.failure),
        );
      }
    });
  }
}
