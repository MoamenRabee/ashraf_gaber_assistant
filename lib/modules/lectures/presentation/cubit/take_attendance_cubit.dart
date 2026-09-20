import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:samy_mossad_assistant/core/database_helper.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/attendance_local_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/local_attendance_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/add_make_up_student_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/check_student_absence_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/sync_attendance_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/take_attendance_state.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/student_entity.dart';

class TakeAttendanceCubit extends Cubit<TakeAttendanceState> {
  final AttendanceLocalDataSource localDataSource;
  final DatabaseHelper databaseHelper;
  final SyncAttendanceUseCase syncAttendanceUseCase;
  final AddMakeUpStudentUseCase addMakeUpStudentUseCase;
  final CheckStudentAbsenceUseCase checkStudentAbsenceUseCase;
  Timer? _debounceTimer;

  /// تواريخ فحص الغياب (yyyy-MM-dd) لحد ما الشاشة تتقفل أو يتعمل reset
  final List<String> _checkDates = [];

  /// الطلاب اللي بنفحص غيابهم دلوقتي
  final List<String> _checkingAbsenceOf = [];

  static const Duration _absenceCheckTimeout = Duration(seconds: 20);

  TakeAttendanceCubit({
    required this.localDataSource,
    required this.databaseHelper,
    required this.syncAttendanceUseCase,
    required this.addMakeUpStudentUseCase,
    required this.checkStudentAbsenceUseCase,
  }) : super(TakeAttendanceInitial());

  Future<void> loadAttendance(int lectureId) async {
    try {
      final attendanceList = await localDataSource.getAttendanceByLecture(
        lectureId,
      );
      emit(
        TakeAttendanceLoaded(
          attendanceList: attendanceList,
          checkDates: List.of(_checkDates),
          checkingAbsenceOf: List.of(_checkingAbsenceOf),
        ),
      );
    } catch (e) {
      emit(TakeAttendanceError('فشل في تحميل قائمة الحضور: ${e.toString()}'));
    }
  }

  Future<void> scanQRCode(String qrCode, LectureEntity lecture) async {
    try {
      // تحويل QR code إلى رقم
      final studentCode = int.tryParse(qrCode);
      if (studentCode == null) {
        await _emitNotFound('كود QR غير صالح', lecture.id);
        return;
      }

      // البحث عن الطالب بالكود داخل سنتر المحاضرة فقط
      final student = await localDataSource.getStudentByCode(
        studentCode,
        centerId: lecture.center.id,
      );
      if (student == null) {
        // الطالب مش في السنتر ده، نشوف هل هو موجود في سنتر تاني
        final studentInOtherCenter = await localDataSource.getStudentByCode(
          studentCode,
        );
        if (studentInOtherCenter == null) {
          await _emitNotFound(
            'لم يتم العثور على الطالب بالكود: $studentCode',
            lecture.id,
          );
        } else {
          await _emitNotFound(
            'الطالب ${studentInOtherCenter.name} موجود لكن لا يمكن تسجيل حضوره هنا لأنه ليس في هذا السنتر\n'
            'سنتر الطالب: ${studentInOtherCenter.center.name}\n'
            'سنتر المحاضرة: ${lecture.center.name}',
            lecture.id,
          );
        }
        return;
      }

      // التحقق من أن الطالب من نفس الصف الدراسي
      if (student.classroom.id != lecture.classroom.id) {
        await _emitNotFound(
          'هذا الطالب ليس من ${lecture.classroom.name}\nالطالب من ${student.classroom.name}',
          lecture.id,
        );
        return;
      }

      // إضافة الحضور تلقائياً
      await _addAttendanceForStudent(student, lecture);
    } catch (e) {
      emit(TakeAttendanceError('خطأ في مسح QR: ${e.toString()}'));
    }
  }

  Future<void> _emitNotFound(String message, int lectureId) async {
    emit(TakeAttendanceStudentNotFound(message));
    await loadAttendance(lectureId);
  }

  /// [anyCenter] للتعويض: الطالب ممكن يكون من أي سنتر (بنفس صف المحاضرة).
  Future<void> searchStudents(
    String query,
    LectureEntity lecture, {
    bool anyCenter = false,
  }) async {
    if (state is! TakeAttendanceLoaded) return;

    final currentState = state as TakeAttendanceLoaded;

    // Cancel previous timer
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      emit(
        currentState.copyWith(
          searchResults: [],
          searchQuery: '',
          clearSearchResults: true,
        ),
      );
      return;
    }

