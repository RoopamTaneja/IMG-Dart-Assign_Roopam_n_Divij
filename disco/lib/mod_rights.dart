import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/checks.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/errors.dart';
import 'package:disco/models/mod.dart';

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
    parser.addOption('username', abbr: 'u', help: 'ADD USER');
    parser.addOption("server", abbr: "s", help: "SERVER RELATED RIGHTS");
    parser.addOption("channel", abbr: "c", help: "CHANNEL RELATED RIGHTS");
    final parsed = parser.parse(arguments);

    final server = parsed['server'];
    final username = parsed['username'];
    final channel = parsed['channel'];
    final currentUser = currentSession['username'];

    User userObj = User();
    await userObj.setUserData(currentUser, db);

    Checks errors = Checks();
    bool check = await errors.serverExists(server, db);

    if (!check) {
      ProcessError.ServerDoesNotExist(server);
    } else {
      //server exists
      Server currServer = Server();
      await currServer.setServerData(server, db);

      bool checkRole = errors.isMod(currServer, userObj);
      if (!checkRole) {
        //u are not mod or creator
        PermissionDeniedError.ModCreatorRight(server);
      } else {
        //now call different fns and pass different values as per need
        Moderator newMod = Moderator();
        await newMod.setUserData(currentUser, db);
        newMod.myServer = currServer;

        if (arguments[0] == "showEntrants") {
          newMod.showEntrants();
        } else if (arguments[0] == "admit") {
          await newMod.admit(username, db);
        } else if (arguments[0] == "remove") {
          await newMod.remove(username, channel, db);
        }
      }
    }
  }
  await db.close();
}
