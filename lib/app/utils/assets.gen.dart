/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vector_graphics/vector_graphics.dart';

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/arrow_down.svg
  SvgGenImage get arrowDown => const SvgGenImage('assets/icons/arrow_down.svg');

  /// File path: assets/icons/ic_check.svg
  SvgGenImage get icCheck => const SvgGenImage('assets/icons/ic_check.svg');

  /// File path: assets/icons/ic_chevron_right.svg
  SvgGenImage get icChevronRight => const SvgGenImage('assets/icons/ic_chevron_right.svg');

  /// Directory path: assets/icons/ic_flags
  $AssetsIconsIcFlagsGen get icFlags => const $AssetsIconsIcFlagsGen();

  /// File path: assets/icons/ic_settings_language.svg
  SvgGenImage get icSettingsLanguage => const SvgGenImage('assets/icons/ic_settings_language.svg');

  /// File path: assets/icons/ic_settings_privacy.svg
  SvgGenImage get icSettingsPrivacy => const SvgGenImage('assets/icons/ic_settings_privacy.svg');

  /// File path: assets/icons/ic_settings_rate.svg
  SvgGenImage get icSettingsRate => const SvgGenImage('assets/icons/ic_settings_rate.svg');

  /// File path: assets/icons/ic_settings_share.svg
  SvgGenImage get icSettingsShare => const SvgGenImage('assets/icons/ic_settings_share.svg');

  /// File path: assets/icons/ic_splash_progress.svg
  SvgGenImage get icSplashProgress => const SvgGenImage('assets/icons/ic_splash_progress.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
        arrowDown,
        icCheck,
        icChevronRight,
        icSettingsLanguage,
        icSettingsPrivacy,
        icSettingsRate,
        icSettingsShare,
        icSplashProgress
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/bg_rate.png
  AssetGenImage get bgRate => const AssetGenImage('assets/images/bg_rate.png');

  /// File path: assets/images/icon_app.png
  AssetGenImage get iconApp => const AssetGenImage('assets/images/icon_app.png');

  /// File path: assets/images/onboarding_1.png
  AssetGenImage get onboarding1 => const AssetGenImage('assets/images/onboarding_1.png');

  /// File path: assets/images/onboarding_2.png
  AssetGenImage get onboarding2 => const AssetGenImage('assets/images/onboarding_2.png');

  /// File path: assets/images/onboarding_3.png
  AssetGenImage get onboarding3 => const AssetGenImage('assets/images/onboarding_3.png');

  /// List of all assets
  List<AssetGenImage> get values => [bgRate, iconApp, onboarding1, onboarding2, onboarding3];
}

class $AssetsIconsIcFlagsGen {
  const $AssetsIconsIcFlagsGen();

  /// File path: assets/icons/ic_flags/de.png
  AssetGenImage get de => const AssetGenImage('assets/icons/ic_flags/de.png');

  /// File path: assets/icons/ic_flags/en.png
  AssetGenImage get en => const AssetGenImage('assets/icons/ic_flags/en.png');

  /// File path: assets/icons/ic_flags/es.png
  AssetGenImage get es => const AssetGenImage('assets/icons/ic_flags/es.png');

  /// File path: assets/icons/ic_flags/fr.png
  AssetGenImage get fr => const AssetGenImage('assets/icons/ic_flags/fr.png');

  /// File path: assets/icons/ic_flags/hi.png
  AssetGenImage get hi => const AssetGenImage('assets/icons/ic_flags/hi.png');

  /// File path: assets/icons/ic_flags/id.png
  AssetGenImage get id => const AssetGenImage('assets/icons/ic_flags/id.png');

  /// File path: assets/icons/ic_flags/pt.png
  AssetGenImage get pt => const AssetGenImage('assets/icons/ic_flags/pt.png');

  /// List of all assets
  List<AssetGenImage> get values => [de, en, es, fr, hi, id, pt];
}

class Assets {
  Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class SvgGenImage {
  const SvgGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = false;

  const SvgGenImage.vec(
    this._assetName, {
    this.size,
    this.flavors = const {},
  }) : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    SvgTheme? theme,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final BytesLoader loader;
    if (_isVecFormat) {
      loader = AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
      );
    }
    return SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter: colorFilter ?? (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
