import 'dart:async';
import 'dart:convert';
import '../struct/studyDocument.dart';
import '../struct/studyCourse.dart';
import '../struct/studyGoal.dart';
import '../struct/studySyncClient.dart';

/// Database Engine cục bộ đóng vai trò Single Source of Truth theo kiến trúc Local-First của Cashew.
/// Cung cấp Reactive Streams (tương đương Drift .watch() trong Cashew) cho toàn bộ hệ thống UI.
class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal() {
    _initSeedData();
  }

  // Bộ nhớ lưu trữ dữ liệu cục bộ
  final Map<String, StudyDocument> _documents = {};
  final Map<String, Course> _courses = {};
  final Map<String, StudyGoal> _goals = {};

  // Các Reactive Stream Controllers (Drift-like reactive streams)
  final _documentsStreamController = StreamController<List<StudyDocument>>.broadcast();
  final _coursesStreamController = StreamController<List<Course>>.broadcast();
  final _goalsStreamController = StreamController<List<StudyGoal>>.broadcast();

  Stream<List<StudyDocument>> watchAllDocuments() => _documentsStreamController.stream;
  Stream<List<Course>> watchAllCourses() => _coursesStreamController.stream;
  Stream<List<StudyGoal>> watchAllGoals() => _goalsStreamController.stream;

  void _notifyDocuments() {
    final docs = _documents.values.toList()
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
    _documentsStreamController.add(List.unmodifiable(docs));

    // Cập nhật số lượng tài liệu chưa đồng bộ cho Sync Client
    final unsynced = docs.where((d) => !d.isSynced).length;
    SyncClient().updatePendingCount(unsynced);
  }

  void _notifyCourses() {
    final list = _courses.values.toList()
      ..sort((a, b) => a.code.compareTo(b.code));
    _coursesStreamController.add(List.unmodifiable(list));
  }

  void _notifyGoals() {
    final list = _goals.values.toList();
    _goalsStreamController.add(List.unmodifiable(list));
  }

  /// Khởi tạo dữ liệu mẫu ban đầu để kiểm thử hệ thống
  void _initSeedData() {
    // 1. Các môn học mẫu
    final c1 = Course(
      id: 'c_ktpm',
      code: 'SE301',
      name: 'Kiến trúc Phần mềm',
      lecturer: 'TS. Nguyễn Văn A',
      credits: 3,
      colorValue: 0xFF2A75D3, // Xanh biển
      description: 'Nghiên cứu các mẫu thiết kế và kiến trúc Local-First, Clean Architecture',
    );
    final c2 = Course(
      id: 'c_flutter',
      code: 'CS402',
      name: 'Phát triển Ứng dụng Di động',
      lecturer: 'ThS. Trần Thị B',
      credits: 4,
      colorValue: 0xFF009688, // Xanh ngọc
      description: 'Lập trình ứng dụng đa nền tảng với Flutter & Dart',
    );
    final c3 = Course(
      id: 'c_db',
      code: 'CS205',
      name: 'Cơ sở Dữ liệu Phân tán',
      lecturer: 'PGS. Lê Hoàng C',
      credits: 3,
      colorValue: 0xFFE65100, // Cam đất
      description: 'Lưu trữ NoSQL, SQLite và cơ chế đồng bộ đa thiết bị',
    );

    _courses[c1.id] = c1;
    _courses[c2.id] = c2;
    _courses[c3.id] = c3;

    // 2. Các tài liệu học tập mẫu
    final now = DateTime.now();
    final d1 = StudyDocument(
      id: 'doc_1',
      title: 'Slide Chương 4: Phân tích Kiến trúc Cashew & Local-First',
      courseId: c1.id,
      type: DocumentType.lecture,
      status: DocumentStatus.completed,
      description: 'Tài liệu chi tiết về phân tầng App Experience, Finance Features, Data & Storage',
      fileUrl: 'https://docs.cashewapp.web.app/architecture-ch4.pdf',
      tags: ['KTPM', 'Cashew', 'Local-First'],
      createdAt: now.subtract(const Duration(days: 4)),
      isPinned: true,
      isSynced: true,
    );

    final d2 = StudyDocument(
      id: 'doc_2',
      title: 'Bài tập lớn: Thiết kế mô-đun Sync Engine cho Quản lý Tài liệu',
      courseId: c1.id,
      type: DocumentType.exercise,
      status: DocumentStatus.inProgress,
      description: 'Yêu cầu phân tách rõ DAO, Service, Presentation và viết Unit Test',
      fileUrl: 'https://github.com/pvhung2112/cashew-assignment.docx',
      tags: ['Bài tập lớn', 'Deadline', 'TH1'],
      deadline: now.add(const Duration(days: 2)),
      createdAt: now.subtract(const Duration(days: 2)),
      isPinned: true,
      isSynced: false,
    );

    final d3 = StudyDocument(
      id: 'doc_3',
      title: 'Giáo trình Flutter Cookbook & Reactive State with Drift',
      courseId: c2.id,
      type: DocumentType.reference,
      status: DocumentStatus.todo,
      description: 'Sách hướng dẫn sử dụng Drift ORM SQLite trên Flutter',
      fileUrl: 'https://drift.simonbinder.eu/docs/drift-guide.pdf',
      tags: ['Flutter', 'Drift', 'SQLite'],
      createdAt: now.subtract(const Duration(days: 1)),
      isPinned: false,
      isSynced: true,
    );

    final d4 = StudyDocument(
      id: 'doc_4',
      title: 'Bài tập thực hành 2: Viết truy vấn lọc tài liệu theo khóa ngoại Course',
      courseId: c3.id,
      type: DocumentType.exercise,
      status: DocumentStatus.todo,
      description: 'Thực hành viết DAO query và filter logic',
      fileUrl: 'https://drive.google.com/bt2_csdl.pdf',
      tags: ['CSDL', 'Query', 'DAO'],
      deadline: now.add(const Duration(days: 5)),
      createdAt: now,
      isPinned: false,
      isSynced: false,
    );

    _documents[d1.id] = d1;
    _documents[d2.id] = d2;
    _documents[d3.id] = d3;
    _documents[d4.id] = d4;

    // 3. Mục tiêu học tập mẫu
    final g1 = StudyGoal(
      id: 'goal_1',
      title: 'Hoàn thành toàn bộ bài tập môn Kiến trúc Phần mềm',
      courseId: c1.id,
      targetCount: 5,
      completedCount: 3,
      deadline: now.add(const Duration(days: 14)),
      notes: 'Trọng tâm vào kiến trúc Offline-First và Reactive Pattern',
    );
    final g2 = StudyGoal(
      id: 'goal_2',
      title: 'Đọc 10 tài liệu tham khảo Flutter nâng cao',
      courseId: c2.id,
      targetCount: 10,
      completedCount: 6,
      deadline: now.add(const Duration(days: 20)),
      notes: 'Tối ưu hóa hiệu năng render Widget Slivers',
    );

    _goals[g1.id] = g1;
    _goals[g2.id] = g2;

    // Khởi tạo các streams
    Timer.run(() {
      _notifyDocuments();
      _notifyCourses();
      _notifyGoals();
    });
  }

  // --- CRUD Documents ---
  Future<void> insertDocument(StudyDocument doc) async {
    _documents[doc.id] = doc;
    _notifyDocuments();
  }

  Future<void> updateDocument(StudyDocument doc) async {
    _documents[doc.id] = doc;
    _notifyDocuments();
  }

  Future<void> deleteDocument(String id) async {
    _documents.remove(id);
    _notifyDocuments();
  }

  StudyDocument? getDocument(String id) => _documents[id];

  List<StudyDocument> getAllDocuments() {
    final list = _documents.values.toList();
    list.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return list;
  }

  // --- CRUD Courses ---
  Future<void> insertCourse(Course course) async {
    _courses[course.id] = course;
    _notifyCourses();
  }

  Future<void> updateCourse(Course course) async {
    _courses[course.id] = course;
    _notifyCourses();
  }

  Future<void> deleteCourse(String id) async {
    _courses.remove(id);
    // Xóa liên hoàn các tài liệu thuộc môn học đó (Cascade Delete)
    _documents.removeWhere((key, value) => value.courseId == id);
    _notifyCourses();
    _notifyDocuments();
  }

  Course? getCourse(String id) => _courses[id];
  List<Course> getAllCourses() => _courses.values.toList();

  // --- CRUD Goals ---
  Future<void> insertGoal(StudyGoal goal) async {
    _goals[goal.id] = goal;
    _notifyGoals();
  }

  Future<void> updateGoal(StudyGoal goal) async {
    _goals[goal.id] = goal;
    _notifyGoals();
  }

  Future<void> deleteGoal(String id) async {
    _goals.remove(id);
    _notifyGoals();
  }

  List<StudyGoal> getAllGoals() => _goals.values.toList();

  // --- Backup & Export / Import ---
  String exportToJson() {
    final data = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'courses': _courses.values.map((c) => c.toMap()).toList(),
      'documents': _documents.values.map((d) => d.toMap()).toList(),
      'goals': _goals.values.map((g) => g.toMap()).toList(),
    };
    return jsonEncode(data);
  }

  void importFromJson(String jsonString) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      if (data['courses'] != null) {
        for (var item in data['courses']) {
          final c = Course.fromMap(item);
          _courses[c.id] = c;
        }
      }
      if (data['documents'] != null) {
        for (var item in data['documents']) {
          final d = StudyDocument.fromMap(item);
          _documents[d.id] = d;
        }
      }
      if (data['goals'] != null) {
        for (var item in data['goals']) {
          final g = StudyGoal.fromMap(item);
          _goals[g.id] = g;
        }
      }
      _notifyCourses();
      _notifyDocuments();
      _notifyGoals();
    } catch (e) {
      throw FormatException('Định dạng tệp sao lưu không hợp lệ: $e');
    }
  }

  void resetDatabase() {
    _documents.clear();
    _courses.clear();
    _goals.clear();
    _initSeedData();
  }
}


