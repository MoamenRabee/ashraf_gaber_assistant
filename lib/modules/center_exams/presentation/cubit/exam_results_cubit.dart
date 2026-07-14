import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/core/database_helper.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_result_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/exam_student_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/usecases/add_student_result_usecase.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/usecases/get_exam_results_usecase.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/usecases/get_exam_students_usecase.dart';
import 'package:samy_mossad_assistant/modules/center_exams/presentation/cubit/exam_results_state.dart';

class ExamResultsCubit extends Cubit<ExamResultsState> {
  final GetExamResultsUseCase getExamResultsUseCase;
  final GetExamStudentsUseCase getExamStudentsUseCase;
  final AddStudentResultUseCase addStudentResultUseCase;
  final DatabaseHelper databaseHelper;
  final int examId;

  List<ExamStudentEntity> _allStudents = [];
  List<ExamStudentEntity> _filteredStudents = [];
  List<ExamResultEntity> _currentResults = [];

  ExamResultsCubit(
    this.getExamResultsUseCase,
    this.getExamStudentsUseCase,
    this.addStudentResultUseCase,
    this.databaseHelper,
    this.examId,
  ) : super(ExamResultsInitial());

  Future<void> loadExamResults() async {
    emit(ExamResultsLoading());

    final result = await getExamResultsUseCase(examId);

    result.fold((error) => emit(ExamResultsError(error)), (results) {
      _currentResults = results;
      final sortedResults = _sortResults(results, SortType.highToLow);
      emit(
        ExamResultsLoaded(allResults: results, filteredResults: sortedResults),
      );
    });
  }

  void searchResults(String query) {
    if (state is! ExamResultsLoaded) return;

    final currentState = state as ExamResultsLoaded;
    List<ExamResultEntity> filtered = currentState.allResults;

    if (query.isNotEmpty) {
      filtered = filtered.where((result) {
        return result.studentName.toLowerCase().contains(query.toLowerCase()) ||
            result.studentCode.toString().contains(query) ||
            result.studentPhone.contains(query);
      }).toList();
    }

    filtered = _sortResults(filtered, currentState.sortType);

    emit(currentState.copyWith(filteredResults: filtered, searchQuery: query));
  }

  void sortResults(SortType sortType) {
    if (state is! ExamResultsLoaded) return;

    final currentState = state as ExamResultsLoaded;
    final sorted = _sortResults(currentState.filteredResults, sortType);

    emit(currentState.copyWith(filteredResults: sorted, sortType: sortType));
  }

  List<ExamResultEntity> _sortResults(
    List<ExamResultEntity> results,
    SortType sortType,
  ) {
    final sorted = List<ExamResultEntity>.from(results);

    switch (sortType) {
      case SortType.highToLow:
        sorted.sort((a, b) => b.mark.compareTo(a.mark));
        break;
      case SortType.lowToHigh:
        sorted.sort((a, b) => a.mark.compareTo(b.mark));
        break;
      case SortType.alphabetical:
        sorted.sort((a, b) => a.studentName.compareTo(b.studentName));
        break;
    }

    return sorted;
  }

  Future<void> loadExamStudents(int classroomId, int centerId) async {
    try {
      // Get student IDs who already have results
      final studentIdsWithResults = _currentResults
          .map((r) => r.studentId)
          .toList();

      // Get students from local database who don't have results yet
      final localStudents = await databaseHelper.getStudentsWithoutExamResult(
        classroomId: classroomId,
        centerId: centerId,
        studentIdsWithResults: studentIdsWithResults,
      );

      // Convert to ExamStudentEntity
      _allStudents = localStudents
          .map(
            (student) => ExamStudentEntity(
              id: student.studentId,
              name: student.name,
              code: student.studentId.toString(),
              phone: student.phone,
              parentPhone: student.parentPhone,
            ),
          )
          .toList();

      _filteredStudents = _allStudents;
    } catch (e) {
      _allStudents = [];
      _filteredStudents = [];
    }
  }

  List<ExamStudentEntity> getFilteredStudents() => _filteredStudents;

  void searchStudents(String query) {
    if (query.isEmpty) {
      _filteredStudents = _allStudents;
    } else {
      _filteredStudents = _allStudents.where((student) {
        return student.name.toLowerCase().contains(query.toLowerCase()) ||
            student.code.toLowerCase().contains(query.toLowerCase()) ||
            (student.phone?.contains(query) ?? false);
      }).toList();
    }
  }

  Future<void> addResult({
    required int studentId,
    required double mark,
    String? notes,
  }) async {
    emit(ExamResultsAddingResult());

    final result = await addStudentResultUseCase(
      localExamId: examId,
      studentId: studentId,
      mark: mark,
      notes: notes,
    );

    result.fold((error) => emit(ExamResultsAddError(error)), (_) {
      emit(const ExamResultsAddSuccess('تم إضافة الدرجة بنجاح'));
    });
  }
}
