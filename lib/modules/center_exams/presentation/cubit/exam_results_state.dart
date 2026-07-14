import 'package:equatable/equatable.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_result_entity.dart';

enum SortType { highToLow, lowToHigh, alphabetical }

abstract class ExamResultsState extends Equatable {
  const ExamResultsState();

  @override
  List<Object?> get props => [];
}

class ExamResultsInitial extends ExamResultsState {}

class ExamResultsLoading extends ExamResultsState {}

class ExamResultsLoaded extends ExamResultsState {
  final List<ExamResultEntity> allResults;
  final List<ExamResultEntity> filteredResults;
  final String searchQuery;
  final SortType sortType;

  const ExamResultsLoaded({
    required this.allResults,
    required this.filteredResults,
    this.searchQuery = '',
    this.sortType = SortType.highToLow,
  });

  @override
  List<Object?> get props => [
    allResults,
    filteredResults,
    searchQuery,
    sortType,
  ];

  ExamResultsLoaded copyWith({
    List<ExamResultEntity>? allResults,
    List<ExamResultEntity>? filteredResults,
    String? searchQuery,
    SortType? sortType,
  }) {
    return ExamResultsLoaded(
      allResults: allResults ?? this.allResults,
      filteredResults: filteredResults ?? this.filteredResults,
      searchQuery: searchQuery ?? this.searchQuery,
      sortType: sortType ?? this.sortType,
    );
  }
}

class ExamResultsError extends ExamResultsState {
  final String message;

  const ExamResultsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExamResultsAddingResult extends ExamResultsState {}

class ExamResultsAddSuccess extends ExamResultsState {
  final String message;

  const ExamResultsAddSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ExamResultsAddError extends ExamResultsState {
  final String message;

  const ExamResultsAddError(this.message);

  @override
  List<Object?> get props => [message];
}
