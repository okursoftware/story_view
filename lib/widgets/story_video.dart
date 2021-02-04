import 'dart:async';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

import '../utils.dart';
import '../controller/story_controller.dart';

class VideoLoader {
  String url;

  File videoFile;

  Map<String, dynamic> requestHeaders;

  LoadState state = LoadState.loading;

  VideoLoader(this.url, {this.requestHeaders});

  void loadVideo(VoidCallback onComplete) {
    /*  if (this.videoFile != null) {
      this.state = LoadState.success;
      onComplete();
    }

    final fileStream = DefaultCacheManager()
        .getFileStream(this.url, headers: this.requestHeaders);

    fileStream.listen((fileResponse) {
      if (fileResponse is FileInfo) {
        if (this.videoFile == null) {
          this.state = LoadState.success;
          this.videoFile = fileResponse.file;
          onComplete();
        }
      }
    });*/
    onComplete();
  }
}

class StoryVideo extends StatefulWidget {
  final StoryController storyController;
  final VideoLoader videoLoader;
  final String urlPath;
  StoryVideo(this.videoLoader, {this.storyController, this.urlPath, Key key})
      : super(key: key ?? UniqueKey());

  static StoryVideo url(String url,
      {StoryController controller,
      Map<String, dynamic> requestHeaders,
      Key key}) {
    return StoryVideo(
      VideoLoader(url, requestHeaders: requestHeaders),
      storyController: controller,
      urlPath: url,
      key: key,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return StoryVideoState();
  }
}

class StoryVideoState extends State<StoryVideo> {
  Future<void> playerLoader;

  StreamSubscription _streamSubscription;

  VideoPlayerController playerController;
  Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() {
    super.initState();
    print("video story initState()");
    widget.storyController.pause();

    widget.videoLoader.loadVideo(() {
      this.playerController =
          VideoPlayerController.network(widget.videoLoader.url);
      _initializeVideoPlayerFuture = this.playerController.initialize();

      /*  playerController.initialize().then((v) {
          if (mounted) {
            setState(() {});

            widget.storyController.play();
          }
        });*/

      if (widget.storyController != null) {
        _streamSubscription =
            widget.storyController.playbackNotifier.listen((playbackState) {
          if (playbackState == PlaybackState.pause) {
            playerController.pause();
          } else {
            playerController.play();
          }
        });
      }
    });
  }

  Widget getContentView() {
 
      return Center(
          child: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            this.playerController.play();
            widget.storyController.play();
            return AspectRatio(
              aspectRatio: this.playerController.value.aspectRatio,
              // Use the VideoPlayer widget to display the video.
              child: VideoPlayer(this.playerController),
            );
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return Center(child: CircularProgressIndicator());
          }
        },
      ));
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      height: double.infinity,
      width: double.infinity,
      child: getContentView(),
    );
  }

  @override
  void dispose() {
    print("video story void dispose() ");
    playerController?.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}
