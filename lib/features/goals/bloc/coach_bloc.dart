import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/data_repository.dart';

// Events
abstract class CoachEvent extends Equatable {
  const CoachEvent();
  @override
  List<Object> get props => [];
}

class LoadCoach extends CoachEvent {}

class SendQuery extends CoachEvent {
  final String query;
  const SendQuery(this.query);
  @override
  List<Object> get props => [query];
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
        final response = await _repo.askCoach(query);
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
        // Add error message as bot response
        final newerMessages = List<ChatMessage>.from(state.messages)
          ..add(
            ChatMessage(
              text: "Error: $e",
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
