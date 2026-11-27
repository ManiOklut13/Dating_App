import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Resolves asset, network/blob URL, or local file path cleanly across web & mobile.
ImageProvider resolveIdentityImageProvider(String path) {
  if (path.startsWith('assets/')) {
    return AssetImage(path);
  }
  if (kIsWeb ||
      path.startsWith('http://') ||
      path.startsWith('https://') ||
      path.startsWith('blob:')) {
    return NetworkImage(path);
  }
  return FileImage(File(path));
}

/// Opens a Phone-Photos style multi-select sheet requiring 2 to 5 photos.
Future<List<String>?> showIdentityPhotoPickerSheet(
  BuildContext context, {
  List<String> initialPhotos = const [],
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _IdentityPhotoPickerSheet(initialPhotos: initialPhotos),
  );
}

class _IdentityPhotoPickerSheet extends StatefulWidget {
  final List<String> initialPhotos;

  const _IdentityPhotoPickerSheet({required this.initialPhotos});

  @override
  State<_IdentityPhotoPickerSheet> createState() =>
      _IdentityPhotoPickerSheetState();
}

class _IdentityPhotoPickerSheetState extends State<_IdentityPhotoPickerSheet> {
  static const int minPhotos = 2;
  static const int maxPhotos = 5;

  final ImagePicker _picker = ImagePicker();
  late final List<String> _selected;
  final List<String> _devicePhotos = [];

  static const List<String> _recentPhoneGallery = [
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600',
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=600',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=600',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=600',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=600',
  ];

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.initialPhotos);
    for (final p in _selected) {
      if (!_recentPhoneGallery.contains(p) && !_devicePhotos.contains(p)) {
        _devicePhotos.add(p);
      }
    }
  }

  Future<void> _pickFromDeviceGallery() async {
    try {
      final files = await _picker.pickMultiImage(imageQuality: 85);
      if (files.isEmpty || !mounted) return;
      setState(() {
        for (final f in files) {
          if (!_devicePhotos.contains(f.path)) {
            _devicePhotos.insert(0, f.path);
          }
          if (!_selected.contains(f.path) && _selected.length < maxPhotos) {
            _selected.add(f.path);
          }
        }
      });
    } catch (_) {
      final single = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (single != null && mounted) {
        setState(() {
          if (!_devicePhotos.contains(single.path)) {
            _devicePhotos.insert(0, single.path);
          }
          if (!_selected.contains(single.path) && _selected.length < maxPhotos) {
            _selected.add(single.path);
          }
        });
      }
    }
  }

  void _togglePhoto(String path) {
    setState(() {
      if (_selected.contains(path)) {
        _selected.remove(path);
      } else if (_selected.length < maxPhotos) {
        _selected.add(path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 5 photos can be selected.'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF14151D) : Colors.white;
    final tileBg = isDark ? const Color(0xFF1E202B) : const Color(0xFFF3F4F6);
    final primary = theme.colorScheme.primary;
    final textPrimary = isDark ? Colors.white : const Color(0xFF181A24);
    final textSub = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final allPhotos = [..._devicePhotos, ..._recentPhoneGallery];
    final canConfirm =
        _selected.length >= minPhotos && _selected.length <= maxPhotos;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
              child: Row(
                children: [
                  Icon(Icons.photo_library_rounded, color: primary, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone Photos • Recents',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          'Select minimum 2 and maximum 5 photos',
                          style: TextStyle(fontSize: 12, color: textSub),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (canConfirm ? Colors.green : primary)
                          .withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selected.length}/$maxPhotos',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: canConfirm ? Colors.green : primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textSub),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Open Native Device Gallery / Files Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: InkWell(
                onTap: _pickFromDeviceGallery,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: tileBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: primary.withOpacity(0.35)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.folder_open_rounded, color: primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Browse Photos from Phone Storage',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Phone-Gallery Style Multi-Select Photo Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: allPhotos.length,
                itemBuilder: (context, index) {
                  final path = allPhotos[index];
                  final orderIdx = _selected.indexOf(path);
                  final isSelected = orderIdx != -1;

                  return GestureDetector(
                    onTap: () => _togglePhoto(path),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? primary
                                  : (isDark
                                      ? Colors.white12
                                      : Colors.grey.shade300),
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image(
                            image: resolveIdentityImageProvider(path),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: tileBg,
                              child: Icon(Icons.broken_image_outlined,
                                  color: textSub),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: primary.withOpacity(0.18),
                            ),
                          ),
                        Positioned(
                          top: 7,
                          right: 7,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? primary : Colors.black45,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: isSelected
                                ? Text(
                                    '${orderIdx + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canConfirm
                      ? () => Navigator.pop(context, _selected)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    canConfirm
                        ? 'Use ${_selected.length} Selected Photos'
                        : 'Select at least 2 photos (${_selected.length}/2 min)',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact strip displaying the 2-5 selected photos with add/remove controls.
class IdentityPhotoGridPreview extends StatelessWidget {
  final List<String> photos;
  final VoidCallback onAddTap;
  final ValueChanged<int> onRemoveAt;

  const IdentityPhotoGridPreview({
    super.key,
    required this.photos,
    required this.onAddTap,
    required this.onRemoveAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final subColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected Photos (${photos.length}/5)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              photos.length < 2 ? 'Minimum 2 required' : '2–5 photos ready ✓',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: photos.length < 2 ? Colors.orangeAccent : Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 86,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...List.generate(photos.length, (idx) {
                final path = photos[idx];
                return Container(
                  width: 72,
                  height: 86,
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image(
                          image: resolveIdentityImageProvider(path),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => onRemoveAt(idx),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            idx == 0 ? 'Main' : '${idx + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (photos.length < 5)
                GestureDetector(
                  onTap: onAddTap,
                  child: Container(
                    width: 72,
                    height: 86,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF16161D)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primary.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, color: primary, size: 22),
                        const SizedBox(height: 2),
                        Text(
                          'Add',
                          style: TextStyle(fontSize: 11, color: subColor),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
