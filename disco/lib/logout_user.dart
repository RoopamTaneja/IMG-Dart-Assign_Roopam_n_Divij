import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/testDB');
  await db.open();
  final userSessions = db.collection('user_sessions');

  final parser = ArgParser();
  parser.addOption('username', abbr: 'u', help: 'ADD USER');
  final parsed = parser.parse(arguments);
  String username = parsed['username'] as String;

  final userSession =
      await userSessions.findOne(where.match('username', username));
  if (userSession == null) {
    print('User not logged in : failure');
  } else {
    await userSessions.remove(userSession);
    print('logout success');
  }
  await db.close();
}
