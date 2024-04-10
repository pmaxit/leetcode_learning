import 'dart:math';

import 'package:leetcode/communities.dart';
import 'package:leetcode/community_solutions.dart';
import 'package:leetcode/problems.dart';
import 'package:leetcode/srs/card_manager.dart';
import 'package:leetcode/srs/cards.dart';
import 'package:leetcode/utils/task_execution.dart';
import 'package:leetcode_api_dart/leetcode_api_dart.dart';
import 'package:dotenv/dotenv.dart';

import 'db_utils.dart';

abstract class jsonSerializable{
  Map<String, dynamic> toJson();
}

class LCManager{
  final LeetcodeApiClient apiClient;
  late String collectionName;
  late String username;
  late DBService db;
  late CardManager cardManager;

  LCManager({required String session, required String csrfToken, this.collectionName='problems'})
      : apiClient = LeetcodeApiClient(session: session, csrfToken: csrfToken){
        db = DBService();
        cardManager = CardManager(db: db);
      }
  

  factory LCManager.fromEnv() {
    final env = DotEnv();
    env.load();

    return LCManager(
      session: env['LEETCODE_SESSION_TOKEN']!,
      csrfToken: env['LEETCODE_CSRF_TOKEN']!,
      collectionName: env['PROBLEM_COLLECTIONS']!,
    );
  }

  Future<List<dynamic>> getAllProblems(int totalProblems) async{
    
    int pageSize=20;
    if (totalProblems < pageSize){
      pageSize = totalProblems;
    }
    List<Future<dynamic>> allProblems = [];

    for (int i = 0; i < totalProblems; i+=pageSize){
      Future<dynamic> p = apiClient.getAllProblems(offset: i, pageSize: pageSize).then((value) => value.problems);
      allProblems.add(p);
    }
    return Future.wait(allProblems);
  }

  Future processEachProblem(List<LCProblem> problems) async{

    // get problem content

    // process community posts
    List<Future<dynamic>> allPosts = [];
    for (LCProblem problem in problems){
      Future<dynamic> p = getTopCommunityPostsByQuestionSlug(questionSlug: problem.titleSlug);
      allPosts.add(p);
    }
    return Future.wait(allPosts);
  }

  Future<List<dynamic>> saveAllproblems(List<LCProblem> problems) async{
    List<Map<String, dynamic>> data = problems.map((e) => e.toJson()).toList();
    await db.insertMany(collectionName, data);
    return data;
  }

  Future getTopCommunityPostsByQuestionSlug({required String questionSlug}) {
    return apiClient.getTopCommunityPosts(questionSlug: questionSlug, orderBy: "most_votes", languageTags: ["python3","python"]);
  }

  Future<List<dynamic>> getAllTopCommunityPostsByProblems({required List<LCProblem> problems}) async{
    
    // get the problem slug
    List<String> problemSlugs = problems.map((e) => e.titleSlug).toList();
    List<Future<dynamic>> allPosts = [];
    for (String slug in problemSlugs){
      Future<dynamic> p = getTopCommunityPostsByQuestionSlug(questionSlug: slug);
      allPosts.add(p);
    }
    return Future.wait(allPosts);
  }

  Future saveComments({required collectionName, required List<CommnityComment> comments}) async{
        List<Map<String, dynamic>> data = comments.map((e) => e.toJson()).toList();
    await db.insertMany(collectionName, data);
    return data;
  }

  Future saveOneObject({required collectionName, required jsonSerializable comment}) async{
    Map<String, dynamic> data = comment.toJson();
    await db.insertOne(collectionName, data);
    return data;
  }

  Future createStatusTable({required String collectionName, required List<LCProblem> problems}) async{
    List<Map<String, dynamic>> data = problems.map((e) => LCProblemStatus(
      titleSlug: e.titleSlug,
      title: e.title,
      status: LCProblemStatusEnum.initial,
    ).toJson()).toList();
    await db.insertMany(collectionName, data);
    return data;
  }  

  Future updateStatusTable({required String collectionName, required LCProblemStatus lcProblemStatus, required LCProblemStatusEnum status }) async{
    print('Updating status ${lcProblemStatus.titleSlug} to $status');
    Map<String, dynamic> query = {
      'titleSlug': lcProblemStatus.titleSlug,
    };
    Map<String, dynamic> data = {
      'status': status.toString(),
    };
    await db.updateOne(collectionName, query, {'status': status.toString()});
    return data;
  }

  Future orchestrate() async{
    // find all problems with initial status
    print('Orchestrating');
    var data =  await db.findAll('status', {'status': LCProblemStatusEnum.solutionsDownloaded.toString()});
    List<LCProblemStatus> problems = 
      List<LCProblemStatus>.from(data.map((e) => LCProblemStatus.fromJson(e)).toList());

    // for each problem get the top community posts
    List<Future<dynamic>> allPosts = [];
    // loop only first 10
    for(int i = 0; i < problems.length; i++){
      LCProblemStatus problem = problems[i];
      print('Processing ${problem.titleSlug}');

      Future<dynamic> p1 = apiClient.getTopCommunityPosts(questionSlug: problem.titleSlug, orderBy: "most_votes", languageTags: ["python3","python"])
        .then((value) => saveComments(collectionName: 'comments', comments: value))
        .then((value) => updateStatusTable(collectionName: 'status', lcProblemStatus: problem, status: LCProblemStatusEnum.communityPostsDownloaded))
        .then((value) => print('Completed processing ${problem.title}'))
      .catchError((e) => updateStatusTable(collectionName: 'status', lcProblemStatus: problem, status: LCProblemStatusEnum.failed));

      // get problem content
      // Future<dynamic> p2 = apiClient.getProblemContent(questionSlug: problem.titleSlug)
      //   .then((value) => db.updateOne('problems', {'titleSlug': problem.titleSlug}, value))
      //   .then((value) => updateStatusTable(collectionName: 'status', lcProblemStatus: problem, status: LCProblemStatusEnum.problemDownloaded))
      //   .then((value) => print('Completed processing ${problem.titleSlug}'))
      //   .catchError((e) => print('Failed to get content for ${problem.title} error:  $e'));

      // Future<dynamic> p3 = apiClient.getOfficialSolution(questionSlug: problem.titleSlug)
      //   .then((value) => db.updateOne('problems', {'titleSlug': problem.titleSlug}, value))
      //   .then((value) => updateStatusTable(collectionName: 'status', lcProblemStatus: problem, status: LCProblemStatusEnum.solutionsDownloaded))
      //   .then((value) => print('Completed processing ${problem.titleSlug}'))
      //   .catchError((e) => print('Failed to get content for ${problem.title} error:  $e'));
      // add time delay for each future
      //allPosts.add(Future.delayed(Duration(seconds: 1), () => p1));
      // get random number from 1 to 10
      
      int random = Random().nextInt(10);
      allPosts.add(Future.delayed(Duration(seconds: random), () => p1));
    }

  

    return Future.wait(allPosts);
  }

  Future getRandomCards(String topicTag, int count) async {
    var data = await db.findAll(collectionName, {'tags': topicTag});
    List<Card> problems = data.map((e) => Card.fromJson(e)).toList();
    List<Card> randomProblems = [];
    for (int i = 0; i < count; i++){
      int random = Random().nextInt(problems.length);
      randomProblems.add(problems[random]);
    }
    return randomProblems;
  }



  Future close() async{
    await db.close();
  }
}