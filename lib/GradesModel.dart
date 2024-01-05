import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'Grade.dart';

class GradesModel {
  Future<Database> database() async {
    return openDatabase(
      join(await getDatabasesPath(), 'grades_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE grades(id INTEGER PRIMARY KEY, sid TEXT, grade TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<List<Grade>> getAllGrades() async {
    final db = await database();
    final List<Map<String, dynamic>> maps = await db.query('grades');
    return List.generate(maps.length, (i) {
      return Grade(
        id: maps[i]['id'],
        sid: maps[i]['sid'],
        grade: maps[i]['grade'],
      );
    });
  }

  Future<void> insertGrade(Grade grade) async {
    final db = await database();
    await db.insert(
      'grades',
      grade.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateGrade(Grade grade) async {
    final db = await database();
    await db.update(
      'grades',
      grade.toMap(),
      where: "id = ?",
      whereArgs: [grade.id],
    );
  }

  Future<void> deleteGradeById(int id) async {
    final db = await database();
    await db.delete(
      'grades',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}