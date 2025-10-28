import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
  late TextRecognizer _textRecognizer;

  TextRecognitionService() {
    _textRecognizer = TextRecognizer();
  }

  Future<String> recognizeTextFromFile(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    String extractedText = '';
    for (TextBlock block in recognizedText.blocks) {
      extractedText += '${block.text}\n';
    }

    return extractedText.trim();
  }

  void dispose() {
    _textRecognizer.close();
  }
}
