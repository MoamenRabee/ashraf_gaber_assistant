import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/modules/students/domain/usecases/get_filters_usecase.dart';
import 'package:samy_mossad_assistant/modules/students/domain/usecases/get_local_students_usecase.dart';
import 'package:samy_mossad_assistant/modules/students/domain/usecases/get_students_count_usecase.dart';
import 'package:samy_mossad_assistant/modules/students/domain/usecases/sync_students_usecase.dart';
import 'package:samy_mossad_assistant/modules/students/presentation/cubit/students_state.dart';

class StudentsCubit extends Cubit<StudentsState> {
  final SyncStudentsUseCase syncStudentsUseCase;
  final GetLocalStudentsUseCase getLocalStudentsUseCase;
  final GetStudentsCountUseCase getStudentsCountUseCase;
  final GetFiltersUseCase getFiltersUseCase;

  StudentsCubit({
    required this.syncStudentsUseCase,
    required this.getLocalStudentsUseCase,
    required this.getStudentsCountUseCase,
    required this.getFiltersUseCase,
  }) : super(StudentsInitial());

  Future<void> syncStudents() async {
    emit(StudentsSyncing());

    final result = await syncStudentsUseCase();

    result.fold((error) => emit(StudentsError(error)), (students) {
      emit(
        StudentsSyncSuccess(
          count: students.length,
          message: 'تم مزامنة ${students.length} طالب بنجاح',
        ),
      );
      // بعد المزامنة، نجلب الطلاب المحليين
      getLocalStudents();
    });
  }

  Future<void> getLocalStudents({
    String? searchQuery,
    int? classroomId,
    int? centerId,
  }) async {
    emit(StudentsLoading());

    final studentsResult = await getLocalStudentsUseCase(
      searchQuery: searchQuery,
      classroomId: classroomId,
      centerId: centerId,
    );

    final countResult = await getStudentsCountUseCase();
    final filtersResult = await getFiltersUseCase();

    studentsResult.fold((error) => emit(StudentsError(error)), (students) {
      final count = countResult.getOrElse(() => 0);
      final filters = filtersResult.getOrElse(
        () => {'classrooms': [], 'centers': []},
      );

      emit(
        StudentsLoaded(
          students: students,
          totalCount: count,
          classrooms: filters['classrooms'] ?? [],
          centers: filters['centers'] ?? [],
        ),
      );
    });
  }

  Future<void> searchStudents({
    String? searchQuery,
    int? classroomId,
    int? centerId,
  }) async {
    // نحتفظ بالـ state الحالي إذا كان loaded
    final currentState = state;
    if (currentState is StudentsLoaded) {
      emit(currentState.copyWith(isSearching: true));
    }

    final studentsResult = await getLocalStudentsUseCase(
      searchQuery: searchQuery,
      classroomId: classroomId,
      centerId: centerId,
    );

    final countResult = await getStudentsCountUseCase();

    studentsResult.fold((error) => emit(StudentsError(error)), (students) {
      final count = countResult.getOrElse(() => 0);

      // نحتفظ بالـ filters من الـ state السابق
      if (currentState is StudentsLoaded) {
        emit(
          StudentsLoaded(
            students: students,
            totalCount: count,
            classrooms: currentState.classrooms,
            centers: currentState.centers,
            isSearching: false,
          ),
        );
      } else {
        // في حالة لم يكن هناك state سابق، نجلب الفلاتر
        final filtersResult = getFiltersUseCase();
        filtersResult.then((result) {
          result.fold((error) => emit(StudentsError(error)), (filters) {
            emit(
              StudentsLoaded(
                students: students,
                totalCount: count,
                classrooms: filters['classrooms'] ?? [],
                centers: filters['centers'] ?? [],
                isSearching: false,
              ),
            );
          });
        });
      }
    });
  }
}
