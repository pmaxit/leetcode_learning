import 'cards.dart';

enum CardType{
  NEW,
  LEARNING,
  REVIEW
}
class LearningCard{
  final int cardId;
  int quality = 0;
  int currentInterval = 0;
  double currentEasiness = 2.5;
  DateTime lastReview = DateTime.now();
  CardType type;
  

  LearningCard({required this.cardId, required this.currentInterval, required this.currentEasiness,  this.lastReview, this.type = CardType.NEW});

  factory LearningCard.fromJson(Map<String, dynamic> json){
    return LearningCard(
      cardId: json['cardId'],
      currentInterval: json['current_interval'],
      currentEasiness: json['current_easiness'],
      type: CardType.values[json['type']],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'cardId': cardId,
      'current_interval': currentInterval,
      'current_easiness': currentEasiness,
      'type': type.index,
    };
  }

  void updateEasiness(int quality){

    // SuperMemo 2 algorithm

    final double newEasiness = (currentEasiness - 0.8 + 0.28 * quality - 0.02 * quality * quality);
    
    if (newEasiness < 1.3){
      currentEasiness = 1.3;
    } else {
      currentEasiness = newEasiness;
    }
  }
  
  int getNextIntervalByQuality(int quality, int currentInterval){
    if (quality < 3){
      return 0;
    } else if (quality < 4){
      return 1;
    } else {
      return (currentInterval * currentEasiness).round();
    }
  }

  void updateInterval(int quality){
    currentInterval = getNextIntervalByQuality(quality, currentInterval);
  }

  void updateType(int quality){
    if (quality < 4){
      type = CardType.LEARNING;
    } else {
      type = CardType.REVIEW;
    }

  }

  void updateCard(int quality){
    updateEasiness(quality);
    updateInterval(quality);
    updateType(quality);

    lastReview = DateTime.now();
    this.quality = quality;
  }

  void resetCard(){
    currentInterval = 0;
    currentEasiness = 2.5;
    type = CardType.NEW;
  }


  DateTime getNextDueDate(int steps){
    int currentQuality = quality;
    int newInterval = currentInterval;
    while (steps > 0){
      newInterval = getNextIntervalByQuality(currentQuality, newInterval);
      steps--;
    }
    return lastReview.add(Duration(days: newInterval));
  }
}

// how to use this class
// LearningCard card = LearningCard(card: Card(front: 'front', back: 'back'), current_interval: 0, current_easiness: 2.5, type: CardType.NEW);
// card.updateCard(5);

