import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/checks.dart';

void main(List<String> arguments) async {
  //creating a new instance of the database server
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  //checking for any instance of login from the database
  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  if (currentSession == null) {
    //evaluating the command line arguments
    final parser = ArgParser();
    parser.addOption('username', abbr: 'u', help: 'ADD USER');
    final parsed = parser.parse(arguments);
    String username = parsed['username'] as String;

    //registering the user in database USERAUTH
    final userAuth = db.collection('userAuth');
    Checks errors = Checks();
    bool userExists = await errors.userExists(username, userAuth);

    //only registering if user does not exist
    if (!userExists) {
      User userObj = User();
      await userObj.register(username, userAuth);
    } else {
      print('DuplicacyError : User Already Exists');
    }
  } else {
    String username = currentSession['username'];
    print('DuplicacyError : $username already logged in');
  }

  await db.close();
}
