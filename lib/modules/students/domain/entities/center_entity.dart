import 'package:equatable/equatable.dart';

class CenterEntity extends Equatable {
  final int id;
  final String name;
  final String address;

  const CenterEntity({
    required this.id,
    required this.name,
    required this.address,
  });

  @override
  List<Object?> get props => [id, name, address];
}
