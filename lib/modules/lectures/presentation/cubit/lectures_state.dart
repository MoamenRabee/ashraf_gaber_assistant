import 'package:equatable/equatable.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_entity.dart';

abstract class LecturesState extends Equatable {
  const LecturesState();

  @override
  List<Object?> get props => [];
}

class LecturesInitial extends LecturesState {}

class LecturesLoading extends LecturesState {}

class LecturesLoaded extends LecturesState {
  final List<LectureEntity> lectures;

  /// المحاضرات الخاصة بالسنتر والصف المختارين بعد تطبيق فلتر الحالة والتاريخ.
  /// فاضية طالما لم يتم اختيار سنتر وصف.
  final List<LectureEntity> filteredLectures;

  /// كل السناتر مع عدد المحاضرات: {id, name, count}
  final List<Map<String, dynamic>> centers;

  /// صفوف السنتر المختار فقط مع عدد المحاضرات: {id, name, count}
  final List<Map<String, dynamic>> classrooms;
  final int? selectedCenterId;
  final int? selectedClassroomId;
  final LectureStatus? selectedStatus;
  final String? selectedDate;

  const LecturesLoaded({
    required this.lectures,
    required this.filteredLectures,
    this.centers = const [],
    this.classrooms = const [],
    this.selectedCenterId,
    this.selectedClassroomId,
    this.selectedStatus,
    this.selectedDate,
  });

  bool get hasActiveFilters => selectedStatus != null || selectedDate != null;

  String? get selectedCenterName => _nameOf(centers, selectedCenterId);

  String? get selectedClassroomName => _nameOf(classrooms, selectedClassroomId);

  static String? _nameOf(List<Map<String, dynamic>> items, int? id) {
    for (final item in items) {
      if (item['id'] == id) return item['name'] as String;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    lectures,
    filteredLectures,
    centers,
    classrooms,
    selectedCenterId,
    selectedClassroomId,
    selectedStatus,
    selectedDate,
  ];
}

class LecturesError extends LecturesState {
  final String message;

  const LecturesError(this.message);

  @override
  List<Object?> get props => [message];
}

class LecturesNoInternet extends LecturesState {}
