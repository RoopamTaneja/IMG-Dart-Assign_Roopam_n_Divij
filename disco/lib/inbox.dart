import 'dart:math';

import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main(List<String> arguments) async {
//creating a new instance of the database server
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();
  //checking for any instance of login from the database

  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();
  final servers = db.collection('servers');
  final messageDB = db.collection('messages');
  final userAuth = db.collection('userAuth');
  final parser = ArgParser();

  parser.addOption("channel", abbr: "c", help: "SHOW CHANNEL MESSAGES");
  parser.addOption("server", abbr: "s", help: "SERVER FOR CHANNEL MESSAGES");
  parser.addOption("user", abbr: "u", help: "SHOW PARTICULAR USER MESSAGES");
  parser.addOption("limit",
      abbr: "l", help: "SET LIMIT ON NUMBER OF MESSAGES SHOWN");

  if (currentSession == null) {
    print('LoginError :  No User Logged in');
    return;
  } else {
    final parsed = parser.parse(arguments);
    final receiver = currentSession['username'];
    final channel = parsed['channel'];
    final server = parsed['server'];
    int limit = int.parse(parsed['limit'] ?? "0");
    final sender = parsed['user'];
    if (sender != null && (server != null || channel != null)) {
      print('SyntaxError : Enter Only One Mode of Inbox');
    }
    if (sender == "ALL") {
      final messages =
          await messageDB.find(where.eq('receiver', receiver)).toList();
      int limitF = max(limit, 10);
      for (var i in messages.reversed) {
        print('FROM : ' + i['sender']);
        print('SENT ON : ' + i['time']);
        print(i['message']);
        print('');
        limitF--;
        if (limitF == 0) {
          break;
        }
      }
      db.close();
      return;
    }
    if (sender != null) {
      final checkReceiver =
          await userAuth.find(where.eq('username', sender)).isEmpty;
      if (checkReceiver || receiver == sender) {
        print("UserError : User Not Found");
        db.close();
        return;
      }
      final messages = await messageDB
          .find(where.eq('receiver', receiver).and(where.eq('sender', sender)))
          .toList();
      int limitF = max(limit, 10);
      for (var i in messages.reversed) {
        print('FROM : ' + i['sender']);
        print('SENT ON : ' + i['time']);
        print(i['message']);
        print('');
        limitF--;
        if (limitF == 0) {
          break;
        }
      }
    }

    if (server == null && channel != null) {
      print('SyntaxError : Enter Server Name');
    }
    if (server != null && channel == null) {
      print('SyntaxError : Enter Channel Name');
    }
    if (server != null && channel != null) {
      final checkServer =
          await servers.find(where.eq('serverName', server)).isEmpty;
      if (checkServer) {
        print('ServerError : Server Not Found');
        db.close();
        return;
      }

      final currentUser = await userAuth
          .findOne(where.eq('username', currentSession['username']));
      String currentId = currentUser?['_id'];

      var checkUser = await servers
          .find(where
              .eq('serverName', server)
              .eq('allMembers', {currentSession['username']: currentId}))
          .isEmpty;
      if (checkUser) {
        print('ServerError : Not Member Of Server');
        db.close();
        return;
      }
      final serverDb = db.collection(server);
      final checkChannel =
          await serverDb.find(where.eq('channelName', channel)).isEmpty;
      if (checkChannel) {
        print('ChannelErorr : No Channel Found');
        db.close();
        return;
      }
      var checkInChannel = await serverDb
          .find(where
              .eq('channelName', channel)
              .eq('members', {currentSession['username']: currentId}))
          .isEmpty;
      if (checkInChannel) {
        print('ChannelError : Not Member Of Channel');
        db.close();
        return;
      }
      final channelServer =
          await serverDb.findOne(where.eq('channelName', channel));
      if (channelServer != null) {
        List channelMessage = channelServer['messages'];

        int limitF = max(limit, 10);
        for (var i in channelMessage.reversed) {
          print('FROM : ' + i['sender']);
          print('SENT ON : ' + i['time']);
          print(i['message']);
          print('');
          limitF--;
          if (limitF == 0) {
            break;
          }
        }
      }
    }
  }

  await db.close();
}
