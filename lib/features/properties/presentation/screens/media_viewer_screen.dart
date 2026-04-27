import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';

class MediaViewerScreen extends StatefulWidget {
  final String url;
  final String mediaType; // 'video' or 'panorama'

  const MediaViewerScreen({super.key, required this.url, required this.mediaType});

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.mediaType == 'video') {
      _initializeVideo();
    } else {
      _isLoading = false; // Panorama loads its own way
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await _videoPlayerController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.primaryBlue,
          handleColor: AppTheme.primaryBlue,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white24,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.mediaType == 'panorama' ? '360° Virtual Tour' : 'Video Walkthrough',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.info, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text('Failed to load media.', style: TextStyle(color: Colors.white)),
        ],
      );
    }

    if (_isLoading) {
      return CircularProgressIndicator(color: AppTheme.primaryBlue);
    }

    if (widget.mediaType == 'panorama') {
      return PanoramaViewer(
        animSpeed: 1.0,
        sensorControl: SensorControl.orientation,
        child: Image.network(widget.url),
      );
    } else if (widget.mediaType == 'video' && _chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    return const SizedBox.shrink();
  }
}
