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

    var serverCurr = await servers.findOne(where.eq('serverName', server));

    if (serverCurr == null) {
      print('ServerErorr : No Such Server');
    } else {
      var role = serverCurr['roles'][currentSession['username']];

      if (role == null) {
        //u are not mod
        print('Permission Denied : You are not a moderator of $server');
      } else if (role == 'creator') {
        //now call different fns and pass different values as per need
        if (arguments[0] == "admit") {
          await admit(users, servers, server, username, serverCurr);
        } else if (arguments[0] == "show") {
          show(serverCurr);
        }
      }
    }
  }
  await db.close();
}

void show(server) {
  //dart bin/disco.dart show -s servername

  List arr = server['inQueue'];
  if (arr.isEmpty) {
    //if empty list
    print('No users waiting for approval');
  } else {
    print('List of users waiting for approval to join : ');
    for (String i in arr) {
      print(i);
    }
  }
}

Future admit(users, servers, server, username, serverCurr) async {
  //dart bin/disco.dart admit -u username -s servername

  //server exists
  var checkUser = await users.find(where.eq('username', username)).isEmpty;

  if (checkUser) {
    print('User Not Found');
    return;
  } else {
    //user also exists, so add him to allMembers list

    final currentUser = await users.findOne(where.eq('username', username));
    final userID = currentUser?['_id'];
    var role = serverCurr['roles'][username];
    if (role != null) {
      print('ServerError : User already in Server');
      return;
    }
    servers.update(where.eq('serverName', server),
        modify.push('allMembers', {username: userID}));
    servers.update(
        where.eq('serverName', server), modify.pull('inQueue', username));
    servers.update(where.eq('serverName', server),
        modify.set('roles.$username', 'peasant'));
    print("$username added as member of $server successfully.");
  }
}
