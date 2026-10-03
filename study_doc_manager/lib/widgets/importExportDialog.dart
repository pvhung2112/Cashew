import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';

class ImportExportDialog extends StatefulWidget {
  const ImportExportDialog({super.key});

  @override
  State<ImportExportDialog> createState() => _ImportExportDialogState();
}

class _ImportExportDialogState extends State<ImportExportDialog> {
  final TextEditingController _importController = TextEditingController();
  String _exportPreview = '';
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _generateExport();
  }

  void _generateExport() {
    setState(() {
      _exportPreview = AppDatabase().exportToJson();
    });
  }

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: _exportPreview));
    setState(() {
      _copied = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép chuỗi sao lưu JSON vào bộ nhớ đệm!')),
    );
  }

  void _handleImport() {
    final text = _importController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng dán chuỗi dữ liệu JSON cần khôi phục!')),
      );
      return;
    }

    try {
      AppDatabase().importFromJson(text);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khôi phục dữ liệu thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi nhập dữ liệu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.swap_vert_circle_rounded, color: Color(0xFF1E3C72)),
          SizedBox(width: 8),
          Text('Sao lưu & Xuất nhập Dữ liệu'),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '1. Xuất dữ liệu sao lưu (JSON Backup):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _exportPreview,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _handleCopy,
                icon: Icon(_copied ? Icons.check : Icons.copy_rounded, size: 16),
                label: Text(_copied ? 'Đã chép vào Clipboard' : 'Sao chép JSON'),
              ),
              const Divider(height: 32),
              const Text(
                '2. Nhập dữ liệu sao lưu (Restore):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _importController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Dán chuỗi JSON đã xuất tại đây...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _handleImport,
                icon: const Icon(Icons.download_rounded, size: 16),
                label: const Text('Tiến hành Khôi phục dữ liệu'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
