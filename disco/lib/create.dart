import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:core';
import 'package:disco/models/checks.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/channel.dart';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  final servers = db.collection('servers');
  final userSessions = db.collection('userSession');
  final users = db.collection('userAuth');
  final currentSession = await userSessions.findOne();

  if (currentSession == null) {
    //if no user logged in then no point in moving ahead
    print('LoginError : No User Logged In');
  } else {
    final parser = ArgParser();
    parser.addOption("server",
        abbr: "s", help: "CREATE SERVER/CHANNEL WITHIN SERVER");
    parser.addOption("channel",
        abbr: "c", help: "CREATE CHANNEL WITHIN SERVER");
    parser.addOption("type", abbr: "t", help: "ADD CHANNEL TYPE");
    final parsed = parser.parse(arguments);

    final channel = parsed['channel'];
    final server = parsed['server'];
    String type = parsed['type'] ?? "text";

    String activeUser = currentSession['username'];
    User userObj = User();
    await userObj.setUserData(activeUser, users);

    Checks errors = Checks();
    if (channel == null && server != null) {
      //only creating a server with no channels
      bool check = await errors.serverExists(server, servers);

      if (check) {
        print('ServerError: Server Already Exists');
      } else {
        //creating the new server

        Server newServer = Server();
        final result = await newServer.createServer(userObj, server, db);

        if (result.isAcknowledged) {
          print('Successfully Created Server $server');
        } else {
          print('ServerError : Unsuccessful Server Creation');
        }
      }
    } else if (channel != null && server != null) {
      Server currServer = Server();
      Channel newChannel = Channel();
      var serverCurr = await currServer.findServer(server, servers);
      var localServer = db.collection(server);

      if (serverCurr == null) {
        //no server...so make server and channel

        final res1 = await currServer.createServer(userObj, server, db);

        final res2 =
            await newChannel.createChannel(userObj, channel, type, localServer);

        if (res1.isAcknowledged && res2.isAcknowledged) {
          print('Successfully Created Channel $channel In Server $server');
        } else {
          print('Create Opearation Unsuccessful');
        }
      } else {
        //there is server, only channel needs to be added

        await currServer.setServerData(server, servers);
        var role = currServer.roles?[userObj.username];
        if (role != 'mod' && role != 'creator') {
          //user not mod or creator
          print(
              'Permission Denied : You are not a moderator or creator of $server');
        } else {
          //check if channel already exists

          var checkChannel = await errors.channelExists(channel, localServer);
          if (checkChannel) {
            //channel already present
            print('ChannelError : Channel Already Exists');
          } else {
            //channel not present can be added

            final result = await newChannel.createChannel(
                userObj, channel, type, localServer);

            if (result.isAcknowledged) {
              print('Successfully Created Channel $channel');
            } else {
              print('ChannelError : Unsuccessful Channel Creation');
            }
          }
        }
      }
    } else {
      //server == null
      print("SyntaxError: Channel can't be Created Without Server");
    }
  }

  await db.close();
}
