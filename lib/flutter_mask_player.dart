library flutter_mask_player;

import 'dart:async';

import 'package:flutter/widgets.dart';

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
  ///
  /// 1) Use the [MaskPlayer] in [StatelessWidget].
  ///
  /// 2) Don't use [State.setState] if [MaskPlayer] is in [State].
  void autoUpdatePlayer() =>
    _autoUpdateState = !_autoUpdateState;

  /// Stop controller works.
  void close() {
    _eventHandler.close();
  }
}

/// Video player with mask.
///
/// Uses [Canvas] to draw video.
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
  final GlobalKey _repaintKey = GlobalKey();

  StreamSubscription<MaskPlayerControllerEvent>? _controllerEventStreamSubscription;
  MaskPlayerControllerEvent? _currentEvent;

  @override
  void initState() {
    super.initState();

    widget.controller.events$.listen((event) {
      _currentEvent = event;
      setState(() {});
    });
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
        throw UnimplementedError("Please, implement initialize event");
      default:
        throw UnimplementedError("If you that error, please create issue in github with this message. Controller event: $_currentEvent");
    }
  }
}
