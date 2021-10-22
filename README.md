<h1 align="center">Video player for flutter with mask</h1>

## Features

This package is designed to play masked videos.

## Getting started

### Installation

---
First, add `flutter_mask_player` as a  [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/packages-and-plugins/using-packages).

This package uses video_player as a base. Its customization spec:

#### iOS

This plugin requires iOS 9.0 or higher. Add the following entry to your Info.plist file, located in `<project root>/ios/Runner/Info.plist`:
```plist
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```
This entry allows your app to access video files by URL.

#### Android

Ensure the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
The Flutter project template adds it, so it may already be there.

#### Web

This plugin compiles for the web platform since version `0.10.5`, in recent enough versions of Flutter (`>=1.12.13+hotfix.4`).

> The Web platform does not suppport dart:io, so avoid using the VideoPlayerController.file constructor for the plugin. 
> Using the constructor attempts to create a VideoPlayerController.file that will throw an UnimplementedError.

### Supported Formats

* On iOS, the backing player is [AVPlayer](https://developer.apple.com/documentation/avfoundation/avplayer). 
The supported formats vary depending on the version of iOS, 
[AVURLAsset](https://developer.apple.com/documentation/avfoundation/avurlasset) 
class has 
[audiovisualTypes](https://developer.apple.com/documentation/avfoundation/avurlasset/1386800-audiovisualtypes?language=objc) 
that you can query for supported av formats.

* On Android, the backing player is [ExoPlayer](https://exoplayer.dev/), 
please refer [here](https://exoplayer.dev/supported-formats.html) for list of supported formats

* On Web, available formats depend on your users' browsers (vendor and version). 
Check [package:video_player_web](https://pub.dev/packages/video_player_web) for more specific information.
  
## Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter_mask_player/flutter_mask_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final MaskPlayerController _controller = MaskPlayerController.assets(
    AssetsPlayerData(
      path: "assets/video/video.mp4",
      maskPath: "assets/video/mask.mp4",
    ),
  );

  MyHomePage({Key? key, required this.title}) : super(key: key) {
    _controller.autoUpdatePlayer() // Required in StatelessWidget.
      ..initialize()
      ..play();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: MaskPlayer(
          controller: _controller,
          loadingPlayerView: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
```

## Additional information

Package develops for neuro-city company, but this is fully open source project.

Please report bugs and shortcomings. I would be very grateful for your pull requests
