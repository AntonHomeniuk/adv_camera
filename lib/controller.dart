part of adv_camera;

/// Controller for a single GoogleMap instance running on the host platform.
class AdvCameraController {
  AdvCameraController._(
    this.channel,
    this._advCameraState,
  )  {
    channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<AdvCameraController> init(
    int id,
    _AdvCameraState advCameraState,
  ) async {
    final MethodChannel channel =
        MethodChannel('plugins.flutter.io/adv_camera/$id');

    await channel.invokeMethod('waitForCamera');

    return AdvCameraController._(
      channel,
      advCameraState,
    );
  }

  @visibleForTesting
  final MethodChannel channel;

  final _AdvCameraState _advCameraState;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case "onImageCaptured":
        String path = call.arguments['path'] as String;
        _advCameraState.onImageCaptured(path);
        break;
      case "onFlashTypeChanged":
        String types = call.arguments['types'] as String;
        _advCameraState.onImageCaptured(types);
        break;
      default:
        throw MissingPluginException();
    }
  }

  Future<void> setSessionPreset(CameraSessionPreset cameraSessionPreset) async {
    if (Platform.isAndroid) return;

    String sessionPreset;

    switch (cameraSessionPreset) {
      case CameraSessionPreset.low:
        sessionPreset = "low";
        break;
      case CameraSessionPreset.medium:
        sessionPreset = "medium";
        break;
      case CameraSessionPreset.high:
        sessionPreset = "high";
        break;
      case CameraSessionPreset.photo:
        sessionPreset = "photo";
        break;
    }
    await channel.invokeMethod('setSessionPreset', <String, dynamic>{
      'sessionPreset': sessionPreset,
    });

    _advCameraState._cameraSessionPreset = cameraSessionPreset;
    _advCameraState.setState(() {});
  }

  Future<void> setPreviewRatio(CameraPreviewRatio cameraPreviewRatio) async {
    if (Platform.isIOS) return;

    String previewRatio;

    switch (cameraPreviewRatio) {
      case CameraPreviewRatio.r16_9:
        previewRatio = "16:9";
        break;
      case CameraPreviewRatio.r11_9:
        previewRatio = "11:9";
        break;
      case CameraPreviewRatio.r4_3:
        previewRatio = "4:3";
        break;
      case CameraPreviewRatio.r1:
        previewRatio = "1:1";
        break;
    }

    bool success =
        await channel.invokeMethod('setPreviewRatio', <String, dynamic>{
      'previewRatio': previewRatio,
    });

    if (success) {
      _advCameraState._cameraPreviewRatio = cameraPreviewRatio;
      _advCameraState.setState(() {});
    }
  }

  Future<void> captureImage({int? maxSize}) async {
    await channel.invokeMethod('captureImage', <String, dynamic>{
      'maxSize': maxSize,
    });
  }

  Future<void> switchCamera() async {
    await channel.invokeMethod('switchCamera', null);
  }

  Future<void> turnOffCamera() async {
    await channel.invokeMethod('turnOff', null);
  }

  Future<void> turnOnCamera() async {
    await channel.invokeMethod('turnOn', null);
  }

  Future<List<String>?> getPictureSizes() async {
    var result = await channel.invokeMethod('getPictureSizes', null);

    if (result == null) return null;

    return List<String>.from(result);
  }

  Future<void> setPictureSize(int width, int height) async {
    await channel.invokeMethod(
        'setPictureSize', {"pictureWidth": width, "pictureHeight": height});
  }

  Future<void> setSavePath(String savePath) async {
    if (Platform.isIOS) return;

    await channel.invokeMethod('setSavePath', {"savePath": savePath});
  }

  Future<void> setFocus(
      double x,
      double y,
  ) async {
    await channel.invokeMethod('setFocus', {"x": x, "y": y});
  }

  Future<void> setFlashType(FlashType flashType) async {
    String flashTypeString;

    switch (flashType) {
      case FlashType.auto:
        flashTypeString = "auto";
        break;
      case FlashType.on:
        flashTypeString = "on";
        break;
      case FlashType.off:
        flashTypeString = "off";
        break;
      case FlashType.torch:
        flashTypeString = "torch";
        break;
    }

    await channel.invokeMethod('setFlashType', {"flashType": flashTypeString});
  }

  Future<List<FlashType>> getFlashType() async {
    final types = await channel.invokeMethod('getFlashType');

    List<FlashType> finalTypes = [];

    if (types == null) return finalTypes;

    if (types is List) {
      for (var each in types) {
        if (each == "on") {
          finalTypes.add(FlashType.on);
        } else if (each == "off") {
          finalTypes.add(FlashType.off);
        } else if (each == "torch") {
          finalTypes.add(FlashType.torch);
        } else if (each == "auto") {
          finalTypes.add(FlashType.auto);
        }
      }
    }

    return finalTypes;
  }
}
