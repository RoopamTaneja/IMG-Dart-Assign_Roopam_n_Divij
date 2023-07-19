import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/checks.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/errors.dart';

void main(List<String> arguments) async {
//creating a new instance of the database server
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();
  //checking for any instance of login from the database

  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  if (currentSession == null) {
    LoginError.NotLoggedIn();
    await db.close();
    return;
  } else {
    final parser = ArgParser();
    parser.addOption("channel", abbr: "c", help: "SHOW CHANNEL MESSAGES");
    parser.addOption("server", abbr: "s", help: "SERVER FOR CHANNEL MESSAGES");
    parser.addOption("user", abbr: "u", help: "SHOW PARTICULAR USER MESSAGES");
    parser.addOption("limit",
        abbr: "l", help: "SET LIMIT ON NUMBER OF MESSAGES SHOWN");

    final parsed = parser.parse(arguments);
    final receiver = currentSession['username'];
    final channel = parsed['channel'];
    final server = parsed['server'];
    int limit = int.parse(parsed['limit'] ?? "0");
    final sender = parsed['user'];

    int limitF;
    if (limit == 0) {
      limitF = 10;
    } else {
      limitF = limit;
    }

    if (sender != null && (server != null || channel != null)) {
      SyntaxError.MultipleInbox();
      await db.close();
      return;
    }

    User receiverObj = User();
    await receiverObj.setUserData(receiver, db);

    if (sender != null) {
      await receiverObj.showDM(sender, limitF, db);
      await db.close();
      return;
    }

    if (server == null && channel != null) {
      SyntaxError.noServerName();
      await db.close();
      return;
    }
    if (server != null && channel == null) {
      SyntaxError.noChannelName();
      await db.close();
      return;
    }
    if (sender == null && server == null && channel == null) {
      SyntaxError.noInbox();
      await db.close();
      return;
    }

    if (server != null && channel != null) {
      bool checkServer = await Checks.serverExists(server, db);

      if (!checkServer) {
        ProcessError.ServerDoesNotExist(server);
        await db.close();
        return;
      }

      Server currServer = Server();
      await currServer.setServerData(server, db);
      await currServer.showChannelMsg(channel, limitF, receiverObj, db);
    }
  }

  await db.close();
}
