import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:core';

//dart bin/disco.dart join -s servername -c channelname

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  final users = db.collection('userAuth');
  final servers = db.collection('servers');
  final userSessions = db.collection('userSession');
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
    final parsed = parser.parse(arguments);

    final channel = parsed['channel'];
    final server = parsed['server'];
    String activeUser = currentSession['username'];

    if (channel == null && server != null) {
      //only server name given
      var serverMain = servers.find(where.eq('serverName', server));
      var check = await serverMain.isEmpty;
      if (check) {
        //server doesn't exist
        print('ServerError: Server Does Not Exist');
      } else {
        //server exists
        final currentUser =
            await users.findOne(where.eq('username', activeUser));
        String activeUserId = currentUser?['_id'];

        //is user already server member
        var checkUser = await servers
            .find(where
                .eq('serverName', server)
                .eq('allMembers', {activeUser: activeUserId}))
            .isEmpty;

        if (checkUser) {
          //he is not a member
          var queueCheck = await servers
              .find(where.eq('serverName', server).eq('inQueue', activeUser))
              .isEmpty;

          //then check if he is already in queue
          if (queueCheck) {
            //he is not in queue so add him
            servers.update(where.eq('serverName', server),
                modify.push('inQueue', activeUser));
            print('$activeUser Added to Queue for Approval');
          } else {
            //he is already in queue
            print(
                'ServerError: Already in Queue for Approval, Try Contacting Moderator or Creator');
          }
        } else {
          //yes he is already member
          print('Already Memeber of $server.');
        }
      }
    } else if (channel != null && server != null) {
      //both server and channel name is supplied

      var check = await servers.find(where.eq('serverName', server)).isEmpty;

      if (check) {
        //server doesn't exist
        print('ServerError: Server Does Not Exist');
      } else {
        //server exists

        var localServer = db.collection(server);
        var checkChannel =
            await localServer.find(where.eq('channelName', channel)).isEmpty;
        if (checkChannel) {
          //channel does not exist
          print('ChannelError : Channel Does Not Exist in $server');
        } else {
          //server and channel both exist

          final currentUser =
              await users.findOne(where.eq('username', activeUser));
          String activeUserId = currentUser?['_id'];

          //is user already server member
          var checkUser = await servers
              .find(where
                  .eq('serverName', server)
                  .eq('allMembers', {activeUser: activeUserId}))
              .isEmpty;

          if (checkUser) {
            //he is not a member

            var queueCheck = await servers
                .find(where.eq('serverName', server).eq('inQueue', activeUser))
                .isEmpty;

            //then check if he is already in queue
            if (queueCheck) {
              //he is not in queue so add him
              servers.update(where.eq('serverName', server),
                  modify.push('inQueue', activeUser));
              print(
                  '$activeUser is not yet a Member of $server. $activeUser Added to Queue for Approval');
            } else {
              //he is already in queue
              print(
                  'ServerError: Already in Queue for Approval of Joining $server. Try Contacting Mod or Creator');
            }
          } else {
            //yes he is server member

            //is he channel member
            var checkInChannel = await localServer
                .find(where
                    .eq('channelName', channel)
                    .eq('members', {activeUser: activeUserId}))
                .isEmpty;

            if (checkInChannel) {
              //no he is not
              //so add him in channel

              await localServer.update(where.eq('channelName', channel),
                  modify.push('members', {activeUser: activeUserId}));
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
      print("SyntaxError: Server Name is Needed");
    }
  }

  await db.close();
}
