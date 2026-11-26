import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String> savePhoto(XFile photo) async {
  final folder = await getApplicationDocumentsDirectory();
  final photoFolder = Directory('${folder.path}/foto_logbook');
  if (!await photoFolder.exists()) {
    await photoFolder.create(recursive: true);
  }

  final filename = 'foto_${DateTime.now().microsecondsSinceEpoch}.jpg';
  final location = '${photoFolder.path}/$filename';
  await File(photo.path).copy(location);
  return location;
}

Future<void> deletePhoto(String? path) async {
  if (path == null || path.isEmpty) return;
  final file = File(path);
  if (await file.exists()) await file.delete();
}
