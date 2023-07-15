import 'package:args/args.dart';
import 'package:disco/models/mod.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/checks.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/errors.dart';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  if (currentSession == null) {
    //if no user logged in then no point in moving ahead

    print('LoginError : No User Logged In');
  } else {
    final parser = ArgParser();
    //add all parser options here for all fns
    parser.addOption('username', abbr: 'u', help: 'ADD USER');
    parser.addOption("server", abbr: "s", help: "SERVER RELATED RIGHTS");
    parser.addOption("channel", abbr: "c", help: "CHANNEL RELATED RIGHTS");
    final parsed = parser.parse(arguments);

    final server = parsed['server'];
    final username = parsed['username'];
    final channel = parsed['channel'];
    final currentUser = currentSession['username'];

    User userObj = User();
    await userObj.setUserData(currentUser, db);

    Checks errors = Checks();
    bool check = await errors.serverExists(server, db);

    if (!check) {
      ProcessError.ServerDoesNotExist(server);
    } else {
      //server exists
      Server currServer = Server();
      await currServer.setServerData(server, db);

      bool checkRole = errors.isMod(currServer, userObj);
      if (!checkRole) {
        //u are not mod or creator
        PermissionDeniedError.ModCreatorRight(server);
      } else {
        //now call different fns and pass different values as per need
        Moderator newMod = Moderator();
        await newMod.setUserData(currentUser, db);
        newMod.myServer = currServer;

        if (arguments[0] == "showEntrants") {
          newMod.showEntrants();
        } else if (arguments[0] == "admit") {
          await newMod.admit(username, currServer, db);
        } else if (arguments[0] == "remove") {
          await newMod.remove(username, channel, currServer, db);
        }
      }
    }
  }
  await db.close();
}

// Future remove(users, servers, server, serverCurr, username, channel, role,
//     currentUser) async {
//   //server exists
//   var checkUser = await users.find(where.eq('username', username)).isEmpty;

//   if (checkUser) {
//     //user does not exist
//     print('User Not Found');
//     return;
//   } else {
//     var Server = await servers.findOne(where.eq('serverName', server));
//     Map<String, dynamic> roleList = server['roles'];
//     var roleCurrent = roleList[currentUser];
//     if (roleCurrent == 'moderator' && role == 'creator') {
//       print('ServerError : You Do Not Have Permission to Remove');
//       return;
//     }
//     if (channel != null && server != null) {
//       var checkChannel =
//           await serverCurr.find(where.eq('channelName', channel)).isEmpty;
//       if (checkChannel) {
//         print('ChannalError: Channel not found');
//         return;
//       }
//       final currentUser = await users.findOne(where.eq('username', username));
//       dynamic userID = currentUser?['_id'];

//       var Channel = await serverCurr.findOne(where.eq('channelName', channel));
//       List memberList = Channel['members'];

//       if (!memberList.any((member) =>
//           member.containsKey(username) && member[username] == userID)) {
//         print('ChannelError : No User Found');
//         return;
//       }

//       await serverCurr.update(
//         where.eq('channelName', channel),
//         modify.pull('members', {'$username': userID}),
//       );
//       print('Succefully Removed ' + username + " from " + channel);
//     } else if (server != null) {
//       final currentUser = await users.findOne(where.eq('username', username));
//       dynamic userID = currentUser?['_id'];

//       List memberList = Server['allMembers'];

//       if (!memberList.any((member) =>
//           member.containsKey(username) && member[username] == userID)) {
//         print('ServerError : No User Found');
//         return;
//       }

//       await serverCurr.update(
//         where,
//         modify.pullAll('members', [
//           {'$username': userID}
//         ]),
//       );
//       await servers.update(
//         where.eq('serverName', server),
//         modify.pullAll('allMembers', [
//           {'$username': userID}
//         ]),
//       );

//       await servers.update(
//           where.eq('serverName', server), modify.unset('roles.$username'));
//       print('Succefully Removed ' + username + " from " + server);
//       return;
//     } else {
//       print('SyntaxError : Invalid Syntax Provide Server Name');
//       return;
//     }
//   }
// }
