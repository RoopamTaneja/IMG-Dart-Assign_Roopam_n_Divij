import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/checks.dart';
import 'package:disco/models/errors.dart';

class Moderator extends User {
  Server? myServer;

  Moderator();

  void showEntrants() {
    //dart bin/disco.dart showEntrants -s servername

    List arr = myServer!.inQueue!;
    if (arr.isEmpty) {
      //if empty list
      print('No users waiting for approval');
    } else {
      print('List of users waiting for approval to join : ');
      for (String i in arr) {
        print(i);
      }
    }
  }

  Future admit(username, Db db) async {
    //dart bin/disco.dart admit -u username -s servername

    final servers = db.collection('servers');
    final currServer = myServer;

    //server exists
    bool checkUser = await Checks.userExists(username, db);

    if (!checkUser) {
      //user does not exist
      ProcessError.UserDoesNotExist(username);
      return;
    } else {
      //user exists
      //check if already a member
      User newEntry = User();
      await newEntry.setUserData(username, db);

      var role = currServer?.roles?[newEntry.username];
      if (role != null) {
        //yes already member
        DuplicacyError.UserInServer(username);
        return;
      }
      //no he is not so make him a member
      await servers.update(where.eq('serverName', currServer?.serverName),
          modify.push('allMembers', {username: newEntry.id}));
      await servers.update(where.eq('serverName', currServer?.serverName),
          modify.pull('inQueue', username));
      await servers.update(where.eq('serverName', currServer?.serverName),
          modify.set('roles.$username', 'peasant'));
      print(
          "$username added as member of ${currServer?.serverName} successfully.");
    }
  }

  Future remove(username, channel, Db db) async {
    final servers = db.collection('servers');
    final currServer = myServer;
    var serverCurr = db.collection(currServer!.serverName!);

    //server exists
    bool checkUser = await Checks.userExists(username, db);

    if (!checkUser) {
      //user does not exist
      ProcessError.UserDoesNotExist(username);
      return;
    } else {
      User newExit = User();
      await newExit.setUserData(username, db);

      if (channel != null) {
        var checkChannel = await Checks.channelExists(channel, currServer, db);
        if (!checkChannel) {
          ProcessError.ChannelDoesNotExist(channel);
          return;
        }
        bool isMember =
            await Checks.isChannelMember(newExit, channel, currServer, db);

        if (!isMember) {
          ProcessError.UserNotInChannel(username);
          return;
        }
        await serverCurr.update(
          where.eq('channelName', channel),
          modify.pull('members', {username: newExit.id}),
        );
        print(
            'Successfully Removed $username from Channel $channel of Server ${currServer.serverName}');
      } else {
        bool isMember = await Checks.isServerMember(newExit, currServer, db);

        if (!isMember) {
          ProcessError.UserNotInServer(username);
          return;
        }
        // ignore: await_only_futures
        final channelCursor = await serverCurr.find();
        await for (var channel in channelCursor) {
          await serverCurr.update(
            where.eq('channelName', channel['channelName']),
            modify.pullAll('members', [
              {newExit.username: newExit.id}
            ]),
          );
        }
        await servers.update(
          where.eq('serverName', currServer.serverName),
          modify.pullAll('allMembers', [
            {newExit.username: newExit.id}
          ]),
        );

        await servers.update(where.eq('serverName', currServer.serverName),
            modify.unset('roles.$username'));
        print(
            'Successfully Removed $username from Server ${currServer.serverName}');
        return;
      }
    }
  }
}
