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
      var serverMain = await servers.find(where.eq('serverName', server));
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
          var queueCheck = await servers
              .find(where.eq('serverName', server).eq('inQueue', activeUser))
              .isEmpty;
          //he is not
          // then add user to waiting queue of server
          if (queueCheck) {
            servers.update(where.eq('serverName', server),
                modify.push('inQueue', activeUser));
            print('$activeUser Added to Queue for Approval');
          } else {
            print(
                'ServerError: Already in Queue for Approval, Try Contacting Mod or Creator');
          }
        } else {
          //yes he is
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
        var localServer = db.collection(server);
        var checkChannel =
            await localServer.find(where.eq('channelName', channel)).isEmpty;
        if (checkChannel) {
          //channel does not exist
          print('ChannelError : Channel Does Not Exists');
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
            //he is not
            // then add user to waiting queue of server
            var queueCheck = await servers
                .find(where.eq('serverName', server).eq('inQueue', activeUser))
                .isEmpty;
            //he is not
            // then add user to waiting queue of server
            if (queueCheck) {
              servers.update(where.eq('serverName', server),
                  modify.push('inQueue', activeUser));
              print('$activeUser Added to Queue for Approval');
            } else {
              print(
                  'ServerError: Already in Queue for Approval, Try Contacting Mod or Creator');
            }
          } else {
            //yes he is

            //is user already channel member
            var checkInChannel = await localServer
                .find(where
                    .eq('channelName', channel)
                    .eq('members', {activeUser: activeUserId}))
                .isEmpty;

            if (checkInChannel) {
              //no he is not

              await localServer.update(where.eq('channelName', channel),
                  modify.push('members', {activeUser: activeUserId}));
              print('Successfully Joined Channel $channel of Server $server');
            } else {
              //yes he is

              print('$activeUser is already member of $channel of $server.');
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
