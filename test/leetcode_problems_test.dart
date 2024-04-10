import 'package:leetcode_api_dart/leetcode_api_dart.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main(){
  group('Problem related endpoints', (){
    final api = getLeetcodeClient();
    test('Get all problems', () async {
      final problems = await api.getAllProblems(offset: 0, pageSize: 20);
      print('All problems $problems');
      expect(true, problems.problems.isNotEmpty);
    });
  
    test('Get Problem by topic', () async {
      const topicTag = 'dynamic-programming';
      final byTopic = await api.getProblemsByTopic(topicTag: topicTag);
      print('Problems by topic $byTopic');
      expect(true, byTopic.questions.isNotEmpty);
    });

    test('Should get Top Interview problems', () async {
      final problems = await api.getTopInterviewProblems(offset: 0, pageSize: 20);
      print('top interview problems $problems');
      expect(true, problems.problems.isNotEmpty);
    });
  });
}