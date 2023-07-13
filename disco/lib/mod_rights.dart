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
    parser.addOption('username', abbr: 'u', help: 'ADD USER');
    parser.addOption("server",
        abbr: "s", help: "CREATE SERVER/CHANNEL WITHIN SERVER");

    final parsed = parser.parse(arguments);
    final server = parsed['server'];
    final username = parsed['username'];

    var checkMod = await servers
        .find(where
            .eq('serverName', server)
            .eq('mods', currentSession['username']))
        .isEmpty;

    if (checkMod) {
      //u are not mod
      print('Permission Denied : You are not a moderator of $server');
    } else {
      //now call different fns and pass different values as per need
      if (arguments[0] == "admit") {
        await admit(users, servers, server, username);
      } else if (arguments[0] == "show") {
        await show(servers, server);
      }
    }
  }
  db.close();
}

Future show(DbCollection servers, server) async {
  //dart bin/disco.dart show -s servername

  var check = await servers.find(where.eq('serverName', server)).isEmpty;

  if (check) {
    print('ServerError: Server Does Not Exist');
    return;
  } else {
    //server exists
    var serverDoc = await servers.findOne(where.eq('serverName', server));
    var arr = serverDoc?['inQueue'];
    print('List of users waiting for approval to join : ');
    for (String i in arr) {
      print(i);
    }
  }
}

Future admit(DbCollection users, DbCollection servers, server, username) async {
  //dart bin/disco.dart admit -u username -s servername

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
      //user also exists, so add him to allMembers list
      final currentUser = await users.findOne(where.eq('username', username));
      final userID = currentUser?['_id'];
      servers.update(where.eq('serverName', server),
          modify.push('allMembers', {username: userID}));
      servers.update(
          where.eq('serverName', server), modify.pull('inQueue', username));
      print("$username added as member of $server successfully.");
    }
  }
}
