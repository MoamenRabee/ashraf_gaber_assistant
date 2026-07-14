class ExamStudentEntity {
  final int id;
  final String name;
  final String code;
  final String? phone;
  final String? parentPhone;

  ExamStudentEntity({
    required this.id,
    required this.name,
    required this.code,
    this.phone,
    this.parentPhone,
  });
}
