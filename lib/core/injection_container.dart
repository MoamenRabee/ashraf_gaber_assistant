import 'package:get_it/get_it.dart';
import 'package:samy_mossad_assistant/core/database_helper.dart';
import 'package:samy_mossad_assistant/modules/auth/data_source/auth_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/auth/data_source/auth_remote_data_source_impl.dart';
import 'package:samy_mossad_assistant/modules/auth/data_source/auth_repository_impl.dart';
import 'package:samy_mossad_assistant/modules/auth/domain/repository/auth_repository.dart';
import 'package:samy_mossad_assistant/modules/auth/domain/usecases/login_usecase.dart';
import 'package:samy_mossad_assistant/modules/auth/domain/usecases/logout_usecase.dart';
import 'package:samy_mossad_assistant/modules/auth/presentation/cubit/auth_cubit.dart';
import 'package:samy_mossad_assistant/modules/center_exams/data_source/center_exams_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/center_exams/data_source/center_exams_remote_data_source_impl.dart';
import 'package:samy_mossad_assistant/modules/center_exams/data_source/center_exams_repository_impl.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/repository/center_exams_repository.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/usecases/get_center_exams_usecase.dart';
import 'package:samy_mossad_assistant/modules/center_exams/presentation/cubit/center_exams_cubit.dart';
import 'package:samy_mossad_assistant/modules/center_exams/data_source/exam_results_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/center_exams/data_source/exam_results_remote_data_source_impl.dart';
import 'package:samy_mossad_assistant/modules/center_exams/data_source/exam_results_repository_impl.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/repository/exam_results_repository.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/usecases/add_student_result_usecase.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/usecases/get_exam_results_usecase.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/usecases/get_exam_students_usecase.dart';
import 'package:samy_mossad_assistant/modules/comments/data_source/comments_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/comments/data_source/comments_remote_data_source_impl.dart';
import 'package:samy_mossad_assistant/modules/comments/data_source/comments_repository_impl.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/repository/comments_repository.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/usecases/get_comments_usecase.dart';
import 'package:samy_mossad_assistant/modules/comments/domain/usecases/reply_to_comment_usecase.dart';
import 'package:samy_mossad_assistant/modules/comments/presentation/cubit/comments_cubit.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/students_local_data_source.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/students_local_data_source_impl.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/students_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/students_remote_data_source_impl.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/students_repository_impl.dart';
import 'package:samy_mossad_assistant/modules/students/domain/repository/students_repository.dart';
import 'package:samy_mossad_assistant/modules/students/domain/usecases/get_filters_usecase.dart';
import 'package:samy_mossad_assistant/modules/students/domain/usecases/get_local_students_usecase.dart';
import 'package:samy_mossad_assistant/modules/students/domain/usecases/get_students_count_usecase.dart';
import 'package:samy_mossad_assistant/modules/students/domain/usecases/sync_students_usecase.dart';
import 'package:samy_mossad_assistant/modules/students/presentation/cubit/students_cubit.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/lectures_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/lectures_remote_data_source_impl.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/lectures_repository_impl.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/lectures_repository.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/create_lecture_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/end_lecture_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/get_lectures_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/reopen_lecture_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/lectures_cubit.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/lecture_students_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/lecture_students_remote_data_source_impl.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/lecture_students_repository_impl.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/lecture_students_repository.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/get_lecture_students_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/lecture_students_cubit.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/attendance_local_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/attendance_local_data_source_impl.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/attendance_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/attendance_remote_data_source_impl.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/attendance_repository_impl.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/attendance_repository.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/add_make_up_student_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/usecases/sync_attendance_usecase.dart';
import 'package:samy_mossad_assistant/modules/lectures/presentation/cubit/take_attendance_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ============ Auth Module ============
  // Cubits
  sl.registerFactory(() => AuthCubit(loginUseCase: sl(), logoutUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());

  // ============ Students Module ============
  // Cubits
  sl.registerFactory(
    () => StudentsCubit(
      syncStudentsUseCase: sl(),
      getLocalStudentsUseCase: sl(),
      getStudentsCountUseCase: sl(),
      getFiltersUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SyncStudentsUseCase(sl()));
  sl.registerLazySingleton(() => GetLocalStudentsUseCase(sl()));
  sl.registerLazySingleton(() => GetStudentsCountUseCase(sl()));
  sl.registerLazySingleton(() => GetFiltersUseCase(sl()));

  // Repository
  sl.registerLazySingleton<StudentsRepository>(() => StudentsRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<StudentsRemoteDataSource>(() => StudentsRemoteDataSourceImpl());
  sl.registerLazySingleton<StudentsLocalDataSource>(() => StudentsLocalDataSourceImpl(databaseHelper: sl()));

  // ============ Lectures Module ============
  // Cubits
  sl.registerFactory(
    () => LecturesCubit(
      getLecturesUseCase: sl(),
      endLectureUseCase: sl(),
      reopenLectureUseCase: sl(),
      createLectureUseCase: sl(),
      getFiltersUseCase: sl(),
    ),
  );
  sl.registerFactory(() => LectureStudentsCubit(sl()));
  sl.registerFactory(
    () => TakeAttendanceCubit(
      localDataSource: sl(),
      databaseHelper: sl(),
      syncAttendanceUseCase: sl(),
      addMakeUpStudentUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetLecturesUseCase(sl()));
  sl.registerLazySingleton(() => EndLectureUseCase(sl()));
  sl.registerLazySingleton(() => ReopenLectureUseCase(sl()));
  sl.registerLazySingleton(() => CreateLectureUseCase(sl()));
  sl.registerLazySingleton(() => GetLectureStudentsUseCase(sl()));
  sl.registerLazySingleton(() => SyncAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => AddMakeUpStudentUseCase(sl()));

  // Repository
  sl.registerLazySingleton<LecturesRepository>(() => LecturesRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<LectureStudentsRepository>(() => LectureStudentsRepositoryImpl(sl()));
  sl.registerLazySingleton<AttendanceRepository>(() => AttendanceRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<LecturesRemoteDataSource>(() => LecturesRemoteDataSourceImpl());
  sl.registerLazySingleton<LectureStudentsRemoteDataSource>(() => LectureStudentsRemoteDataSourceImpl());
  sl.registerLazySingleton<AttendanceLocalDataSource>(() => AttendanceLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<AttendanceRemoteDataSource>(() => AttendanceRemoteDataSourceImpl());

  // ============ Center Exams Module ============
  // Cubit
  sl.registerFactory(() => CenterExamsCubit(sl()));

  // Use case
  sl.registerLazySingleton(() => GetCenterExamsUseCase(sl()));
  sl.registerLazySingleton(() => GetExamResultsUseCase(sl()));
  sl.registerLazySingleton(() => GetExamStudentsUseCase(repository: sl()));
  sl.registerLazySingleton(() => AddStudentResultUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<CenterExamsRepository>(() => CenterExamsRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ExamResultsRepository>(() => ExamResultsRepositoryImpl(remoteDataSource: sl()));

  // Data source
  sl.registerLazySingleton<CenterExamsRemoteDataSource>(() => CenterExamsRemoteDataSourceImpl());
  sl.registerLazySingleton<ExamResultsRemoteDataSource>(() => ExamResultsRemoteDataSourceImpl());

  // ============ Comments Module ============
  // Cubit
  sl.registerFactory(() => CommentsCubit(getCommentsUseCase: sl(), replyToCommentUseCase: sl()));

  // Use case
  sl.registerLazySingleton(() => GetCommentsUseCase(repository: sl()));
  sl.registerLazySingleton(() => ReplyToCommentUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<CommentsRepository>(() => CommentsRepositoryImpl(remoteDataSource: sl()));

  // Data source
  sl.registerLazySingleton<CommentsRemoteDataSource>(() => CommentsRemoteDataSourceImpl());

  // ============ Core ============
  // Database
  sl.registerLazySingleton(() => DatabaseHelper());
}
