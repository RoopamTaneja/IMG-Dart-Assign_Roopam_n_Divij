import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:core';

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
    final currentUser = await users.findOne(where.eq('username', activeUser));
    String activeUserId = currentUser?['_id'];

    if (channel == null && server != null) {
      //only creating a server with no channels
      var check = await servers.find(where.eq('serverName', server)).isEmpty;

      if (!check) {
        print('ServerError: Server Already Exists');
      } else {
        final document = createServer(server, activeUser, activeUserId);

        final result = await servers
            .insertOne(document..['_id'] = ObjectId().toHexString());
        await db.createCollection(server);

        if (result.isAcknowledged) {
          print('Successfully Created Server $server');
        } else {
          print('ServerError : Unsuccessful Server Creation');
        }
      }
    } else if (channel != null && server != null) {
      var serverCurr = await servers.findOne(where.eq('serverName', server));
      var localServer = db.collection(server);

      if (serverCurr == null) {
        //no server...so make server and channel
        final document = createServer(server, activeUser, activeUserId);
        final res1 = await servers
            .insertOne(document..['_id'] = ObjectId().toHexString());
        await db.createCollection(server);

        final channelDoc =
            createChannel(channel, activeUser, activeUserId, type);
        final res2 = await localServer
            .insertOne(channelDoc..['_id'] = ObjectId().toHexString());

        if (res1.isAcknowledged && res2.isAcknowledged) {
          print('Successfully Created Channel $channel In Server $server');
        } else {
          print('Create Opearation Unsuccessful');
        }
      } else {
        //there is server, only channel needs to be added

        var role = serverCurr['roles'][activeUser];
        if (role != 'mod' && role != 'creator') {
          //user not mod or creator
          print(
              'Permission Denied : You are not a moderator or creator of $server');
        } else {
          var checkChannel =
              await localServer.find(where.eq('channelName', channel)).isEmpty;
          if (!checkChannel) {
            //channel already present
            print('ChannelError : Channel Already Exists');
          } else {
            //channel not present can be added

            final document =
                createChannel(channel, activeUser, activeUserId, type);

            final result = await localServer
                .insertOne(document..['_id'] = ObjectId().toHexString());

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

Map<String, dynamic> createServer(sName, activeUser, activeUserId) {
  var document = {
    'serverName': sName,
    'dateOfCreation': DateTime.now().toString(),
    'creator': activeUser,
    'userId': activeUserId,
    'serverId': Uuid().v1(),
    'roles': {activeUser: 'creator'},
    'allMembers': [
      {activeUser: activeUserId}
    ],
    'inQueue': [], //members waiting to join
  };
  return document;
}

Map<String, dynamic> createChannel(channel, activeUser, activeUserId, type) {
  final document = {
    'channelName': channel,
    'members': [
      {activeUser: activeUserId}
    ],
    'type': type,
    'messages': []
  };
  return document;
}
