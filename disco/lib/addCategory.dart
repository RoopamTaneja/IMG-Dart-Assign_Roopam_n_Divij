// ignore_for_file: file_names

import 'package:args/args.dart';
import 'package:disco/models/category.dart';
import 'package:disco/models/checks.dart';
import 'package:disco/models/user.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/errors.dart';

import 'models/server.dart';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();
  var activeUser = currentSession?['username'];
  Server ser = new Server();
  User us = new User();
  if (currentSession == null) {
    //if no user logged in then no point in moving ahead
    LoginError.NotLoggedIn();
  } else {
    final parser = ArgParser();
    parser.addOption("server",
        abbr: "s", help: "CREATE SERVER/CHANNEL WITHIN SERVER");
    parser.addOption("category", abbr: "g", help: "ADD CATEGORY WITHIN SERVER");
    parser.addFlag("creator",
        abbr: "C", help: "ALLOW CREATOR TO ACCESS CHANNELS");
    parser.addFlag("moderator",
        abbr: "M", help: "ALLOW MODERATOR TO ACCESS CHANNELS");
    parser.addFlag("peasant",
        abbr: "P", help: "ALLOW PEASANTS TO ACCESS CHANNELS");
    parser.addOption('users',
        abbr: 'u', help: 'ADD PERMITTED USERS WITHIN CHANNEL');
    final parsed = parser.parse(arguments);
    final server = parsed['server'];
    final category = parsed['category'];
    final c = parsed['creator'] as bool;
    final m = parsed['moderator'] as bool;
    final p = parsed['peasant'] as bool;
    final users = parsed['users'] ?? "";
    List userList = users.split('+');
    var activeUser = currentSession['username'];

    await ser.setServerData(server, db);
    await us.setUserData(activeUser, db);

    if (!Checks.isMod(ser, us)) {
      ProcessError.ChannelRightsError();
    } else if (await Checks.categoryExists(server, category, db)) {
      DuplicacyError.CategoryExists(category, server);
    } else {
      Category newCategory = Category();
      await newCategory.createCategory(server, category, db, c, m, p, userList);
    }
  }
  db.close();
}