    // Create new timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        // البحث مع فلترة بالصف الدراسي والسنتر
        final students = await databaseHelper.searchStudents(
          searchQuery: query,
          classroomId: lecture.classroom.id,
          centerId: anyCenter ? null : lecture.center.id,
        );
        // نستخدم أحدث state عشان مانرجّعش تواريخ الفحص أو القائمة لنسخة قديمة
        final latestState = state;
        if (latestState is! TakeAttendanceLoaded) return;
        emit(latestState.copyWith(searchResults: students, searchQuery: query));
      } catch (e) {
        emit(TakeAttendanceError('فشل في البحث: ${e.toString()}'));
      }
    });
  }

  List<String> get checkDates => List.unmodifiable(_checkDates);

  void addCheckDate(DateTime date) {
    final formatted =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    if (_checkDates.contains(formatted)) return;
    _checkDates
      ..add(formatted)
      ..sort();
    _emitCheckDates();
  }

  void removeCheckDate(String date) {
    _checkDates.remove(date);
    _emitCheckDates();
  }

  void resetCheckDates() {
    _checkDates.clear();
    _emitCheckDates();
  }

  void _emitCheckDates() {
    final currentState = state;
    if (currentState is TakeAttendanceLoaded) {
      emit(currentState.copyWith(checkDates: List.of(_checkDates)));
    }
  }

  void _emitCheckingAbsence() {
    final currentState = state;
    if (currentState is TakeAttendanceLoaded) {
      emit(
        currentState.copyWith(checkingAbsenceOf: List.of(_checkingAbsenceOf)),
      );
    }
  }

  /// فحص غياب الطالب في تواريخ الفحص (لو في تواريخ وفي إنترنت فقط).
  /// مابيوقفش تسجيل الحضور، وأثناء الفحص بيظهر مؤشر تحميل في الشاشة.
  Future<void> _checkAbsence(
    StudentEntity student,
    LectureEntity lecture,
  ) async {
    if (_checkDates.isEmpty) return;

    // مفيش إنترنت: مابنعملش فحص خالص
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) return;
    } catch (_) {
      return;
    }
    if (isClosed) return;

    _checkingAbsenceOf.add(student.name);
    _emitCheckingAbsence();

    TakeAttendanceState? resultState;
    try {
      final result = await checkStudentAbsenceUseCase(
        dates: List.of(_checkDates),
        classroomId: lecture.classroom.id,
        centerId: lecture.center.id,
        studentCode: student.studentId,
      ).timeout(_absenceCheckTimeout);

      resultState = result.fold<TakeAttendanceState?>(
        (error) => TakeAttendanceAbsenceCheckFailed(
          'تعذر فحص غياب ${student.name}: $error',
        ),
        (absence) => absence.hasAbsence
            ? TakeAttendanceAbsenceFound(student, absence)
            : null,
      );
    } on TimeoutException {
      resultState = TakeAttendanceAbsenceCheckFailed(
        'تعذر فحص غياب ${student.name}: انتهت مهلة الاتصال',
      );
    } catch (_) {
      resultState = TakeAttendanceAbsenceCheckFailed(
        'تعذر فحص غياب ${student.name}',
      );
    }

    _checkingAbsenceOf.remove(student.name);
    if (isClosed) return;

    if (resultState != null) emit(resultState);
    // بيرجّع Loaded بدون مؤشر التحميل
    await loadAttendance(lecture.id);
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    final currentState = state;
    if (currentState is! TakeAttendanceLoaded) return;

    emit(
      currentState.copyWith(
        searchResults: [],
        searchQuery: '',
        clearSearchResults: true,
      ),
    );
  }

  /// تسجيل حضور طالب بيعوض في المحاضرة دي بدل محاضرة تانية.
  /// بيتبعت للسيرفر فوراً وبعد نجاحه بيتسجل في الحضور على الجهاز (كتعويض ومتزامن).
  Future<void> addMakeUpStudent(
    StudentEntity student,
    LectureEntity lecture, {
    String? notes,
  }) async {
    try {
      final currentAttendance = await localDataSource.getAttendanceByLecture(
        lecture.id,
      );
      if (currentAttendance.any((a) => a.studentCode == student.studentId)) {
        emit(const TakeAttendanceError('هذا الطالب مسجل حضوره بالفعل'));
        await loadAttendance(lecture.id);
        return;
      }

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        emit(const TakeAttendanceError('لا يوجد اتصال بالإنترنت'));
        await loadAttendance(lecture.id);
        return;
      }

      emit(TakeAttendanceLoading());

      final result = await addMakeUpStudentUseCase(
        lectureId: lecture.id,
        studentCode: student.studentId,
        notes: notes,
      );

      final error = result.fold((error) => error, (_) => null);
      if (error != null) {
        emit(TakeAttendanceError(error));
        await loadAttendance(lecture.id);
        return;
      }

      // السيرفر سجله، نسجله على الجهاز كمان عشان يظهر في القائمة.
      // isSynced = true عشان المزامنة العادية ماتبعتوش تاني كحضور عادي.
      await localDataSource.addAttendance(
        LocalAttendanceEntity(
          lectureId: lecture.id,
          lectureDescription: lecture.description,
          studentId: student.id,
          studentName: student.name,
          studentCode: student.studentId,
          attendedAt: _formatNow(),
          isSynced: true,
          isMakeUp: true,
        ),
      );

      emit(TakeAttendanceSuccess('تم تسجيل تعويض ${student.name}'));
      await loadAttendance(lecture.id);
    } catch (e) {
      emit(TakeAttendanceError('فشل في تسجيل التعويض: ${e.toString()}'));
      await loadAttendance(lecture.id);
    }
  }

  String _formatNow() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  Future<void> addAttendance(
    StudentEntity student,
    LectureEntity lecture,
  ) async {
    await _addAttendanceForStudent(student, lecture);
  }

  Future<void> _addAttendanceForStudent(
    StudentEntity student,
    LectureEntity lecture,
  ) async {
    try {
      // التحقق من أن الطالب من نفس الصف الدراسي
      if (student.classroom.id != lecture.classroom.id) {
        emit(
          TakeAttendanceError(
            'لا يمكن تسجيل الحضور\nالطالب من ${student.classroom.name}\nالمحاضرة لـ ${lecture.classroom.name}',
          ),
        );
        if (state is TakeAttendanceLoaded) {
          await loadAttendance(lecture.id);
        }
        return;
      }

      if (state is! TakeAttendanceLoaded) {
        await loadAttendance(lecture.id);
      }

      final currentState = state as TakeAttendanceLoaded;

      // Check if student already attended
      final alreadyAttended = currentState.attendanceList.any(
        (attendance) => attendance.studentCode == student.studentId,
      );

      if (alreadyAttended) {
        emit(const TakeAttendanceError('هذا الطالب مسجل حضوره بالفعل'));
        // Reload to show current state
        await loadAttendance(lecture.id);
        return;
      }

      final attendedAt = _formatNow();

      final attendance = LocalAttendanceEntity(
        lectureId: lecture.id,
        lectureDescription: lecture.description,
        studentId: student.id,
        studentName: student.name,
        studentCode: student.studentId,
        attendedAt: attendedAt,
        isSynced: false,
      );

      await localDataSource.addAttendance(attendance);
      emit(TakeAttendanceSuccess('تم تسجيل حضور ${student.name}'));

      // Reload attendance list
      await loadAttendance(lecture.id);

      // مش بنستنى الفحص عشان شاشة الـ QR ماتتأخرش في الرجوع
      unawaited(_checkAbsence(student, lecture));
    } catch (e) {
      emit(TakeAttendanceError('فشل في إضافة الحضور: ${e.toString()}'));
      if (state is TakeAttendanceLoaded) {
        await loadAttendance(lecture.id);
      }
    }
  }

  Future<void> deleteAttendance(int id, int lectureId) async {
    try {
      await localDataSource.deleteAttendance(id);
      emit(const TakeAttendanceSuccess('تم حذف الحضور'));

      // Reload attendance list
      await loadAttendance(lectureId);
    } catch (e) {
      emit(TakeAttendanceError('فشل في حذف الحضور: ${e.toString()}'));
      if (state is TakeAttendanceLoaded) {
        await loadAttendance(lectureId);
      }
    }
  }

  Future<void> syncAttendance(int lectureId) async {
    try {
      // فحص الاتصال بالإنترنت
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        emit(const TakeAttendanceError('لا يوجد اتصال بالإنترنت'));
        await loadAttendance(lectureId);
        return;
      }

      final unsyncedAttendance = await localDataSource.getUnsyncedAttendance(
        lectureId,
      );

      if (unsyncedAttendance.isEmpty) {
        emit(const TakeAttendanceSuccess('جميع السجلات متزامنة'));
        await loadAttendance(lectureId);
        return;
      }

      // عرض رسالة جاري المزامنة
      emit(TakeAttendanceLoading());

      // المزامنة مع السيرفر
      final result = await syncAttendanceUseCase(lectureId, unsyncedAttendance);

      result.fold(
        (error) {
          emit(TakeAttendanceError('فشل في المزامنة: $error'));
        },
        (_) {
          emit(
            TakeAttendanceSuccess(
              'تم مزامنة ${unsyncedAttendance.length} سجل بنجاح',
            ),
          );
        },
      );

      await loadAttendance(lectureId);
    } catch (e) {
      emit(TakeAttendanceError('فشل في المزامنة: ${e.toString()}'));
      await loadAttendance(lectureId);
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
