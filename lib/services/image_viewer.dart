import 'package:flutter/material.dart';

class ImageGalleryViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageGalleryViewer({
    required this.images,
    required this.initialIndex,
    super.key,
  });

  @override
  State<ImageGalleryViewer> createState() => ImageGalleryViewerState();
}

class ImageGalleryViewerState extends State<ImageGalleryViewer> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                child: Center(child: Image.network(widget.images[index])),
              );
            },
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
