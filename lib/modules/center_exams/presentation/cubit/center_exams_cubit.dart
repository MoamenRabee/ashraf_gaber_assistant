import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/center_exam_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/usecases/get_center_exams_usecase.dart';
import 'package:samy_mossad_assistant/modules/center_exams/presentation/cubit/center_exams_state.dart';

class CenterExamsCubit extends Cubit<CenterExamsState> {
  final GetCenterExamsUseCase getCenterExamsUseCase;

  CenterExamsCubit(this.getCenterExamsUseCase) : super(CenterExamsInitial());

  Future<void> loadCenterExams() async {
    emit(CenterExamsLoading());

    // Check internet connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      emit(CenterExamsNoInternet());
      return;
    }

    final result = await getCenterExamsUseCase();

    result.fold(
      (error) => emit(CenterExamsError(error)),
      (exams) => emit(CenterExamsLoaded(allExams: exams, filteredExams: exams)),
    );
  }

  void filterExams({int? classroomId, int? centerId, String? searchQuery}) {
    if (state is! CenterExamsLoaded) return;

    final currentState = state as CenterExamsLoaded;
    List<CenterExamEntity> filtered = currentState.allExams;

    // Filter by classroom
    if (classroomId != null) {
      filtered = filtered
          .where((exam) => exam.classroomId == classroomId)
          .toList();
    }

    // Filter by center
    if (centerId != null) {
      filtered = filtered.where((exam) => exam.centerId == centerId).toList();
    }

    // Filter by search query
    final query = searchQuery ?? currentState.searchQuery;
    if (query.isNotEmpty) {
      filtered = filtered
          .where(
            (exam) => exam.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

    emit(
      currentState.copyWith(
        filteredExams: filtered,
        selectedClassroomId: classroomId,
        selectedCenterId: centerId,
        searchQuery: query,
      ),
    );
  }

  void clearFilters() {
    if (state is! CenterExamsLoaded) return;
    final currentState = state as CenterExamsLoaded;
    emit(
      CenterExamsLoaded(
        allExams: currentState.allExams,
        filteredExams: currentState.allExams,
        searchQuery: '',
      ),
    );
  }

  void searchExams(String query) {
    if (state is! CenterExamsLoaded) return;
    final currentState = state as CenterExamsLoaded;
    filterExams(
      classroomId: currentState.selectedClassroomId,
      centerId: currentState.selectedCenterId,
      searchQuery: query,
    );
  }

  List<Map<String, dynamic>> getClassrooms() {
    if (state is! CenterExamsLoaded) return [];
    final currentState = state as CenterExamsLoaded;

    final classrooms = <Map<String, dynamic>>[];
    final seenIds = <int>{};

    for (var exam in currentState.allExams) {
      if (!seenIds.contains(exam.classroomId)) {
        classrooms.add({'id': exam.classroomId, 'name': exam.classroomName});
        seenIds.add(exam.classroomId);
      }
    }

    return classrooms;
  }

  List<Map<String, dynamic>> getCenters() {
    if (state is! CenterExamsLoaded) return [];
    final currentState = state as CenterExamsLoaded;

    final centers = <Map<String, dynamic>>[];
    final seenIds = <int>{};

    for (var exam in currentState.allExams) {
      if (!seenIds.contains(exam.centerId)) {
        centers.add({'id': exam.centerId, 'name': exam.centerName});
        seenIds.add(exam.centerId);
      }
    }

    return centers;
  }
}
