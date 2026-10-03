# 📚 Quản lý Tài liệu Học tập (Study Document Manager)
### Ứng dụng áp dụng Kiến trúc Cashew (Local-First Architecture)

- **Môn học / Bài tập:** Thực hành 1 (TH1): Xây dựng Ứng dụng Quản lý Tài liệu Học tập theo Kiến trúc Cashew
- **Sinh viên thực hiện:** **Phạm Văn Hưng** (GitHub: `pvhung2112`)
- **Thư mục dự án:** `D:\ok\study_doc_manager\`
- **Báo cáo giải trình đầy đủ 5 mục Checklist:** [Xem file BAO_CAO_TH1_QUAN_LY_TAI_LIEU_CASHEW.md](../BAO_CAO_TH1_QUAN_LY_TAI_LIEU_CASHEW.md)

---

## 🏛️ Cấu trúc phân lớp kiến trúc (Cashew Layering)

Dự án được phân chia thành 4 phân hệ chính chuẩn theo mô hình kiến trúc của ứng dụng Cashew:

```
lib/
├── main.dart                          # Khởi tạo App & Theme Material 3
├── database/                          # TẦNG DATA & STORAGE
│   ├── tables.dart                    # Schema cấu trúc bảng
│   ├── database_helper.dart           # Local-First Engine & Reactive Streams
│   ├── document_dao.dart              # Data Access Object cho Tài liệu
│   ├── course_dao.dart                # Data Access Object cho Môn học
│   └── goal_dao.dart                  # Data Access Object cho Mục tiêu
├── struct/                            # TẦNG FEATURE ENTITIES & SERVICES
│   ├── studyDocument.dart             # Model Tài liệu (Bài giảng, Bài tập, Tham khảo)
│   ├── course.dart                    # Model Môn học / Học phần
│   ├── studyGoal.dart                 # Model Mục tiêu tiến độ
│   ├── syncClient.dart                # Bộ đồng bộ đám mây Local-First
│   ├── reminderService.dart           # Dịch vụ nhắc hạn nộp bài tập
│   └── externalStorageService.dart    # Tích hợp dịch vụ ngoại vi
├── pages/                             # TẦNG APP EXPERIENCE (PRESENTATION)
│   ├── homePage/homePage.dart         # Dashboard tổng quan
│   ├── documentsPage.dart             # Danh sách tài liệu phân Tab & Chips
│   ├── addEditDocumentPage.dart       # Form Thêm / Sửa tài liệu
│   ├── documentSearchPage.dart        # Tìm kiếm & Lọc đa tiêu chí
│   ├── coursesPage.dart               # Quản lý Môn học
│   └── studyGoalsPage.dart            # Theo dõi Mục tiêu & Tiến độ
└── widgets/                           # TẦNG REUSABLE COMPONENTS
    ├── documentCard.dart              # Thẻ tài liệu tương tác nhanh
    ├── statSummaryCard.dart           # Thẻ thống kê tổng quan
    ├── importExportDialog.dart        # Xuất / nhập sao lưu JSON
    └── backupRestoreWidget.dart       # Quản lý hàng đợi đồng bộ
```

---

## 🧪 Kết quả Kiểm thử tự động (Checklist 4)

Chạy lệnh kiểm thử:
```bash
flutter test
```

Kết quả: **11/11 tests passed 100%**
- `test/document_crud_test.dart`: Kiểm thử Thêm, Sửa, Xóa, Tìm kiếm, Lọc đa tiêu chí.
- `test/architecture_layer_test.dart`: Kiểm thử tính tách biệt của DAO, Reactive Streams, Cascade Delete, Sao lưu và Phục hồi JSON.
- `test/sync_client_test.dart`: Kiểm thử hàng đợi đồng bộ Sync Queue và tiến trình đồng bộ Local-First lên Cloud.

---

## 🚀 Hướng dẫn khởi chạy ứng dụng

```bash
# Di chuyển vào thư mục dự án
cd D:\ok\study_doc_manager

# Cài đặt thư viện
flutter pub get

# Chạy kiểm thử tự động
flutter test

# Khởi chạy trên trình duyệt Web (Chrome)
flutter run -d chrome
```
