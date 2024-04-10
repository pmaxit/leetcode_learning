import 'package:leetcode/LCManager.dart';
import 'package:leetcode/communities.dart';
import 'package:leetcode/problems.dart';

Future<void> callAPI(LCManager lcmanager, int count) async{
  // Call the LeetCode API here
  List<LCProblem> problems = await lcmanager.getAllProblems(count).then((value) => value.expand((element) => element).toList())
    .then((problems) => problems.map((e) => LCProblem.fromProblem(e)).toList());
  
  //await lcmanager.saveAllproblems(problems).then((value) => lcmanager.createStatusTable(collectionName: 'status', problems: problems));

  await lcmanager.orchestrate();

  //print(problems);
  //await lcmanager.saveAllproblems(problems);
  //var value = await lcmanager.getCommunityComments(param: '');
  // var comments = await lcmanager.getAllTopCommunityPostsByProblems(problems: problems);
  // // unnest the list of lists
  // List<CommnityComment> listComments = comments.expand((element) => element).toList().map((e) => e as CommnityComment).toList();
  // // print type of comments element
  // await lcmanager.saveAllObjects(collectionName: 'comments', comments: listComments);
}