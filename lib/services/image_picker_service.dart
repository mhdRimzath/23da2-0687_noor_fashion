import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

/// Service to pick images from Camera, Gallery, or File Manager.
/// Returns compressed Uint8List bytes ready for upload.
class ImagePickerService {
  final ImagePicker _imagePicker = ImagePicker();

  /// Pick image from Camera
  Future<Uint8List?> pickFromCamera() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );
      if (file == null) return null;
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('❌ Camera pick error: $e');
      return null;
    }
  }

  /// Pick image from Gallery
  Future<Uint8List?> pickFromGallery() async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 75,
      );
      if (file == null) return null;
      return await file.readAsBytes();
    } catch (e) {
      debugPrint('❌ Gallery pick error: $e');
      return null;
    }
  }

  /// Pick image from File Manager
  Future<Uint8List?> pickFromFileManager() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return null;

      final PlatformFile file = result.files.first;

      // For web or when bytes are directly available
      if (file.bytes != null) {
        return file.bytes!;
      }

      // For mobile/desktop when file path is available
      if (file.path != null) {
        final xFile = XFile(file.path!);
        return await xFile.readAsBytes();
      }

      return null;
    } catch (e) {
      debugPrint('❌ File picker error: $e');
      return null;
    }
  }
}
