/// Thực thể Môn học / Học phần (Tương đương Account/Wallet trong Cashew)
class Course {
  final String id;
  final String code; // Mã môn học: CS101, SE302, ...
  final String name; // Tên môn học: Kiến trúc Hệ thống, Lập trình Di động, ...
  final String lecturer; // Giảng viên phụ trách
  final int credits; // Số tín chỉ
  final int colorValue; // Mã màu HEX để hiển thị giao diện UI
  final String description;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.code,
    required this.name,
    this.lecturer = '',
    this.credits = 3,
    this.colorValue = 0xFF4A86E8, // Xanh Cashew
    this.description = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Course copyWith({
    String? id,
    String? code,
    String? name,
    String? lecturer,
    int? credits,
    int? colorValue,
    String? description,
    DateTime? createdAt,
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      lecturer: lecturer ?? this.lecturer,
      credits: credits ?? this.credits,
      colorValue: colorValue ?? this.colorValue,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'lecturer': lecturer,
      'credits': credits,
      'colorValue': colorValue,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      lecturer: map['lecturer'] ?? '',
      credits: map['credits'] is int ? map['credits'] : int.tryParse('${map['credits']}') ?? 3,
      colorValue: map['colorValue'] is int ? map['colorValue'] : int.tryParse('${map['colorValue']}') ?? 0xFF4A86E8,
      description: map['description'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }
}
