import 'dart:developer';
import 'package:path/path.dart';
import 'package:samy_mossad_assistant/modules/students/data_source/models/student_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'students.db';
  static const int _databaseVersion = 3;

  static const String tableStudents = 'students';
  static const String tableAttendance = 'attendance';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), _databaseName);
    log('Database path: $path');

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableStudents (
        id INTEGER PRIMARY KEY,
        student_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        parent_phone TEXT NOT NULL,
        classroom_id INTEGER NOT NULL,
        classroom_name TEXT NOT NULL,
        center_id INTEGER NOT NULL,
        center_name TEXT NOT NULL,
        center_address TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAttendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lecture_id INTEGER NOT NULL,
        lecture_description TEXT NOT NULL,
        student_id INTEGER NOT NULL,
        student_name TEXT NOT NULL,
        student_code INTEGER NOT NULL,
        attended_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        is_make_up INTEGER NOT NULL DEFAULT 0
      )
    ''');
    log('Database tables created');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE $tableAttendance (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          lecture_id INTEGER NOT NULL,
          lecture_description TEXT NOT NULL,
          student_id INTEGER NOT NULL,
          student_name TEXT NOT NULL,
          student_code INTEGER NOT NULL,
          attended_at TEXT NOT NULL,
          is_synced INTEGER NOT NULL DEFAULT 0
        )
      ''');
      log('Attendance table created during upgrade');
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE $tableAttendance ADD COLUMN is_make_up INTEGER NOT NULL DEFAULT 0',
      );
      log('is_make_up column added to attendance table');
    }
  }

  Future<void> insertStudents(List<StudentModel> students) async {
    final db = await database;

    // حذف البيانات القديمة
    await db.delete(tableStudents);

    // إدراج البيانات الجديدة
    final batch = db.batch();
    for (var student in students) {
      batch.insert(
        tableStudents,
        student.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    log('Inserted ${students.length} students');
  }

  Future<List<StudentModel>> getAllStudents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableStudents);

    return List.generate(maps.length, (i) {
      return StudentModel.fromDatabase(maps[i]);
    });
  }

  Future<List<StudentModel>> searchStudents({
    String? searchQuery,
    int? classroomId,
    int? centerId,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    log(
      'Search: query=$searchQuery, classroomId=$classroomId, centerId=$centerId',
    );

    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause =
          '(name LIKE ? OR phone LIKE ? OR parent_phone LIKE ? OR CAST(student_id AS TEXT) LIKE ?)';
      whereArgs = [
        '%$searchQuery%',
        '%$searchQuery%',
        '%$searchQuery%',
        '%$searchQuery%',
      ];
    }

    if (classroomId != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND classroom_id = ?';
      } else {
        whereClause = 'classroom_id = ?';
      }
      whereArgs.add(classroomId);
    }

    if (centerId != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND center_id = ?';
      } else {
        whereClause = 'center_id = ?';
      }
      whereArgs.add(centerId);
    }

    log('Search WHERE: $whereClause with args: $whereArgs');

    final List<Map<String, dynamic>> maps = await db.query(
      tableStudents,
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );

    log('Search returned ${maps.length} students');

    return List.generate(maps.length, (i) {
      return StudentModel.fromDatabase(maps[i]);
    });
  }

  Future<int> getStudentsCount() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableStudents'),
    );
    return count ?? 0;
  }

  Future<List<StudentModel>> getStudentsWithoutExamResult({
    required int classroomId,
    required int centerId,
    required List<int> studentIdsWithResults,
    String? searchQuery,
  }) async {
    final db = await database;

    String whereClause = 'classroom_id = ? AND center_id = ?';
    List<dynamic> whereArgs = [classroomId, centerId];

    // Exclude students who already have results
    if (studentIdsWithResults.isNotEmpty) {
      final placeholders = List.filled(
        studentIdsWithResults.length,
        '?',
      ).join(',');
      whereClause += ' AND student_id NOT IN ($placeholders)';
      whereArgs.addAll(studentIdsWithResults);
    }

    // Add search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause +=
          ' AND (name LIKE ? OR phone LIKE ? OR parent_phone LIKE ? OR CAST(student_id AS TEXT) LIKE ?)';
      whereArgs.addAll([
        '%$searchQuery%',
        '%$searchQuery%',
        '%$searchQuery%',
        '%$searchQuery%',
      ]);
    }

    log(
      'getStudentsWithoutExamResult WHERE: $whereClause with args: $whereArgs',
    );

    final List<Map<String, dynamic>> maps = await db.query(
      tableStudents,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );

    log('Found ${maps.length} students without results');

    return List.generate(maps.length, (i) {
      return StudentModel.fromDatabase(maps[i]);
    });
  }

  Future<List<Map<String, dynamic>>> getAllClassrooms() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT classroom_id as id, classroom_name as name FROM $tableStudents ORDER BY classroom_name',
    );
    return maps;
  }

  Future<List<Map<String, dynamic>>> getAllCenters() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT center_id as id, center_name as name FROM $tableStudents ORDER BY center_name',
    );
    return maps;
  }

  Future<void> clearAllStudents() async {
    final db = await database;
    await db.delete(tableStudents);
    log('Cleared all students');
  }

  // ============ Attendance Methods ============

  Future<int> insertAttendance(Map<String, dynamic> attendance) async {
    final db = await database;
    final id = await db.insert(
      tableAttendance,
      attendance,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    log('Inserted attendance with id: $id');
    return id;
  }

  Future<List<Map<String, dynamic>>> getAttendanceByLecture(
    int lectureId,
  ) async {
    final db = await database;
    final maps = await db.query(
      tableAttendance,
      where: 'lecture_id = ?',
      whereArgs: [lectureId],
      orderBy: 'attended_at DESC',
    );
    return maps;
  }

  Future<int> deleteAttendance(int id) async {
    final db = await database;
    final count = await db.delete(
      tableAttendance,
      where: 'id = ?',
      whereArgs: [id],
    );
    log('Deleted attendance with id: $id');
    return count;
  }

  Future<List<Map<String, dynamic>>> getUnsyncedAttendance(
    int lectureId,
  ) async {
    final db = await database;
    final maps = await db.query(
      tableAttendance,
      where: 'lecture_id = ? AND is_synced = 0',
      whereArgs: [lectureId],
    );
    return maps;
  }

  Future<int> markAttendanceAsSynced(int id) async {
    final db = await database;
    final count = await db.update(
      tableAttendance,
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    log('Marked attendance $id as synced');
    return count;
  }

  Future<StudentModel?> getStudentByCode(
    int studentCode, {
    int? centerId,
  }) async {
    final db = await database;
    final maps = await db.query(
      tableStudents,
      where: centerId != null
          ? 'student_id = ? AND center_id = ?'
          : 'student_id = ?',
      whereArgs: centerId != null ? [studentCode, centerId] : [studentCode],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return StudentModel.fromDatabase(maps.first);
  }

  Future<void> clearAllAttendance() async {
    final db = await database;
    await db.delete(tableAttendance);
    log('Cleared all attendance');
  }
}
