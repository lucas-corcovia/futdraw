class ImgBbResult {
  final ImageData data;
  final bool success;
  final int status;

  ImgBbResult({
    required this.data,
    required this.success,
    required this.status,
  });

  factory ImgBbResult.fromJson(Map<String, dynamic> json) {
    return ImgBbResult(
      data: ImageData.fromJson(json['data']),
      success: json['success'],
      status: json['status'],
    );
  }
}

class ImageData {
  final String id;
  final String title;
  final String urlViewer;
  final String url;
  final String displayUrl;
  final int width;
  final int height;
  final int size;
  final int time;
  final int expiration;
  final ImageInfo image;
  final ImageInfo thumb;
  final String deleteUrl;

  ImageData({
    required this.id,
    required this.title,
    required this.urlViewer,
    required this.url,
    required this.displayUrl,
    required this.width,
    required this.height,
    required this.size,
    required this.time,
    required this.expiration,
    required this.image,
    required this.thumb,
    required this.deleteUrl,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      id: json['id'],
      title: json['title'],
      urlViewer: json['url_viewer'],
      url: json['url'],
      displayUrl: json['display_url'],
      width: json['width'],
      height: json['height'],
      size: json['size'],
      time: json['time'],
      expiration: json['expiration'],
      image: ImageInfo.fromJson(json['image']),
      thumb: ImageInfo.fromJson(json['thumb']),
      deleteUrl: json['delete_url'],
    );
  }
}

class ImageInfo {
  final String filename;
  final String name;
  final String mime;
  final String extension;
  final String url;

  ImageInfo({
    required this.filename,
    required this.name,
    required this.mime,
    required this.extension,
    required this.url,
  });

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      filename: json['filename'],
      name: json['name'],
      mime: json['mime'],
      extension: json['extension'],
      url: json['url'],
    );
  }
}
