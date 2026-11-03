import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

/// A picked photo as a multipart part with its image type. Upload endpoints
/// check the part's MIME type, and Dio would otherwise send octet-stream.
Future<MultipartFile> imagePart(XFile file) {
  final subtype = switch (file.name.split('.').last.toLowerCase()) {
    'png' => 'png',
    'webp' => 'webp',
    'gif' => 'gif',
    _ => 'jpeg',
  };
  return MultipartFile.fromFile(
    file.path,
    filename: file.name,
    contentType: DioMediaType('image', subtype),
  );
}
