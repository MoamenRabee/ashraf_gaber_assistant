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
  final List<LectureEntity> filteredLectures;
  final List<Map<String, dynamic>> classrooms;
  final List<Map<String, dynamic>> centers;
  final int? selectedClassroomId;
  final int? selectedCenterId;
  final LectureStatus? selectedStatus;
  final String? selectedDate;

  const LecturesLoaded({
    required this.lectures,
    List<LectureEntity>? filteredLectures,
    this.classrooms = const [],
    this.centers = const [],
    this.selectedClassroomId,
    this.selectedCenterId,
    this.selectedStatus,
    this.selectedDate,
  }) : filteredLectures = filteredLectures ?? lectures;

  @override
  List<Object?> get props => [
    lectures,
    filteredLectures,
    classrooms,
    centers,
    selectedClassroomId,
    selectedCenterId,
    selectedStatus,
    selectedDate,
  ];

  LecturesLoaded copyWith({
    List<LectureEntity>? lectures,
    List<LectureEntity>? filteredLectures,
    List<Map<String, dynamic>>? classrooms,
    List<Map<String, dynamic>>? centers,
    int? selectedClassroomId,
    int? selectedCenterId,
    LectureStatus? selectedStatus,
    String? selectedDate,
    bool clearClassroom = false,
    bool clearCenter = false,
    bool clearStatus = false,
    bool clearDate = false,
  }) {
    return LecturesLoaded(
      lectures: lectures ?? this.lectures,
      filteredLectures: filteredLectures ?? this.filteredLectures,
      classrooms: classrooms ?? this.classrooms,
      centers: centers ?? this.centers,
      selectedClassroomId: clearClassroom
          ? null
          : (selectedClassroomId ?? this.selectedClassroomId),
      selectedCenterId: clearCenter
          ? null
          : (selectedCenterId ?? this.selectedCenterId),
      selectedStatus: clearStatus
          ? null
          : (selectedStatus ?? this.selectedStatus),
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
    );
  }
}

class LecturesError extends LecturesState {
  final String message;

  const LecturesError(this.message);

  @override
  List<Object?> get props => [message];
}

class LecturesNoInternet extends LecturesState {}
