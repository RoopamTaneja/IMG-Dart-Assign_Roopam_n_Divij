import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/errors.dart';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  final users = db.collection('userAuth');
  final servers = db.collection('servers');
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

    final currentUser =
        await users.findOne(where.eq('username', currentSession['username']));
    String userID = currentUser?['_id'];

    var checkOwner = await servers
        .find(where.eq('serverName', server).eq('userId', userID))
        .isEmpty;

    if (checkOwner) {
      //u are not owner
      print('Permission Denied : You are not the owner of $server');
    } else {
      var serverCurr = await servers.findOne(where.eq('serverName', server));

      //now call different fns and pass different values as per need
      if (command == "addMod") {
        await addMod(users, servers, server, serverCurr, username);
      } else if (command == "removeMod") {
        await removeMod(users, servers, server, serverCurr, username);
      } else {
        print("SyntaxError : No such command exists");
      }
    }
  }
  db.close();
}

Future addMod(users, servers, server, serverCurr, username) async {
  //dart bin/disco.dart sudo -o addMod -u username -s servername

  //server exists bcoz i'm its owner
  var role = serverCurr['roles'][username];
  if (role == 'peasant') {
    //user is peasant so make him mod

    await servers.update(where.eq('serverName', server),
        modify.set('roles.$username', 'moderator'));
    print("$username Added as Moderator of $server Successfully.");
  } else {
    //else that is not possible (for null, mod, creator etc)

    print("UpdationError : Promotion Not Possible.");
  }
}

Future removeMod(users, servers, server, serverCurr, username) async {
  //dart bin/disco.dart sudo -o removeMod -u username -s servername

  //server exists bcoz i'm its owner
  var role = serverCurr['roles'][username];
  if (role == "moderator") {
    //user is mod so make him peasant

    await servers.update(where.eq('serverName', server),
        modify.set('roles.$username', 'peasant'));
    print("$username Removed as Moderator of $server Successfully.");
  } else {
    //else that is not possible (for null, peasant, creator etc)

    print("UpdationError : Demotion Not Possible.");
  }
}
