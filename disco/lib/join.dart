import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/checks.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/channel.dart';
import 'package:disco/models/errors.dart';

//dart bin/disco.dart join -s servername -c channelname

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
    final parsed = parser.parse(arguments);

    final channel = parsed['channel'];
    final server = parsed['server'];
    var activeUser = currentSession['username'];
    User userObj = User();
    await userObj.setUserData(activeUser, db);

    Checks errors = Checks();
    if (channel == null && server != null) {
      //only server name given
      bool check = await errors.serverExists(server, db);
      if (!check) {
        //server doesn't exist
        ProcessError.ServerDoesNotExist(server);
      } else {
        //server exists
        Server currServer = Server();
        await currServer.setServerData(server, db);

        //is user already server member
        bool checkUser = await errors.isServerMember(userObj, currServer, db);

        if (!checkUser) {
          //he is not a member
          bool queueCheck = await errors.presentInQueue(userObj, server, db);

          //then check if he is already in queue
          if (!queueCheck) {
            //he is not in queue so add him
            await currServer.addInQueue(userObj, db);
            print('$activeUser Added to Queue for Approval');
          } else {
            //he is already in queue
            print(
                'DuplicacyError : Already in Queue for Approval, Try Contacting Moderator or Creator');
          }
        } else {
          //yes he is already member
          print('Already Member of $server.');
        }
      }
    } else if (channel != null && server != null) {
      //both server and channel name is supplied

      bool check = await errors.serverExists(server, db);

      if (!check) {
        //server doesn't exist
        ProcessError.ServerDoesNotExist(server);
      } else {
        //server exists
        Server currServer = Server();
        await currServer.setServerData(server, db);

        bool checkChannel = await errors.channelExists(channel, currServer, db);
        if (!checkChannel) {
          //channel does not existS
          ProcessError.ChannelDoesNotExist(channel);
        } else {
          //server and channel both exist

          //is user already server member
          bool checkUser = await errors.isServerMember(userObj, currServer, db);

          if (!checkUser) {
            //he is not a member

            bool queueCheck = await errors.presentInQueue(userObj, server, db);

            //then check if he is already in queue
            if (!queueCheck) {
              //he is not in queue so add him

              await currServer.addInQueue(userObj, db);
              print(
                  '$activeUser is not yet a Member of $server. $activeUser Added to Queue for Approval');
            } else {
              //he is already in queue
              print(
                  'DuplicacyError : Already in Queue for Approval of Joining $server. Try Contacting Mod or Creator');
            }
          } else {
            //yes he is server member

            //is he channel member
            bool checkInChannel =
                await errors.isChannelMember(userObj, channel, currServer, db);

            if (!checkInChannel) {
              //no he is not
              //so add him in channel

              Channel currChannel = Channel();
              await currChannel.addInChannel(userObj, channel, currServer, db);

              print('Successfully Joined Channel $channel of Server $server');
            } else {
              //yes he is already in channel

              print('$activeUser is Already Member of $channel of $server.');
            }
          }
        }
      }
    } else {
      //server == null
      SyntaxError.noServerName();
    }
  }

  await db.close();
}
