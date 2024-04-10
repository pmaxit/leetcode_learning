import 'dart:core';

class Card{
  late int id;
  final String front;
  Map<String, dynamic> frontMetadata = {};
  final String back;
  List<dynamic> backMetadata = [] ;
  final String? hint;
  final String? source;
  final String? tags;

  Card({required this.front, required this.back, this.hint, this.source, this.tags, this.id=0, frontMetadata, backMetadata}){
    // generateid
    id = front.hashCode + back.hashCode;
  }

  factory Card.fromJson(Map<String, dynamic> json){
    return Card(
      id: json['id'],
      front: json['front'],
      back: json['back'],
      hint: json['hint'],
      source: json['source'],
      tags: json['tags'],
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'front': front,
      'back': back,
      'hint': hint,
      'source': source,
      'tags': tags,
    };
  }
}