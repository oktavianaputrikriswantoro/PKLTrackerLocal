import 'package:image_picker/image_picker.dart';

import 'photo_storage.dart' as storage;

class PhotoService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pilihFoto({required ImageSource source}) async {
    final XFile? hasil = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );

    if (hasil == null) return null;
    return storage.savePhoto(hasil);
  }

  Future<void> hapusFoto(String? path) async {
    await storage.deletePhoto(path);
  }
}
