import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/create_lecture_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/end_lecture_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/get_lectures_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/reopen_lecture_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/lectures_state.dart';
import 'package:samy_mossad_assistant/modules/students/domain/usecases/get_filters_usecase.dart';

class LecturesCubit extends Cubit<LecturesState> {
  final GetLecturesUseCase getLecturesUseCase;
  final EndLectureUseCase endLectureUseCase;
  final ReopenLectureUseCase reopenLectureUseCase;
  final CreateLectureUseCase createLectureUseCase;
  final GetFiltersUseCase getFiltersUseCase;

  LecturesCubit({
    required this.getLecturesUseCase,
    required this.endLectureUseCase,
    required this.reopenLectureUseCase,
    required this.createLectureUseCase,
    required this.getFiltersUseCase,
  }) : super(LecturesInitial());

  /// [centerId] و[classroomId] لو اتحددوا بننقل المستخدم لسنتر وصف معينين بعد التحميل
  /// (مثلاً بعد إضافة محاضرة)، وإلا بنحتفظ بالاختيار الحالي.
  Future<void> loadLectures({int? centerId, int? classroomId}) async {
    // الاحتفاظ بالسنتر والصف المختارين عند التحديث
    final current = state;
    final previous = current is LecturesLoaded ? current : null;

    // التحقق من الإنترنت أولاً
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );

    if (!hasInternet) {
      emit(LecturesNoInternet());
      return;
    }

    emit(LecturesLoading());

    final result = await getLecturesUseCase();

    result.fold(
      (error) => emit(LecturesError(error)),
      (lectures) => emit(
        _buildLoaded(
          lectures,
          centerId: centerId ?? previous?.selectedCenterId,
          classroomId: centerId != null ? classroomId : previous?.selectedClassroomId,
          status: centerId != null ? null : previous?.selectedStatus,
          date: centerId != null ? null : previous?.selectedDate,
        ),
      ),
    );
  }

  /// السناتر والصفوف المتاحة في فورم إضافة محاضرة: من الطلاب المحفوظين على الجهاز
  /// ومعاهم اللي ظاهرين في المحاضرات الحالية.
  Future<({List<Map<String, dynamic>> centers, List<Map<String, dynamic>> classrooms})> getLectureFormOptions() async {
    final centers = <int, String>{};
    final classrooms = <int, String>{};

    final filters = await getFiltersUseCase();
    filters.fold((_) {}, (data) {
      for (final center in data['centers'] ?? const <Map<String, dynamic>>[]) {
        centers[center['id'] as int] = center['name'] as String;
      }
      for (final classroom in data['classrooms'] ?? const <Map<String, dynamic>>[]) {
        classrooms[classroom['id'] as int] = classroom['name'] as String;
      }
    });

    final current = state;
    if (current is LecturesLoaded) {
      for (final lecture in current.lectures) {
        centers[lecture.center.id] = lecture.center.name;
        classrooms[lecture.classroom.id] = lecture.classroom.name;
      }
    }

    List<Map<String, dynamic>> toOptions(Map<int, String> items) =>
        items.entries.map((e) => {'id': e.key, 'name': e.value}).toList();

    return (centers: toOptions(centers), classrooms: toOptions(classrooms));
  }

  /// بيرجّع رسالة الخطأ لو فشل، أو null لو نجح (وبيحمّل المحاضرات ويفتح السنتر والصف الجداد).
  Future<String?> createLecture({
    required String description,
    required int classroomId,
    required int centerId,
    required String date,
    required String time,
  }) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );
    if (!hasInternet) return 'لا يوجد اتصال بالإنترنت';

    final result = await createLectureUseCase(
      description: description,
      classroomId: classroomId,
      centerId: centerId,
      date: date,
      time: time,
    );

    final error = result.fold((error) => error, (_) => null);
    if (error != null) return error;

    await loadLectures(centerId: centerId, classroomId: classroomId);
    return null;
  }

  void selectCenter(int centerId) {
    final currentState = state;
    if (currentState is! LecturesLoaded) return;

    emit(_buildLoaded(currentState.lectures, centerId: centerId));
  }

  void selectClassroom(int classroomId) {
    final currentState = state;
    if (currentState is! LecturesLoaded) return;

    emit(_buildLoaded(currentState.lectures, centerId: currentState.selectedCenterId, classroomId: classroomId));
  }

  /// الرجوع خطوة: من المحاضرات للصفوف، ومن الصفوف للسناتر.
  void goBack() {
    final currentState = state;
    if (currentState is! LecturesLoaded) return;

    emit(
      _buildLoaded(
        currentState.lectures,
        centerId: currentState.selectedClassroomId != null ? currentState.selectedCenterId : null,
      ),
    );
  }

  /// فلتر الحالة والتاريخ داخل السنتر والصف المختارين.
  void applyFilters({LectureStatus? status, String? date}) {
    final currentState = state;
    if (currentState is! LecturesLoaded) return;

    emit(
      _buildLoaded(
        currentState.lectures,
        centerId: currentState.selectedCenterId,
        classroomId: currentState.selectedClassroomId,
        status: status,
        date: date,
      ),
    );
  }

  LecturesLoaded _buildLoaded(
    List<LectureEntity> lectures, {
    int? centerId,
    int? classroomId,
    LectureStatus? status,
    String? date,
  }) {
    final centers = _summarize(lectures, (l) => (id: l.center.id, name: l.center.name));

    // لو السنتر أو الصف مش موجودين في البيانات (بعد تحديث مثلاً) نرجع للمستوى الأعلى
    if (!centers.any((c) => c['id'] == centerId)) {
      centerId = null;
    }
    final centerLectures = centerId == null
        ? <LectureEntity>[]
        : lectures.where((l) => l.center.id == centerId).toList();

    final classrooms = _summarize(centerLectures, (l) => (id: l.classroom.id, name: l.classroom.name));
    if (!classrooms.any((c) => c['id'] == classroomId)) {
      classroomId = null;
    }

    final filtered = classroomId == null
        ? <LectureEntity>[]
        : centerLectures.where((lecture) {
            if (lecture.classroom.id != classroomId) return false;
            if (status != null && lecture.status != status) return false;
            if (date != null && lecture.date != date) return false;
            return true;
          }).toList();

    return LecturesLoaded(
      lectures: lectures,
      filteredLectures: filtered,
      centers: centers,
      classrooms: classrooms,
      selectedCenterId: centerId,
      selectedClassroomId: classroomId,
      selectedStatus: classroomId == null ? null : status,
      selectedDate: classroomId == null ? null : date,
    );
  }

  List<Map<String, dynamic>> _summarize(
    List<LectureEntity> lectures,
    ({int id, String name}) Function(LectureEntity) pick,
  ) {
    final items = <int, Map<String, dynamic>>{};
    for (final lecture in lectures) {
      final key = pick(lecture);
      final item = items.putIfAbsent(key.id, () => {'id': key.id, 'name': key.name, 'count': 0});
      item['count'] = (item['count'] as int) + 1;
    }
    return items.values.toList();
  }

  Future<void> endLecture(int lectureId) async {
    // التحقق من الإنترنت أولاً
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
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
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
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
