import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../services/ocr_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/primary_button.dart';
import 'edit_text_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final OcrService _ocr = OcrService.instance;
  String? _imagePath;
  bool _busy = false;

  Future<void> _scan(ImageSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final path = await _ocr.pickImagePath(source);
      if (path == null) return;

      setState(() {
        _imagePath = path;
        _busy = true;
      });

      final text = await _ocr.extractText(path);
      if (!mounted) return;
      setState(() => _busy = false);

      if (text.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No text found. Try a clearer photo.')),
        );
        return;
      }

      navigator.push(
        MaterialPageRoute(
          builder: (_) => EditTextScreen(initialText: text),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not read the image. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan notes')),
      body: LoadingOverlay(
        isLoading: _busy,
        message: 'Reading text…',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: _imagePath == null
                        ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner_outlined,
                          size: 56,
                          color: AppColors.accent,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Take a photo of your notes',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                        : Image.file(File(_imagePath!), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Use camera',
                  icon: Icons.photo_camera_rounded,
                  onPressed: () => _scan(ImageSource.camera),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _scan(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose from gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.glassBorder),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditTextScreen(initialText: ''),
                    ),
                  ),
                  child: const Text('Or type / paste text'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}