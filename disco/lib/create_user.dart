import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main(List<String> arguments) async {
  final parser = ArgParser();

  parser.addOption('username', abbr: 'u', help: 'ADD USER');

  final parsed = parser.parse(arguments);

  String username = parsed['username'] as String;
  print(username);
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  final collection = db.collection('mycollection');
  final document = {'username': username};
  final result =
      await collection.insert(document..['_id'] = ObjectId().toHexString());
  print(result);
}
