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

  if (arguments[0] == "showServers") {
    await showServers(servers);
  } else if (currentSession == null) {
    //if no user logged in then no point in moving ahead
    print('LoginError : No User Logged In');
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
    var serverCurr = await servers.findOne(where.eq('serverName', server));
    final currentUser = currentSession['username'];

    if (serverCurr == null) {
      print('ServerError : No Such Server');
    } else {
      var role = serverCurr['roles'][currentSession['username']];

      if (arguments[0] == "showMods") {
        //mods can be seen by non members also

        showMods(serverCurr);
      } else if (arguments[0] == "showChannels") {
        var serverCurrent = db.collection(server);
        await showChannels(serverCurrent);
      } else if (role != 'creator' && role != 'moderator') {
        //u are not mod or creator
        print(
            'Permission Denied : You are not a moderator or creator of $server');
      } else if (role == 'creator' || role == 'moderator') {
        //now call different fns and pass different values as per need

        if (arguments[0] == "admit") {
          await admit(users, servers, server, username, serverCurr, channel);
        } else if (arguments[0] == "showEntrants") {
          showEntrants(serverCurr);
        } else if (arguments[0] == "remove") {
          var serverCurrent = db.collection(server);
          await remove(users, servers, server, serverCurrent, username, channel,
              role, currentUser);
        }
      }
    }
  }
  await db.close();
}

Future showServers(servers) async {
  List serverName =
      await servers.find().map((doc) => doc['serverName']).toList();
  for (String i in serverName) {
    print(i);
  }
}

Future showChannels(serverCurrent) async {
  List channelNames =
      await serverCurrent.find().map((doc) => doc['channelName']).toList();
  for (String i in channelNames) {
    print(i);
  }
}

void showEntrants(server) {
  //dart bin/disco.dart showEntrants -s servername

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

Future admit(users, servers, server, username, serverCurr, channel) async {
  //dart bin/disco.dart admit -u username -s servername

  //server exists
  var checkUser = await users.find(where.eq('username', username)).isEmpty;

  if (checkUser) {
    //user does not exist
    print('User Not Found');
    return;
  } else {
    //user exists
    //check if already a member
    final currentUser = await users.findOne(where.eq('username', username));
    final userID = currentUser?['_id'];
    var role = serverCurr['roles'][username];
    if (role != null) {
      //yes already member
      print('ServerError : User already in Server');
      return;
    }
    //no he is not so make him a member
    await servers.update(where.eq('serverName', server),
        modify.push('allMembers', {username: userID}));
    await servers.update(
        where.eq('serverName', server), modify.pull('inQueue', username));
    await servers.update(where.eq('serverName', server),
        modify.set('roles.$username', 'peasant'));
    print("$username added as member of $server successfully.");
  }
}

Future remove(users, servers, server, serverCurr, username, channel, role,
    currentUser) async {
  //server exists
  var checkUser = await users.find(where.eq('username', username)).isEmpty;

  if (checkUser) {
    //user does not exist
    print('User Not Found');
    return;
  } else {
    var Server = await servers.findOne(where.eq('serverName', server));
    Map<String, dynamic> roleList = server['roles'];
    var roleCurrent = roleList[currentUser];
    if (roleCurrent == 'moderator' && role == 'creator') {
      print('ServerError : You Do Not Have Permission to Remove');
      return;
    }
    if (channel != null && server != null) {
      var checkChannel =
          await serverCurr.find(where.eq('channelName', channel)).isEmpty;
      if (checkChannel) {
        print('ChannalError: Channel not found');
        return;
      }
      final currentUser = await users.findOne(where.eq('username', username));
      dynamic userID = currentUser?['_id'];

      var Channel = await serverCurr.findOne(where.eq('channelName', channel));
      List memberList = Channel['members'];

      if (!memberList.any((member) =>
          member.containsKey(username) && member[username] == userID)) {
        print('ChannelError : No User Found');
        return;
      }

      await serverCurr.update(
        where.eq('channelName', channel),
        modify.pull('members', {'$username': userID}),
      );
      print('Succefully Removed ' + username + " from " + channel);
    } else if (server != null) {
      final currentUser = await users.findOne(where.eq('username', username));
      dynamic userID = currentUser?['_id'];

      List memberList = Server['allMembers'];

      if (!memberList.any((member) =>
          member.containsKey(username) && member[username] == userID)) {
        print('ServerError : No User Found');
        return;
      }

      await serverCurr.update(
        where,
        modify.pullAll('members', [
          {'$username': userID}
        ]),
      );
      await servers.update(
        where.eq('serverName', server),
        modify.pullAll('allMembers', [
          {'$username': userID}
        ]),
      );

      await servers.update(
          where.eq('serverName', server), modify.unset('roles.$username'));
      print('Succefully Removed ' + username + " from " + server);
      return;
    } else {
      print('SyntaxError : Invalid Syntax Provide Server Name');
      return;
    }
  }
}

void showMods(serverCurr) {
  //dart bin/disco.dart showMods -s servername

  Map<String, dynamic> role = serverCurr['roles'];

  print('List of moderators : ');
  int count = 0;
  for (String i in role.keys) {
    if (role[i] == 'moderator') {
      print(i);
      count++;
    }
  }
  if (count == 0) {
    var server = serverCurr['serverName'];
    var creator = serverCurr['creator'];
    print("No moderators in $server except creator : $creator");
  }
}
