import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:samy_mossad_assistant/core/database_helper.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/attendance_local_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/local_attendance_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/sync_attendance_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/take_attendance_state.dart';
import 'package:samy_mossad_assistant/modules/students/domain/entities/student_entity.dart';

class TakeAttendanceCubit extends Cubit<TakeAttendanceState> {
  final AttendanceLocalDataSource localDataSource;
  final DatabaseHelper databaseHelper;
  final SyncAttendanceUseCase syncAttendanceUseCase;
  Timer? _debounceTimer;

  TakeAttendanceCubit({
    required this.localDataSource,
    required this.databaseHelper,
    required this.syncAttendanceUseCase,
  }) : super(TakeAttendanceInitial());

  Future<void> loadAttendance(int lectureId) async {
    try {
      final attendanceList = await localDataSource.getAttendanceByLecture(
        lectureId,
      );
      emit(TakeAttendanceLoaded(attendanceList: attendanceList));
    } catch (e) {
      emit(TakeAttendanceError('فشل في تحميل قائمة الحضور: ${e.toString()}'));
    }
  }

  Future<void> scanQRCode(String qrCode, LectureEntity lecture) async {
    try {
      // تحويل QR code إلى رقم
      final studentCode = int.tryParse(qrCode);
      if (studentCode == null) {
        emit(const TakeAttendanceStudentNotFound('كود QR غير صالح'));
        return;
      }

      // البحث عن الطالب بالكود
      final student = await localDataSource.getStudentByCode(studentCode);
      if (student == null) {
        emit(
          TakeAttendanceStudentNotFound(
            'لم يتم العثور على الطالب بالكود: $studentCode',
          ),
        );
        return;
      }

      // التحقق من أن الطالب من نفس الصف الدراسي
      if (student.classroom.id != lecture.classroom.id) {
        emit(
          TakeAttendanceStudentNotFound(
            'هذا الطالب ليس من ${lecture.classroom.name}\nالطالب من ${student.classroom.name}',
          ),
        );
        return;
      }

      // إضافة الحضور تلقائياً
      await _addAttendanceForStudent(student, lecture);
    } catch (e) {
      emit(TakeAttendanceError('خطأ في مسح QR: ${e.toString()}'));
    }
  }

  Future<void> searchStudents(String query, LectureEntity lecture) async {
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
          centerId: lecture.center.id,
        );
        emit(
          currentState.copyWith(searchResults: students, searchQuery: query),
        );
      } catch (e) {
        emit(TakeAttendanceError('فشل في البحث: ${e.toString()}'));
      }
    });
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

      final now = DateTime.now();
      final attendedAt =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

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
