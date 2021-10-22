library flutter_mask_player;

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

/// Types of events in [MaskPlayerController].
enum MaskPlayerControllerEvent {
  initialize
}

/// [MaskPlayerController] player data, where media gets from assets.
class AssetsPlayerData {
  final String path;
  final String? maskPath;

  AssetsPlayerData({ required this.path, this.maskPath });
}

/// [MaskPlayerController] player data, where media gets from network.
class NetworkPlayerData {
  final String url;
  final String? headers;
  final String? maskUrl;
  final String? maskHeaders;

  NetworkPlayerData({ required this.url, this.headers, this.maskUrl, this.maskHeaders });
}

  /// Controller for the [MaskPlayer].
  ///
  /// Communicates with [MaskPlayer] using event messages [MaskPlayerControllerEvent].
class MaskPlayerController {
  final StreamController<MaskPlayerControllerEvent> _eventHandler = StreamController();

  bool _playing = false;
  bool _autoUpdateState = false;

  @protected AssetsPlayerData? assetsData;
  @protected NetworkPlayerData? networkData;

  /// Returns [Stream] with event messages.
  Stream<MaskPlayerControllerEvent> get events$ => _eventHandler.stream;

  /// Returns [bool] of playing state.
  bool get isPlaying => _playing;

  /// Returns true if auto update of the player is enabled
  ///
  /// Default value is false.
  bool get isAutoUpdates => _autoUpdateState;

  MaskPlayerController() {
    throw Exception("Please, use special constructors to create controller, b~b~baka!");
  }

  /// Constructor where media creates from assets.
  ///
  /// Used [AssetsPlayerData] to creates meta data of media.
  MaskPlayerController.assets(AssetsPlayerData assetsPlayerData) : assetsData = assetsPlayerData;

  /// Constructor where media create from network with get http request.
  ///
  /// Used [NetworkPlayerData] to creates meta data of media.
  MaskPlayerController.network(NetworkPlayerData networkPlayerData) : networkData = networkPlayerData;

  /// Magic function to update stream without update event state.
  ///
  /// Works if [isAutoUpdates] is true.
  void _updatePlayer() {
    if(isAutoUpdates) {
      _eventHandler.stream.last.then((event) => _eventHandler.add(event));
    }
  }

  /// Start media initialize.
  void initialize() {
    _eventHandler.add(MaskPlayerControllerEvent.initialize);
  }

  /// Starts playing the video.
  ///
  /// If you use [autoUpdatePlayer], [MaskPlayer] will update.
  /// If you don't use [autoUpdatePlayer], use [State.setState] to update [MaskPlayer].
  void play() {
    _playing = true;
    _updatePlayer();
  }

  /// Stop playing the video.
  ///
  /// If you use [autoUpdatePlayer], [MaskPlayer] will update.
  /// If you don't use [autoUpdatePlayer], use [State.setState] to update [MaskPlayer].
  void stop() {
    _playing = false;
    _updatePlayer();
  }

  /// Change auto update of the player state.
  ///
  /// This is necessary in order to:
  /// * Use the [MaskPlayer] in [StatelessWidget].
  /// * Don't use [State.setState] if [MaskPlayer] is in [State].
  void autoUpdatePlayer() =>
    _autoUpdateState = !_autoUpdateState;

  /// Stop controller works.
  void close() {
    _eventHandler.close();
  }
}

/// Video player with mask.
///
/// Uses [CustomPaint] to draw video.
/// First, he takes a frame of the video and draws it.
/// The video pixel will be drawn if it is white in the mask.
class MaskPlayer extends StatefulWidget {
  @protected final MaskPlayerController controller;
  @protected final Widget? uninitializedPlayerView;
  @protected final Widget? loadingPlayerView;

  /// [controller] is central thing of player.
  /// [controller] has type [MaskPlayerController].
  const MaskPlayer({
    required this.controller,
    this.uninitializedPlayerView,
    this.loadingPlayerView,
    Key? key,
  }) : super(key: key);

  @override
  _MaskPlayerState createState() => _MaskPlayerState();
}

class _MaskPlayerState extends State<MaskPlayer> {
  final GlobalKey _videoKey = GlobalKey();
  final GlobalKey _maskKey = GlobalKey();
  VideoPlayerController? _controller;
  VideoPlayerController? _maskController;


  StreamSubscription<MaskPlayerControllerEvent>? _controllerEventStreamSubscription;
  MaskPlayerControllerEvent? _currentEvent;

  @override
  void initState() {
    super.initState();

    widget.controller.events$.listen((event) {
      _currentEvent = event;
      setState(() {});
    });

    if(widget.controller.assetsData != null) {
      _controller = VideoPlayerController.network(widget.controller.assetsData!.path);
    } else if(widget.controller.networkData != null) {
      _controller = VideoPlayerController.network(widget.controller.networkData!.url);
    }

    // TODO: Create mask controller implementation.

    _controller!.initialize().then((value) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();

    _controllerEventStreamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    switch(_currentEvent) {
      case null:
        return widget.uninitializedPlayerView ?? Container();
      case MaskPlayerControllerEvent.initialize:
        return Stack(
          children: <Widget>[
            _controller != null ? Visibility(
              visible: false,
              key: _videoKey,
              child: VideoPlayer(_controller!),
            ) : Container(),
            _maskController != null ? Visibility(
              visible: false,
              key: _maskKey,
              child: VideoPlayer(_maskController!),
            ) : Container(),
            CustomPaint(
              painter: _VideoPainter(
                videoKey: _videoKey,
                maskKey: _maskKey,
              ),
            ),
          ],
        );
      default:
        throw UnimplementedError("If you that error, please create issue in github with this message. Controller event: $_currentEvent");
    }
  }
}

class _VideoPainter extends CustomPainter {
  @protected final GlobalKey videoKey;
  @protected final GlobalKey maskKey;

  _VideoPainter({ required this.videoKey, required this.maskKey });

  @override
  void paint(Canvas canvas, Size size) async {
    final boundary = videoKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if(boundary != null) {
      final image = await boundary.toImage();
      canvas.drawImage(image, Offset(boundary.size.width, boundary.size.height), Paint());
    }

    // TODO: Implements mask paint part.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}