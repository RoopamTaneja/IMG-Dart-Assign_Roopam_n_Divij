import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/checks.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/channel.dart';
import 'package:disco/models/errors.dart';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();
  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();
  if (currentSession == null) {
    //if no user logged in then no point in moving ahead
    LoginError.NotLoggedIn();
  } else {
    final parser = ArgParser();
    parser.addOption("server", abbr: "s", help: "SERVER NAME");
    parser.addOption("channel", abbr: "c", help: "CHANNEL NAME");
    parser.addOption('users',
        abbr: 'u', help: 'ADD PERMITTED USERS WITHIN CHANNEL');
    final parsed = parser.parse(arguments);
    final channel = parsed['channel'];
    final server = parsed['server'];
    final users = parsed['users'];
    List userList = users.split('+');
    var activeUser = currentSession['username'];
    User userObj = User();
    await userObj.setUserData(activeUser, db);

    bool check = await Checks.serverExists(server, db);
    if (!check) {
      //server doesn't exist
      ProcessError.ServerDoesNotExist(server);
    } else {
      Server currServer = Server();
      await currServer.setServerData(server, db);

      bool checkChannel = await Checks.channelExists(channel, currServer, db);
      if (!checkChannel) {
        //channel does not exist
        ProcessError.ChannelDoesNotExist(channel);
      } else {
        Channel currChannel = Channel();

        await currChannel.setChannelData(server, channel, db);
        await currChannel.addPermittedMember(userList, db, activeUser);
      }
    }
  }
  db.close();
}
