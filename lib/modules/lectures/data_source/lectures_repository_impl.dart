import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/lectures/data_source/lectures_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/entities/lecture_entity.dart';
import 'package:samy_mossad_assistant/modules/lectures/domain/repository/lectures_repository.dart';

class LecturesRepositoryImpl implements LecturesRepository {
  final LecturesRemoteDataSource remoteDataSource;

  LecturesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<LectureEntity>>> getLectures() async {
    try {
      final lectures = await remoteDataSource.getLectures();
      return Right(lectures);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> endLecture(int lectureId) async {
    try {
      final result = await remoteDataSource.endLecture(lectureId);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, Map<String, dynamic>>> reopenLecture(int lectureId) async {
    try {
      final result = await remoteDataSource.reopenLecture(lectureId);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
