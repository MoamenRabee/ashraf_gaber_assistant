import 'package:samy_mossad_assistant/modules/students/domain/entities/center_entity.dart';

class CenterModel extends CenterEntity {
  const CenterModel({
    required super.id,
    required super.name,
    required super.address,
  });

  factory CenterModel.fromJson(Map<String, dynamic> json) {
    return CenterModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'address': address};
  }
}
