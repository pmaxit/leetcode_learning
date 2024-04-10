class CommnityComment{
  final int id;
  final int topicId;
  final int viewCount;
  final int topLevelCommentCount;
  final String title;
  final bool pinned;
  final List<dynamic> solutionTags;
  final String? content;
  final int creationDate;
  final String? status;
  final String questionSlug;
  

  CommnityComment({
    required this.id,
    required this.topicId,
    required this.viewCount,
    required this.topLevelCommentCount,
    required this.title,
    required this.pinned,
    required this.solutionTags,
    required this.content,
    required this.creationDate,
    required this.status,
    required this.questionSlug
  });

  factory CommnityComment.fromJson(Map<String, dynamic> json){
    return CommnityComment(
      id: json['id'],
      viewCount: json['viewCount'],
      topLevelCommentCount: json['topLevelCommentCount'],
      title: json['title'],
      pinned: json['pinned'],
      solutionTags: json['solutionTags'],
      content: json['post']['content'],
      creationDate: json['post']['creationDate'],
      topicId: json['post']['id'],
      status: json['post']['status'] ?? 'Unknown',
      questionSlug: json['questionSlug']
    );
  }

  @override
  String toString(){
    return 'CommnityComment: {topicId: $topicId, viewCount: $viewCount, topLevelCommentCount: $topLevelCommentCount, title: $title, pinned: $pinned, solutionTags: $solutionTags, creationDate: $creationDate, status: $status}';
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'topicId': topicId,
      'viewCount': viewCount,
      'topLevelCommentCount': topLevelCommentCount,
      'title': title,
      'pinned': pinned,
      'solutionTags': solutionTags,
      'content': content,
      'creationDate': creationDate,
      'status': status,
      'questionSlug': questionSlug
    };
  }
}