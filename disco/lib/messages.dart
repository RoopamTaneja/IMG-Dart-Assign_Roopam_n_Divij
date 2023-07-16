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
  } else {
    final parser = ArgParser();
    parser.addOption('personal', abbr: 'p', help: "SEND PERSONAL MESSAGES");
    parser.addOption('channel', abbr: 'c', help: 'SEND MESSAGES ON CHANNEL');
    parser.addOption('server', abbr: 's', help: "SERVER FOR CHANNEL");
    parser.addOption('write', abbr: 'w', help: "WRITE MESSAGES");
    final parsed = parser.parse(arguments);

    final sender = currentSession['username'];
    final channel = parsed['channel'];
    final server = parsed['server'];
    final msg = parsed['write'];
    final receiver = parsed['personal'];
    if (msg == null) {
      SyntaxError.noMessage();
      await db.close();
      return;
    }
    if (receiver != null && (server != null || channel != null)) {
      SyntaxError.MultipleRecipients();
      await db.close();
      return;
    }
    if (receiver == null && channel == null) {
      SyntaxError.noRecipient();
      await db.close();
      return;
    }
    if (channel != null && server == null) {
      SyntaxError.noServerName();
      await db.close();
      return;
    }

    User senderObj = User();
    await senderObj.setUserData(sender, db);

    Checks errors = Checks();

    if (receiver != null) {
      //for dm

      await senderObj.sendDM(msg, receiver, db);
    } else if (channel != null && server != null) {
      //for msg on channel

      bool checkServer = await errors.serverExists(server, db);
      if (!checkServer) {
        ProcessError.ServerDoesNotExist(server);
        await db.close();
        return;
      }

      Server currServer = Server();
      await currServer.setServerData(server, db);
      await currServer.sendMsgInChannel(msg, channel, senderObj, db);
    }
  }
  await db.close();
}
