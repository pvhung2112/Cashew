import 'dart:async';
import 'database_helper.dart';
import '../struct/studyGoal.dart';

/// Data Access Object cho Mục tiêu học tập (DAO Layer)
class GoalDao {
  final AppDatabase _db;

  GoalDao({AppDatabase? database}) : _db = database ?? AppDatabase();

  Future<void> insert(StudyGoal goal) async {
    await _db.insertGoal(goal);
  }

  Future<void> update(StudyGoal goal) async {
    await _db.updateGoal(goal);
  }

  Future<void> delete(String id) async {
    await _db.deleteGoal(id);
  }

  List<StudyGoal> getAll() {
    return _db.getAllGoals();
  }

  Stream<List<StudyGoal>> watchAll() {
    return _db.watchAllGoals();
  }
}
