import 'package:equatable/equatable.dart';

class Suggestion extends Equatable {
  final String title;
  final String description;
  final String type;

  const Suggestion({
    required this.title,
    required this.description,
    required this.type,
  });

  @override
  List<Object?> get props => [title, description, type];
}
