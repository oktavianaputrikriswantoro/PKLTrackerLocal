import 'dart:convert';

import 'package:flutter/material.dart';

Widget photoPreview(String path, {BoxFit fit = BoxFit.cover}) {
  final separator = path.indexOf(',');
  if (!path.startsWith('data:image/') || separator < 0) {
    return const Center(child: Icon(Icons.broken_image_outlined));
  }
  try {
    return Image.memory(
      base64Decode(path.substring(separator + 1)),
      fit: fit,
      errorBuilder: (_, _, _) =>
          const Center(child: Icon(Icons.broken_image_outlined)),
    );
  } on FormatException {
    return const Center(child: Icon(Icons.broken_image_outlined));
  }
}
