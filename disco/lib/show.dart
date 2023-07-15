import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/checks.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/server.dart';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  final servers = db.collection('servers');
  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  if (arguments[0] == "showServers") {
    //show servers irrespective logged in or not
    await showServers(servers);
  } else if (currentSession == null) {
    //if no user logged in then no point in moving ahead
    print('LoginError : No User Logged In');
  } else {
    final parser = ArgParser();
    //add all parser options here for all fns
    parser.addOption("server", abbr: "s", help: "SERVER RELATED RIGHTS");
    final parsed = parser.parse(arguments);
    final server = parsed['server'];

    final currentUser = currentSession['username'];
    User userObj = User();
    await userObj.setUserData(currentUser, db);

    Checks errors = Checks();
    bool check = await errors.serverExists(server, db);
    if (!check) {
      print('ServerError : No Such Server');
    } else {
      //server exists

      Server currServer = Server();
      await currServer.setServerData(server, db);

      if (arguments[0] == "showMods") {
        //mods can be seen by non members also

        currServer.showMods();
      } else if (arguments[0] == "showChannels") {
        //channels can be seen by non members also

        await currServer.showChannels(db);
      }
    }
  }
  await db.close();
}

Future showServers(DbCollection servers) async {
  List serverNames =
      await servers.find().map((doc) => doc['serverName']).toList();
  if (serverNames.isEmpty) {
    print("No Servers Yet.");
  } else {
    print("List of Servers : ");
    for (String i in serverNames) {
      print(i);
    }
  }
}
