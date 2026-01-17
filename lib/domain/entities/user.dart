import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String
  password; // In real app, never store plain password in entity if possible, or handle securely

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
  });

  @override
  List<Object?> get props => [id, email, name, password];
}
