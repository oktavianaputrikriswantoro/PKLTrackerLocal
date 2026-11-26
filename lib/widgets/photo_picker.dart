import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/photo_service.dart';
import 'photo_preview.dart';

class PhotoPicker extends StatefulWidget {
  final ValueChanged<String?> onPhotoSelected;
  final String? initialPath;

  const PhotoPicker({
    super.key,
    required this.onPhotoSelected,
    this.initialPath,
  });

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  final PhotoService _service = PhotoService();
  String? fotoPath;

  @override
  void initState() {
    super.initState();
    fotoPath = widget.initialPath;
  }

  Future<void> pilihFoto(ImageSource source) async {
    try {
      final hasil = await _service.pilihFoto(source: source);

      if (!mounted || hasil == null) return;

      setState(() => fotoPath = hasil);
      widget.onPhotoSelected(hasil);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih foto: $e')));
    }
  }

  void tampilkanPilihan() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari galeri'),
                onTap: () {
                  Navigator.pop(context);
                  pilihFoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil foto'),
                onTap: () {
                  Navigator.pop(context);
                  pilihFoto(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto Dokumentasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: tampilkanPilihan,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: fotoPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox.expand(
                      child: photoPreview(fotoPath!, fit: BoxFit.cover),
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 40,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: 8),
                      Text('Pilih atau ambil foto'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
