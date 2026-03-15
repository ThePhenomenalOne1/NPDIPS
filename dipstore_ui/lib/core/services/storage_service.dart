import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage({
    required XFile file,
    required String path,
  }) async {
    try {
      final ref = _storage
          .ref()
          .child(path)
          .child('${DateTime.now().millisecondsSinceEpoch}_${file.name}');

      if (kIsWeb) {
        await ref.putData(await file.readAsBytes());
      } else {
        await ref.putFile(File(file.path));
      }

      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting image: $e');
      // Don't rethrow, strictly speaking, missing file is not critical for flow
    }
  }
}
