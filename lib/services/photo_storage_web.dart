import 'dart:convert';

import 'package:image_picker/image_picker.dart';

Future<String> savePhoto(XFile photo) async {
  final bytes = await photo.readAsBytes();
  return 'data:${photo.mimeType ?? 'image/jpeg'};base64,'
      '${base64Encode(bytes)}';
}

Future<void> deletePhoto(String? path) async {}
