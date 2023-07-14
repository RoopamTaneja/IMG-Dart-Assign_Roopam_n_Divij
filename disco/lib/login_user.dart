import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/user.dart';

void main(List<String> arguments) async {
  //creating new instance of database server
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  final users = db.collection('userAuth');
  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  //checking for any login
  if (currentSession == null) {
    //evaluating command line arguments
    final parser = ArgParser();
    parser.addOption('username', abbr: 'u', help: 'LOGIN USER');
    final parsed = parser.parse(arguments);
    String username = parsed['username'] as String;

    User userObj = User();
    await userObj.login(username, users, userSessions);
  } else {
    //checking if some user is already logged in

    String username = currentSession['username'];
    print('DuplicacyError : $username Already Logged In');
  }
  await db.close();
}
