import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/attendance_local_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/attendance_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/local_attendance_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/student_absence_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final AttendanceLocalDataSource localDataSource;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<String, void>> syncAttendance(
    int lectureId,
    List<LocalAttendanceEntity> attendanceList,
  ) async {
    try {
      // تحويل البيانات للصيغة المطلوبة
      final students = attendanceList.map((attendance) {
        final dateTime = DateTime.parse(attendance.attendedAt);
        return {
          'student_id': attendance.studentCode,
          'status': 'attended', // جميعهم حاضرين لأننا نسجل الحضور فقط
          'attended_date':
              '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}',
          'attended_time':
              '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}',
        };
      }).toList();

      // إرسال البيانات للسيرفر
      await remoteDataSource.syncAttendance(lectureId, students);

      // تحديث السجلات في قاعدة البيانات المحلية كمتزامنة
      for (var attendance in attendanceList) {
        if (attendance.id != null && !attendance.isSynced) {
          await localDataSource.markAttendanceAsSynced(attendance.id!);
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> addMakeUpStudent({
    required int lectureId,
    required int studentCode,
    String? notes,
  }) async {
    try {
      await remoteDataSource.addMakeUpStudent(
        lectureId: lectureId,
        studentCode: studentCode,
        notes: notes,
      );
      return const Right(null);
    } catch (e) {
      return Left(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, StudentAbsenceEntity>> checkStudentAbsence({
    required List<String> dates,
    required int classroomId,
    required int centerId,
    required int studentCode,
  }) async {
    try {
      final result = await remoteDataSource.checkStudentAbsence(
        dates: dates,
        classroomId: classroomId,
        centerId: centerId,
        studentCode: studentCode,
      );
      return Right(result);
    } catch (e) {
      return Left(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
