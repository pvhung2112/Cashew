import 'dart:async';

/// Dịch vụ kết nối ngoại vi (External Services Layer)
class ExternalStorageService {
  static final ExternalStorageService _instance = ExternalStorageService._internal();
  factory ExternalStorageService() => _instance;
  ExternalStorageService._internal();

  Future<Map<String, dynamic>> fetchDocumentMetadata(String url) async {
    final cleanUrl = url.trim();
    String detectedExtension = 'pdf';
    int estimatedSizeKb = 1024;

    if (cleanUrl.endsWith('.docx') || cleanUrl.contains('docx')) {
      detectedExtension = 'docx';
      estimatedSizeKb = 512;
    } else if (cleanUrl.endsWith('.pptx') || cleanUrl.contains('pptx')) {
      detectedExtension = 'pptx';
      estimatedSizeKb = 4096;
    } else if (cleanUrl.endsWith('.zip') || cleanUrl.contains('zip')) {
      detectedExtension = 'zip';
      estimatedSizeKb = 10240;
    }

    return {
      'url': cleanUrl,
      'extension': detectedExtension,
      'sizeKb': estimatedSizeKb,
      'verified': true,
      'source': cleanUrl.contains('drive.google.com') ? 'Google Drive' : 'Direct Link',
    };
  }
}
