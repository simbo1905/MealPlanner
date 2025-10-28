// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_recognition_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$textRecognitionServiceHash() =>
    r'9f9c1d32920265d7da653e09ee89b372b7d0f4dc';

/// See also [textRecognitionService].
@ProviderFor(textRecognitionService)
final textRecognitionServiceProvider =
    AutoDisposeProvider<TextRecognitionService>.internal(
      textRecognitionService,
      name: r'textRecognitionServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$textRecognitionServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TextRecognitionServiceRef =
    AutoDisposeProviderRef<TextRecognitionService>;
String _$recognizeTextHash() => r'7d4813f6e71fed51ad33c0582156f8a07de54916';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [recognizeText].
@ProviderFor(recognizeText)
const recognizeTextProvider = RecognizeTextFamily();

/// See also [recognizeText].
class RecognizeTextFamily extends Family<AsyncValue<String>> {
  /// See also [recognizeText].
  const RecognizeTextFamily();

  /// See also [recognizeText].
  RecognizeTextProvider call(String imagePath) {
    return RecognizeTextProvider(imagePath);
  }

  @override
  RecognizeTextProvider getProviderOverride(
    covariant RecognizeTextProvider provider,
  ) {
    return call(provider.imagePath);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recognizeTextProvider';
}

/// See also [recognizeText].
class RecognizeTextProvider extends AutoDisposeFutureProvider<String> {
  /// See also [recognizeText].
  RecognizeTextProvider(String imagePath)
    : this._internal(
        (ref) => recognizeText(ref as RecognizeTextRef, imagePath),
        from: recognizeTextProvider,
        name: r'recognizeTextProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$recognizeTextHash,
        dependencies: RecognizeTextFamily._dependencies,
        allTransitiveDependencies:
            RecognizeTextFamily._allTransitiveDependencies,
        imagePath: imagePath,
      );

  RecognizeTextProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.imagePath,
  }) : super.internal();

  final String imagePath;

  @override
  Override overrideWith(
    FutureOr<String> Function(RecognizeTextRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecognizeTextProvider._internal(
        (ref) => create(ref as RecognizeTextRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        imagePath: imagePath,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _RecognizeTextProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecognizeTextProvider && other.imagePath == imagePath;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, imagePath.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RecognizeTextRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `imagePath` of this provider.
  String get imagePath;
}

class _RecognizeTextProviderElement
    extends AutoDisposeFutureProviderElement<String>
    with RecognizeTextRef {
  _RecognizeTextProviderElement(super.provider);

  @override
  String get imagePath => (origin as RecognizeTextProvider).imagePath;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
