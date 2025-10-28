import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/text_recognition_service.dart';

part 'text_recognition_provider.g.dart';

@riverpod
TextRecognitionService textRecognitionService(Ref ref) {
  final service = TextRecognitionService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
}

@riverpod
Future<String> recognizeText(
  Ref ref,
  String imagePath,
) async {
  final service = ref.watch(textRecognitionServiceProvider);
  final text = await service.recognizeTextFromFile(imagePath);
  return text;
}
