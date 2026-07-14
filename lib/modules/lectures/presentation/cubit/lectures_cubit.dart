import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/end_lecture_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/get_lectures_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/reopen_lecture_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/lectures_state.dart';

class LecturesCubit extends Cubit<LecturesState> {
  final GetLecturesUseCase getLecturesUseCase;
  final EndLectureUseCase endLectureUseCase;
  final ReopenLectureUseCase reopenLectureUseCase;

  LecturesCubit({required this.getLecturesUseCase, required this.endLectureUseCase, required this.reopenLectureUseCase})
    : super(LecturesInitial());

  Future<void> loadLectures() async {
    // التحقق من الإنترنت أولاً
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult.any(
      (result) =>
          result == ConnectivityResult.mobile || result == ConnectivityResult.wifi || result == ConnectivityResult.ethernet,
    );

    if (!hasInternet) {
      emit(LecturesNoInternet());
      return;
    }

    emit(LecturesLoading());

    final result = await getLecturesUseCase();

    result.fold((error) => emit(LecturesError(error)), (lectures) {
      // استخراج الفلاتر
      final classrooms = _extractClassrooms(lectures);
      final centers = _extractCenters(lectures);

      emit(LecturesLoaded(lectures: lectures, classrooms: classrooms, centers: centers));
    });
  }

  void applyFilters({int? classroomId, int? centerId, LectureStatus? status, String? date}) {
    final currentState = state;
    if (currentState is! LecturesLoaded) return;

    final filtered = currentState.lectures.where((lecture) {
      if (classroomId != null && lecture.classroom.id != classroomId) {
        return false;
      }
      if (centerId != null && lecture.center.id != centerId) {
        return false;
      }
      if (status != null && lecture.status != status) {
        return false;
      }
      if (date != null && lecture.date != date) {
        return false;
      }
      return true;
    }).toList();

    emit(
      currentState.copyWith(
        filteredLectures: filtered,
        selectedClassroomId: classroomId,
        selectedCenterId: centerId,
        selectedStatus: status,
        selectedDate: date,
      ),
    );
  }

  void clearFilters() {
    final currentState = state;
    if (currentState is! LecturesLoaded) return;

    emit(
      currentState.copyWith(
        filteredLectures: currentState.lectures,
        clearClassroom: true,
        clearCenter: true,
        clearStatus: true,
        clearDate: true,
      ),
    );
  }

  List<Map<String, dynamic>> _extractClassrooms(List<LectureEntity> lectures) {
    final classroomMap = <int, String>{};
    for (var lecture in lectures) {
      classroomMap[lecture.classroom.id] = lecture.classroom.name;
    }
    return classroomMap.entries.map((e) => {'id': e.key, 'name': e.value}).toList();
  }

  List<Map<String, dynamic>> _extractCenters(List<LectureEntity> lectures) {
    final centerMap = <int, String>{};
    for (var lecture in lectures) {
      centerMap[lecture.center.id] = lecture.center.name;
    }
    return centerMap.entries.map((e) => {'id': e.key, 'name': e.value}).toList();
  }

  Future<void> endLecture(int lectureId) async {
    // التحقق من الإنترنت أولاً
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult.any(
      (result) =>
          result == ConnectivityResult.mobile || result == ConnectivityResult.wifi || result == ConnectivityResult.ethernet,
    );

    if (!hasInternet) {
      emit(LecturesNoInternet());
      return;
    }

    emit(LecturesLoading());

    final result = await endLectureUseCase(lectureId);

    result.fold((error) => emit(LecturesError(error)), (response) {
      // إعادة تحميل المحاضرات بعد النجاح
      loadLectures();
    });
  }

  Future<void> reopenLecture(int lectureId) async {
    // التحقق من الإنترنت أولاً
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult.any(
      (result) =>
          result == ConnectivityResult.mobile || result == ConnectivityResult.wifi || result == ConnectivityResult.ethernet,
    );

    if (!hasInternet) {
      emit(LecturesNoInternet());
      return;
    }

    emit(LecturesLoading());

    final result = await reopenLectureUseCase(lectureId);

    result.fold((error) => emit(LecturesError(error)), (response) {
      // إعادة تحميل المحاضرات بعد النجاح
      loadLectures();
    });
  }
}
