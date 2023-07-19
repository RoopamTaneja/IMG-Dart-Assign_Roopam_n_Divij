import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/checks.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/errors.dart';
import 'package:disco/models/sudo.dart';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  if (currentSession == null) {
    //if no user logged in then no point in moving ahead
    LoginError.NotLoggedIn();
  } else {
    final parser = ArgParser();
    //add all parser options here for all fns
    parser.addOption('owner',
        abbr: 'o', help: 'COMMANDS ONLY ACCESSIBLE TO SERVER OWNER');
    parser.addOption('username', abbr: 'u', help: 'ADD USER');
    parser.addOption("server",
        abbr: "s", help: "CREATE SERVER/CHANNEL WITHIN SERVER");
    final parsed = parser.parse(arguments);

    final command = parsed['owner'];
    final server = parsed['server'];
    final username = parsed['username'];

    User userObj = User();
    await userObj.setUserData(currentSession['username'], db);

    bool checkOwner = await Checks.isOwner(userObj, server, db);

    if (!checkOwner) {
      //u are not owner
      print('PermissionDeniedError : You Are Not The Creator Of $server');
    } else {
      Server currServer = Server();
      await currServer.setServerData(server, db);

      Sudo owner = Sudo();
      owner.myServer = currServer;

      //now call different fns and pass different values as per need
      if (command == "addMod") {
        await owner.addMod(username, db);
      } else if (command == "removeMod") {
        await owner.removeMod(username, db);
      } else {
        SyntaxError.noCommand();
      }
    }
  }
  db.close();
}
