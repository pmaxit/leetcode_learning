// create enm for topics
import 'package:leetcode_api_dart/models/problem.dart';

enum LCProblemStatusEnum{
  initial,
  problemDownloaded,
  solutionsDownloaded,
  communityPostsDownloaded,
  done, 
  completed,
  failed
}

class LCProblemStatus{
  final String titleSlug;
  final String title;
  final LCProblemStatusEnum status;

  LCProblemStatus({
    required this.titleSlug,
    required this.title,
    this.status =LCProblemStatusEnum.initial,
  });

  factory LCProblemStatus.fromJson(Map<String, dynamic> json){
    return LCProblemStatus(
      titleSlug: json['titleSlug'],
      title: json['title'],
      // convert string to enum
      status: LCProblemStatusEnum.values.firstWhere((e) => e.toString() == json['status']),
    );
  }
  // toJson
  Map<String, dynamic> toJson(){
    return {
      'titleSlug': titleSlug,
      'title': title,
      'status': status.toString(),
    };
  }
}
  


class LCProblem{
  final String title;
  final String difficulty;
  final String titleSlug;
  final String status;
  final int frontendQuestionId;
  final int questionId;
  final List<String> topicTags;
  final String acRate;
  final String? content;
  final Map<String, dynamic>? officialSolution;

  LCProblem({
    required this.title,
    required this.difficulty,
    required this.titleSlug,
    required this.status,
    required this.frontendQuestionId,
    required this.questionId,
    required this.topicTags,
    required this.acRate,
    this.content,
    this.officialSolution
  });

  static LCProblem fromProblem(Problem problem){
    return LCProblem(
      title: problem.title,
      difficulty: problem.difficulty.toString(),
      titleSlug: problem.titleSlug,
      status: problem.status ?? 'Unknown',
      frontendQuestionId: int.parse(problem.frontendQuestionId),
      questionId: int.parse(problem.questionId),
      topicTags: problem.topicTags.map((e) => e.name).toList(),
      acRate: problem.acRate.toString()
    );
  }

  factory LCProblem.fromJson(Map<String, dynamic> json){
    print('json: $json  ');
    return LCProblem(
      title: json['title'],
      difficulty: json['difficulty'],
      titleSlug: json['titleSlug'],
      status: json['status'] ?? 'Unknown',
      frontendQuestionId: json['frontend_question_id'],
      questionId: json['question_id'],
      topicTags: List<String>.from(json['topic_tag']),
      acRate: json['acRate'],
    );
  }

  // to String
  @override
  String toString(){
    return 'Problem: {title: $title, difficulty: $difficulty, titleSlug: $titleSlug, status: $status, frontendQuestionId: $frontendQuestionId, questionId: $questionId, topicTags: $topicTags, acRate: $acRate}';
  }

  Map<String, dynamic> toJson(){
    return {
      'title': title,
      'difficulty': difficulty,
      'titleSlug': titleSlug,
      'status': status,
      'frontend_question_id': frontendQuestionId,
      'question_id': questionId,
      'topic_tag': topicTags,
      'acRate': acRate,
    };
  }

}