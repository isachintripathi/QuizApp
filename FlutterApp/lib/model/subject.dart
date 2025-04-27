// Helper Subject class for CategoryMaterialScreen
class Subject {
  final String id;
  final String name;
  final List<String> pdfs;
  final List<String> docs;
  final List<String> videos;

  Subject({
    required this.id,
    required this.name,
    this.pdfs = const [],
    this.docs = const [],
    this.videos = const []
  });
}