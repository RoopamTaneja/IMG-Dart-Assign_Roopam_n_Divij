import 'package:args/args.dart';
import 'package:disco/models/mod.dart';
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
    parser.addOption("server",
        abbr: "s", help: "CREATE SERVER/CHANNEL WITHIN SERVER");
    parser.addOption("channel",
        abbr: "c", help: "CREATE CHANNEL WITHIN SERVER");
    parser.addOption("type", abbr: "t", help: "ADD CHANNEL TYPE");
    parser.addFlag("creator",
        abbr: "C", help: "ALLOW CREATOR TO ACCESS CHANNELS");
    parser.addFlag("moderator",
        abbr: "M", help: "ALLOW MODERATOR TO ACCESS CHANNELS");
    parser.addFlag("peasant",
        abbr: "P", help: "ALLOW PEASANTS TO ACCESS CHANNELS");

    final parsed = parser.parse(arguments);

    final channel = parsed['channel'];
    final server = parsed['server'];
    final Creator = parsed['creator'] as bool;
    final Moderator = parsed['moderator'] as bool;
    final Peasant = parsed['peasant'] as bool;
    String type = parsed['type'] ?? "text";

    String activeUser = currentSession['username'];
    User userObj = User();
    await userObj.setUserData(activeUser, db);

    Checks errors = Checks();
    if (channel == null && server != null) {
      //only creating a server with no channels
      bool check = await errors.serverExists(server, db);

      if (check) {
        DuplicacyError.ServerExists(server);
      } else {
        //creating the new server

        Server newServer = Server();
        final result = await newServer.createServer(userObj, server, db);

        if (result.isAcknowledged) {
          print('Successfully Created Server $server');
        } else {
          ProcessError.UnsuccessfulProcess();
        }
      }
    } else if (channel != null && server != null) {
      Server currServer = Server();
      Channel newChannel = Channel();
      var serverCurr = await currServer.findServer(server, db);

      if (serverCurr == null) {
        //no server...so make server and channel

        final res1 = await currServer.createServer(userObj, server, db);

        final res2 = await newChannel.createChannel(userObj, channel, type,
            server, db, Creator, Moderator, Peasant, activeUser);

        if (res1.isAcknowledged && res2.isAcknowledged) {
          print('Successfully Created Channel $channel In Server $server');
        } else {
          ProcessError.UnsuccessfulProcess();
        }
      } else {
        //there is server, only channel needs to be added

        await currServer.setServerData(server, db);
        bool checkRole = errors.isMod(currServer, userObj);
        if (!checkRole) {
          //user not mod or creator
          PermissionDeniedError.ModCreatorRight(server);
        } else {
          //check if channel already exists

          var checkChannel =
              await errors.channelExists(channel, currServer, db);

          if (checkChannel) {
            //channel already present
            DuplicacyError.ChannelExists(channel);
          } else {
            //channel not present can be added

            final result = await newChannel.createChannel(userObj, channel,
                type, server, db, Creator, Moderator, Peasant, activeUser);

            if (result.isAcknowledged) {
              print('Successfully Created Channel $channel');
            } else {
              ProcessError.UnsuccessfulProcess();
            }
          }
        }
      }
    } else {
      //server == null
      SyntaxError.ChannelWithoutServer();
    }
  }

  await db.close();
}
