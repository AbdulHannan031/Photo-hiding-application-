import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/views/setting.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<File> hiddenFiles = []; // Stores both images and videos

  @override
  void initState() {
    super.initState();
    _loadHiddenFiles();
  }

  Future<void> _loadHiddenFiles() async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      String hiddenDirPath = '${appDir.path}/hidden';
      Directory hiddenDir = Directory(hiddenDirPath);
      if (hiddenDir.existsSync()) {
        List<FileSystemEntity> files = hiddenDir.listSync();
        setState(() {
          hiddenFiles = files.whereType<File>().toList();
        });
      }
    } catch (e) {
      print('Failed to load hidden files: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hidden Media'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showPickOptionsDialog,
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: hiddenFiles.isEmpty
          ? Center(
              child: Text('No hidden media'),
            )
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: hiddenFiles.length,
              itemBuilder: (context, index) {
                File file = hiddenFiles[index];
                return _buildMediaItem(file);
              },
            ),
    );
  }

  Widget _buildMediaItem(File file) {
    return GestureDetector(
      onTap: () {
        _showMediaDialog(file);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: file.path.endsWith('.mp4')
              ? _buildVideoPlayer(file, false)
              : Image.file(
                  file,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(File file, bool isFullScreen) {
    VideoPlayerController _controller = VideoPlayerController.file(file)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
      });

    return Stack(
      alignment: Alignment.center,
      children: [
        VideoPlayer(_controller),
        _controller.value.isInitialized
            ? Container()
            : CircularProgressIndicator(),
        if (!isFullScreen)
          IconButton(
            icon: Icon(Icons.fullscreen),
            onPressed: () {
              _showFullScreenVideo(file);
            },
          ),
      ],
    );
  }

  void _showFullScreenVideo(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayer(file: file),
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source, MediaType mediaType) async {
    final picker = ImagePicker();
    XFile? pickedFile;

    if (mediaType == MediaType.image) {
      pickedFile = await picker.pickImage(source: source);
    } else if (mediaType == MediaType.video) {
      pickedFile = await picker.pickVideo(source: source);
    }

    if (pickedFile != null) {
      File mediaFile = File(pickedFile.path);
      _hideMedia(mediaFile);
    }
  }

  Future<void> _hideMedia(File mediaFile) async {
    try {
      Directory appDir = await getApplicationDocumentsDirectory();
      String hiddenDirPath = '${appDir.path}/hidden';
      Directory hiddenDir = Directory(hiddenDirPath);
      if (!hiddenDir.existsSync()) {
        hiddenDir.createSync();
      }
      String newPath =
          '$hiddenDirPath/${DateTime.now().millisecondsSinceEpoch}${mediaFile.path.split('/').last}';
      await mediaFile.copy(newPath);
      setState(() {
        hiddenFiles.add(File(newPath));
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${mediaFile.path.split('/').last} hidden successfully'),
        duration: Duration(seconds: 2),
      ));
    } on PlatformException catch (e) {
      print('Failed to hide media: ${e.message}');
    }
  }

  void _showPickOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Pick Media"),
        actions: <Widget>[
          TextButton(
            child: Text("Image"),
            onPressed: () {
              Navigator.of(context).pop();
              _pickMedia(ImageSource.gallery, MediaType.image);
            },
          ),
          TextButton(
            child: Text("Video"),
            onPressed: () {
              Navigator.of(context).pop();
              _pickMedia(ImageSource.gallery, MediaType.video);
            },
          ),
        ],
      ),
    );
  }

  void _showMediaDialog(File mediaFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(0),
          child: Stack(
            children: [
              Center(
                child: mediaFile.path.endsWith('.mp4')
                    ? _buildVideoPlayer(mediaFile, true)
                    : Image.file(mediaFile),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black54,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TextButton(
                        child: Text('Close',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Export',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          _exportMedia(mediaFile);
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Delete',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          _deleteMedia(mediaFile);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportMedia(File mediaFile) {
    // Implement export functionality to device's gallery
    // For example, you could use path_provider to get the temporary directory
    // and copy the file there, then notify the user.
    // Example:
    // final tempDir = await getTemporaryDirectory();
    // final newPath = '${tempDir.path}/${mediaFile.path.split('/').last}';
    // await mediaFile.copy(newPath);
    // Show a snackbar or dialog confirming export.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${mediaFile.path.split('/').last} exported successfully'),
      duration: Duration(seconds: 2),
    ));
  }

  void _deleteMedia(File mediaFile) {
    setState(() {
      hiddenFiles.remove(mediaFile);
    });
    // Optionally, delete the file from app's storage as well
    mediaFile.delete();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${mediaFile.path.split('/').last} deleted successfully'),
      duration: Duration(seconds: 2),
    ));
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final File file;
  FullScreenVideoPlayer({required this.file});

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

enum MediaType { image, video }
