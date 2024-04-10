import 'package:leetcode/problems.dart';

import '../communities.dart';
import '../db_utils.dart';
import 'cards.dart';

class CardManager{
  final DBService db;

  CardManager({required this.db});

  // get cards from DB
  Future<List<Card>> getAllCards() async{
    List<Map<String, dynamic>> cardMaps = await db.findAll('cards', {});
    return cardMaps.map((e) => Card.fromJson(e)).toList();
  }



  Future<void> updateCard(Card card) async{
    return db.updateOne('cards', {'id': card.id}, card.toJson());
  }

  String createFrontCard(LCProblem problem){
    String problemContent = problem.content ?? '';
    String title = problem.title;
    String front = title + '\n' + problemContent;
    return front;
  }

  String createBackCard(LCProblem problem){
    String back = problem.content ?? '';
    return back;
  }

  Card createCardFromProblem(LCProblem problem, List<CommnityComment> comments ) {

    Card card = Card(front: createFrontCard(problem), back: createBackCard(problem) , tags: problem.topicTags.join(', '),
      frontMetadata: problem, backMetadata: comments);
    return card;
  }

  Future insertCardsFromProblem(List<LCProblem> problems, List<CommnityComment> comments){
    List<Card> cards = [];
    for (int i = 0; i < problems.length; i++){
      // filter comments
      List<CommnityComment> problemComments = comments.where((element) => element.questionSlug == problems[i].titleSlug).toList();
      cards.add(createCardFromProblem(problems[i], problemComments));
    }
    return db.insertMany('cards', cards.map((e) => e.toJson()).toList());
  }

}