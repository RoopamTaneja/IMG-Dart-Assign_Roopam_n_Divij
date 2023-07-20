import 'package:args/args.dart';
import 'package:disco/models/channel.dart';
import 'package:disco/models/checks.dart';
import 'package:disco/models/server.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/errors.dart';

import 'models/user.dart';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();
  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();
  final activeUser = currentSession?['username'];
  if (currentSession == null) {
    LoginError.NotLoggedIn();
  } else {
    final parser = ArgParser();
    parser.addOption("server", abbr: "s", help: "SERVER NAME");
    parser.addOption('channel', abbr: 'c', help: 'MOVE CHANNEL TO CATEGORY');
    parser.addOption("category", abbr: "g", help: "CATEGORY IN SERVER");

    final parsed = parser.parse(arguments);

    final category = parsed['category'];
    final channel = parsed['channel'];
    final server = parsed['server'];
    bool checkServer = await Checks.serverExists(server, db);
    if (!checkServer) {
      ProcessError.ServerDoesNotExist(server);
      await db.close();
      return;
    }

    Server ser = Server();
    await ser.setServerData(server, db);
    bool checkChannel = await Checks.channelExists(channel, ser, db);

    if (!checkChannel) {
      //channel does not exist
      ProcessError.ChannelDoesNotExist(channel);
      db.close();
      return;
    } else {
      bool checkCategory = await Checks.categoryExists(server, category, db);
      if (!checkCategory) {
        ProcessError.CategoryDoesNotExist(category);
        db.close();
        return;
      } else {
        User us = User();
        await us.setUserData(activeUser, db);
        if (!Checks.isMod(ser, us)) {
          ProcessError.ChannelRightsError();
          db.close();
          return;
        }
        Channel ch = Channel();
        await ch.setChannelData(server, channel, db);
        await ch.moveToCategory(category, channel, server, db);
      }
    }
  }
  db.close();
}
