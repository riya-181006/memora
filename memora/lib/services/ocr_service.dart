import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  OcrService._();

  static final OcrService instance = OcrService._();

  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImagePath(ImageSource source) async {
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    return file?.path;
  }

  Future<String> extractText(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final input = InputImage.fromFilePath(imagePath);
      final result = await recognizer.processImage(input);
      return result.text.trim();
    } finally {
      await recognizer.close();
    }
  }
}