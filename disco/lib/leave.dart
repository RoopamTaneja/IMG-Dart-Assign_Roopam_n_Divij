import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/checks.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/channel.dart';

void main(List<String> arguments) async {
  //creating a new instance of the database server
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();
  //checking for any instance of login from the database

  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  if (currentSession == null) {
    //if no user logged in then no point in moving ahead
    print('LoginError : No User Logged In');
  } else {
    final parser = ArgParser();
    parser.addOption('server', abbr: 's', help: 'LEAVE A SERVER');
    parser.addOption('channel', abbr: 'c', help: 'LEAVE A CHANNEL');
    final parsed = parser.parse(arguments);

    final server = parsed['server'];
    final channel = parsed['channel'];
    final currUser = currentSession['username'];
    User userObj = User();
    await userObj.setUserData(currUser, db);

    Checks errors = Checks();
    bool check = await errors.serverExists(server, db);
    if (!check) {
      print('ServerError : No Such Server');
    } else {
      Server currServer = Server();
      await currServer.setServerData(server, db);

      if (channel != null && server != null) {
        bool checkChannel = await errors.channelExists(channel, currServer, db);
        if (!checkChannel) {
          //channel does not exist
          print('ChannelError : Channel Does Not Exist in $server');
        } else {
          Channel currChannel = Channel();
          await currChannel.setChannelData(server, channel, db);
          currChannel.leaveChannel(userObj, db);
        }
      } else if (server != null) {
        await currServer.leaveServer(userObj, db);
      } else {
        print('SyntaxError : Invalid Syntax Provide Server Name');
      }
    }
  }
  await db.close();
}
