import 'package:dartz/dartz.dart';
import 'package:samy_mossad_assistant/modules/center_exams/data_source/center_exams_remote_data_source.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/entities/center_exam_entity.dart';
import 'package:samy_mossad_assistant/modules/center_exams/domain/repository/center_exams_repository.dart';

class CenterExamsRepositoryImpl implements CenterExamsRepository {
  final CenterExamsRemoteDataSource remoteDataSource;

  CenterExamsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, List<CenterExamEntity>>> getCenterExams() async {
    try {
      final exams = await remoteDataSource.getCenterExams();
      return Right(exams);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
