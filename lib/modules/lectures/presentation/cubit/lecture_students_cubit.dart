import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/get_lecture_students_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/lecture_students_state.dart';

class LectureStudentsCubit extends Cubit<LectureStudentsState> {
  final GetLectureStudentsUseCase getLectureStudentsUseCase;
  Timer? _debounceTimer;

  LectureStudentsCubit(this.getLectureStudentsUseCase)
    : super(LectureStudentsInitial());

  Future<void> loadLectureStudents(int lectureId) async {
    emit(LectureStudentsLoading());

    // Check internet connection
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      emit(LectureStudentsNoInternet());
      return;
    }

    final result = await getLectureStudentsUseCase(lectureId);

    result.fold(
      (error) => emit(LectureStudentsError(error)),
      (students) => emit(
        LectureStudentsLoaded(students: students, filteredStudents: students),
      ),
    );
  }

  void searchStudents(String query) {
    if (state is! LectureStudentsLoaded) return;

    final currentState = state as LectureStudentsLoaded;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredStudents: currentState.students,
            searchQuery: '',
          ),
        );
        return;
      }

      final filtered = currentState.students.where((student) {
        final nameLower = student.name.toLowerCase();
        final phoneLower = student.phone.toLowerCase();
        final studentIdStr = student.studentId.toString();
        final queryLower = query.toLowerCase();

        return nameLower.contains(queryLower) ||
            phoneLower.contains(queryLower) ||
            studentIdStr.contains(queryLower);
      }).toList();

      emit(
        currentState.copyWith(filteredStudents: filtered, searchQuery: query),
      );
    });
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
