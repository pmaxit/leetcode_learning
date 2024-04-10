import 'package:dotenv/dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';

class DBService{
  dynamic db, env;
  bool isConnected = false;
  DBService(){
    env = DotEnv();
    env.load();
  }

  Future connect() async{
    db = await Db.create(env['MONGO_URL']!);
    await db.open();

    print('Connected to database');
    isConnected = true;
  }

  Future close() async{
    await db.close();
    print('Connection closed');
  }

  Future insertOne(String collection, Map<String, dynamic> data) async{
    await db.collection(collection).insert(data);
    print('Data inserted');
  }

  Future insertOneWithStage(String collection, Map<String, dynamic> data, String stage) async{
    data['stage'] = stage;
    await db.collection(collection).insert(data);
    print('Data inserted');
  }

  Future insertMany(String collection, List<Map<String, dynamic>> data) async{
    await db.collection(collection).insertAll(data);
    print('Data inserted');
  }

  Future updateOne(String collection, Map<String, dynamic> query, Map<String, dynamic> data) async{
    // add to existing data 
    print('Updating data $data with query $query');
    List<Future> allUpdates = [];
    data.forEach((key, value) { 
      allUpdates.add(db.collection(collection).update(query, {r'$set': {key: value}}));
    });

    return Future.wait(allUpdates);
  }
   
  Future updateMany(String collection, Map<String, dynamic> query, Map<String, dynamic> data) async{
    await db.collection(collection).update(query, data, multiUpdate: true);

    print('Data updated');
  }

  Future deleteOne(String collection, Map<String, dynamic> query) async{
    await db.collection(collection).remove(query);

    print('Data deleted');
  }

  Future deleteMany(String collection, Map<String, dynamic> query) async{
    await db.collection(collection).remove(query, justOne: false);

    print('Data deleted');
  }

  void dropCollection(String collection) async{
    await db.collection(collection).drop();
    print('Collection dropped');
  }
  // find fuzzy data

  Future findAll(String collection, Map<String, dynamic> query) async{
    print(' Collection $collection Query $query');
    var data = await db.collection(collection).find(query).toList();
    return data;
  }

  
}