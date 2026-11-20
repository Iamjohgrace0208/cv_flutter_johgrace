import 'package:material_ui/material_ui.dart';

Future<void> showPhotoGallery(
  BuildContext context, {
  required String personName,
  required List<String> photos,
  int initialIndex = 0,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _PhotoGalleryPage(
        personName: personName,
        photos: photos,
        initialIndex: initialIndex,
      ),
    ),
  );
}

class PhotoThumbnail extends StatelessWidget {
  const PhotoThumbnail({
    required this.personName,
    required this.photos,
    required this.index,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    super.key,
  });

  final String personName;
  final List<String> photos;
  final int index;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Ouvrir la galerie photo de $personName',
      child: GestureDetector(
        onTap: () => showPhotoGallery(
          context,
          personName: personName,
          photos: photos,
          initialIndex: index,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Image.asset(
            photos[index],
            width: width,
            height: height,
            fit: BoxFit.cover,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                return child;
              }
              return Container(
                width: width,
                height: height,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Icon(
                  Icons.photo_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              width: width,
              height: height,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: Icon(
                Icons.broken_image_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoGalleryPage extends StatefulWidget {
  const _PhotoGalleryPage({
    required this.personName,
    required this.photos,
    required this.initialIndex,
  });

  final String personName;
  final List<String> photos;
  final int initialIndex;

  @override
  State<_PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<_PhotoGalleryPage> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPhoto(int index) {
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.personName),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_currentIndex + 1} / ${widget.photos.length}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.photos.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) => Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Image.asset(
                    widget.photos[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white70,
                          size: 42,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Cette photo ne peut pas être affichée.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Photo précédente',
                    onPressed: _currentIndex == 0
                        ? null
                        : () => _showPhoto(_currentIndex - 1),
                    color: Colors.white,
                    disabledColor: Colors.white38,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Text(
                    'Photo ${_currentIndex + 1} sur ${widget.photos.length}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  IconButton(
                    tooltip: 'Photo suivante',
                    onPressed: _currentIndex == widget.photos.length - 1
                        ? null
                        : () => _showPhoto(_currentIndex + 1),
                    color: Colors.white,
                    disabledColor: Colors.white38,
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
