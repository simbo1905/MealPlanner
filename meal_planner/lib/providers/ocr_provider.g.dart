// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ocr_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$processRecipeImageHash() =>
    r'45fe6b31c4e9038aea1670bf67133947ad4b95f6';

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

/// Mock OCR processing provider
/// In production, this would call MistralAI Vision API
///
/// Copied from [processRecipeImage].
@ProviderFor(processRecipeImage)
const processRecipeImageProvider = ProcessRecipeImageFamily();

/// Mock OCR processing provider
/// In production, this would call MistralAI Vision API
///
/// Copied from [processRecipeImage].
class ProcessRecipeImageFamily extends Family<AsyncValue<WorkspaceRecipe>> {
  /// Mock OCR processing provider
  /// In production, this would call MistralAI Vision API
  ///
  /// Copied from [processRecipeImage].
  const ProcessRecipeImageFamily();

  /// Mock OCR processing provider
  /// In production, this would call MistralAI Vision API
  ///
  /// Copied from [processRecipeImage].
  ProcessRecipeImageProvider call(String imagePath) {
    return ProcessRecipeImageProvider(imagePath);
  }

  @override
  ProcessRecipeImageProvider getProviderOverride(
    covariant ProcessRecipeImageProvider provider,
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
  String? get name => r'processRecipeImageProvider';
}

/// Mock OCR processing provider
/// In production, this would call MistralAI Vision API
///
/// Copied from [processRecipeImage].
class ProcessRecipeImageProvider
    extends AutoDisposeFutureProvider<WorkspaceRecipe> {
  /// Mock OCR processing provider
  /// In production, this would call MistralAI Vision API
  ///
  /// Copied from [processRecipeImage].
  ProcessRecipeImageProvider(String imagePath)
    : this._internal(
        (ref) => processRecipeImage(ref as ProcessRecipeImageRef, imagePath),
        from: processRecipeImageProvider,
        name: r'processRecipeImageProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$processRecipeImageHash,
        dependencies: ProcessRecipeImageFamily._dependencies,
        allTransitiveDependencies:
            ProcessRecipeImageFamily._allTransitiveDependencies,
        imagePath: imagePath,
      );

  ProcessRecipeImageProvider._internal(
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
    FutureOr<WorkspaceRecipe> Function(ProcessRecipeImageRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProcessRecipeImageProvider._internal(
        (ref) => create(ref as ProcessRecipeImageRef),
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
  AutoDisposeFutureProviderElement<WorkspaceRecipe> createElement() {
    return _ProcessRecipeImageProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProcessRecipeImageProvider && other.imagePath == imagePath;
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
mixin ProcessRecipeImageRef on AutoDisposeFutureProviderRef<WorkspaceRecipe> {
  /// The parameter `imagePath` of this provider.
  String get imagePath;
}

class _ProcessRecipeImageProviderElement
    extends AutoDisposeFutureProviderElement<WorkspaceRecipe>
    with ProcessRecipeImageRef {
  _ProcessRecipeImageProviderElement(super.provider);

  @override
  String get imagePath => (origin as ProcessRecipeImageProvider).imagePath;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
