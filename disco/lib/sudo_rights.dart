import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:core';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  final users = db.collection('userAuth');
  final servers = db.collection('servers');
  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  if (currentSession == null) {
    //if no user logged in then no point in moving ahead
    print('LoginError : No User Logged In');
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
    if (command == "showMod") {
      await showMods(servers, server);
    } else if (checkOwner) {
      //u are not owner
      print('Permission Denied : You are not the owner of $server');
    } else {
      //now call different fns and pass different values as per need
      if (command == "addMod") {
        await addMod(users, servers, server, username);
      } else if (command == "removeMod") {
        await removeMod(users, servers, server, username);
      }
    }
  }
  db.close();
}

Future showMods(DbCollection servers, server) async {
  //dart bin/disco.dart sudo -o showMod -s servername

  var check = await servers.find(where.eq('serverName', server)).isEmpty;

  if (check) {
    print('ServerError: Server Does Not Exist');
    return;
  } else {
    //server exists
    var serverDoc = await servers.findOne(where.eq('serverName', server));
    if (serverDoc == null) {
      print('ServerError: Server does Not Exist');
      return;
    }
    Map<String, dynamic> role = serverDoc['roles'];

    print('List of moderators : ');
    for (String i in role.keys) {
      if (role[i] == 'moderator') {
        print(i);
      }
    }
  }
}

Future addMod(
    DbCollection users, DbCollection servers, server, username) async {
  //dart bin/disco.dart sudo -o addMod -s servername -u username

  var check = await servers.find(where.eq('serverName', server)).isEmpty;

  if (check) {
    print('ServerError: Server Does Not Exist');
    return;
  } else {
    //server exists
    var checkUser = await users.find(where.eq('username', username)).isEmpty;
    if (checkUser) {
      print('User Not Found');
      return;
    } else {
      //user also exists, so add him to mods list
      servers.update(where.eq('serverName', server),
          modify.set('roles.$username', 'moderator'));
      print("$username added as moderator of $server successfully.");
    }
  }
}

Future removeMod(
    DbCollection users, DbCollection servers, server, username) async {
  var check = await servers.find(where.eq('serverName', server)).isEmpty;

  if (check) {
    print('ServerError: Server Does Not Exist');
    return;
  } else {
    //server exists
    var checkUser = await users.find(where.eq('username', username)).isEmpty;
    if (checkUser) {
      print('User Not Found');
      return;
    } else {
      //user also exists, so add him to mods list
      servers.update(where.eq('serverName', server),
          modify.set('roles.$username', 'peasant'));
      print("$username added as moderator of $server successfully.");
    }
  }
}
