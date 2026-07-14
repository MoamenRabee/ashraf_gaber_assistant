import 'package:equatable/equatable.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/center_exam_entity.dart';

abstract class CenterExamsState extends Equatable {
  const CenterExamsState();

  @override
  List<Object?> get props => [];
}

class CenterExamsInitial extends CenterExamsState {}

class CenterExamsLoading extends CenterExamsState {}

class CenterExamsNoInternet extends CenterExamsState {}

class CenterExamsLoaded extends CenterExamsState {
  final List<CenterExamEntity> allExams;
  final List<CenterExamEntity> filteredExams;
  final int? selectedClassroomId;
  final int? selectedCenterId;
  final String searchQuery;

  const CenterExamsLoaded({
    required this.allExams,
    required this.filteredExams,
    this.selectedClassroomId,
    this.selectedCenterId,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
    allExams,
    filteredExams,
    selectedClassroomId,
    selectedCenterId,
    searchQuery,
  ];

  CenterExamsLoaded copyWith({
    List<CenterExamEntity>? allExams,
    List<CenterExamEntity>? filteredExams,
    int? selectedClassroomId,
    int? selectedCenterId,
    String? searchQuery,
    bool clearClassroom = false,
    bool clearCenter = false,
  }) {
    return CenterExamsLoaded(
      allExams: allExams ?? this.allExams,
      filteredExams: filteredExams ?? this.filteredExams,
      selectedClassroomId: clearClassroom
          ? null
          : (selectedClassroomId ?? this.selectedClassroomId),
      selectedCenterId: clearCenter
          ? null
          : (selectedCenterId ?? this.selectedCenterId),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CenterExamsError extends CenterExamsState {
  final String message;

  const CenterExamsError(this.message);

  @override
  List<Object?> get props => [message];
}
