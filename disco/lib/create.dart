import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io';
import 'dart:core';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();
  final servers = db.collection('servers');
  final users = db.collection('userAuth');
  final userSessions = db.collection('userSession');
  var user = await userSessions.count();
  final parser = ArgParser();
  parser.addOption("server",
      abbr: "s", help: "CREATE SERVER/CHANNEL WITHIN SERVER");
  parser.addOption("channel", abbr: "c", help: "CREATE CHANNEL WITHIN SERVER");
  parser.addOption("type", abbr: "t", help: "ADD CHANNEL TYPE");
  final parsed = parser.parse(arguments);

  final channel = parsed['channel'];
  final server = parsed['server'];
  String type = parsed['type'] ?? "default";

  if (channel == null && server != null) {
    var check = await servers.find(where.eq('severName', server)).isEmpty;

    if (user == 0) {
      print('LoginError : No User Logged In');
    } else if (!check) {
      print('ServerError: Server Already exists');
    } else {
      var user = await users.findOne();
      var activeUser = user?['username'] as String;
      var activeUserId = user?['hash'] as String;
      var document = {
        'serverName': parsed['server'],
        'dateOfCreation': DateTime.now().toString(),
        'creator': activeUser,
        'userId': activeUserId,
        'serverId': Uuid().v1(),
        'mods': [],
        'peasants': []
      };
      final result =
          await servers.insertOne(document..['_id'] = ObjectId().toHexString());
      await db.createCollection(server);

      if (result.isAcknowledged) {
        print('Succesfully Created Server ' + server);
      } else {
        print('ServerError : Unsuccessful Server Creation');
      }
    }
    await db.close();
  } else if (channel != null && server != null) {
    var check = await servers.find(where.eq('serverName', server)).isEmpty;
    var localServer = db.collection(server);

    var checkChannel =
        await localServer.find(where.eq('channelName', channel)).isEmpty;
    if (user == 0) {
      print('LoginError : No User Logged In');
    } else if (check) {
      print('ServerError: Server does not Exists');
    } else if (!checkChannel) {
      print('ChannelError : Channel already Exist');
    } else {
      var user = await users.findOne();
      var activeUser = user?['username'] as String;
      var activeUserId = user?['hash'] as String;
      final document = {
        'channelName': channel,
        'memebers': [
          {activeUser: activeUserId}
        ],
        'type': type
      };
      final result = await localServer
          .insertOne(document..['_id'] = ObjectId().toHexString());
      if (result.isAcknowledged) {
        print('Succesfully Created Channel ' + channel);
      } else {
        print('ServerError : Unsuccessful Server Creation');
      }
    }
    await db.close();
  } else {
    print('SyntacError: Channel cannot be Created Wihthout Server');
  }
}
