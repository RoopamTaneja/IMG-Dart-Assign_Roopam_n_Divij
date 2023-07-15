import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main(List<String> arguments) async {
  //creating a new instance of the database server
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();
  //checking for any instance of login from the database

  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();
  final servers = db.collection('servers');

  final users = db.collection('userAuth');
  final parser = ArgParser();

  parser.addOption('server', abbr: 's', help: 'LEAVE A SERVER');
  parser.addOption('channel', abbr: 'c', help: 'LEAVE A CHANNEL');
  parser.addFlag('user', abbr: 'u', help: 'DELETE YOUR ACCOUNT');
  if (currentSession == null) {
    //if no user logged in then no point in moving ahead
    print('LoginError : No User Logged In');
  } else {
    final parsed = parser.parse(arguments);
    final server = parsed['server'];
    final channel = parsed['channel'];
    var serverCurr = await servers.findOne(where.eq('serverName', server));
    final currUser = currentSession['username'];

    if (serverCurr == null) {
      print('ServerError : No Such Server');
    } else {
      if (channel != null && server != null) {
        var localServer = db.collection(server);
        var checkChannel =
            await localServer.find(where.eq('channelName', channel)).isEmpty;
        if (checkChannel) {
          //channel does not exist
          print('ChannelError : Channel Does Not Exist in $server');
        } else {
          final currentUser =
              await users.findOne(where.eq('username', currUser));
          dynamic userID = currentUser?['_id'];

          var Channel =
              await localServer.findOne(where.eq('channelName', channel)) ?? {};
          List memberList = Channel['members'];

          if (!memberList.any((member) =>
              member.containsKey(currUser) && member[currUser] == userID)) {
            print('ChannelError : No User Found');
            await db.close();
            return;
          }

          await localServer.update(
            where.eq('channelName', channel),
            modify.pull('members', {'$currUser': userID}),
          );
          print('Succefully Exited from ' + channel);
        }
      } else if (server != null) {
        var localServer = db.collection(server);
        final currentUser = await users.findOne(where.eq('username', currUser));
        dynamic userID = currentUser?['_id'];
        var Server =
            await servers.findOne(where.eq('serverName', server)) ?? {};
        List memberList = Server['allMembers'];

        if (!memberList.any((member) =>
            member.containsKey(currUser) && member[currUser] == userID)) {
          print('ServerError : No User Found');
          await db.close();
          return;
        }

        await localServer.update(
          where,
          modify.pullAll('members', [
            {'$currUser': userID}
          ]),
        );
        await servers.update(
          where.eq('serverName', server),
          modify.pullAll('allMembers', [
            {'$currUser': userID}
          ]),
        );

        await servers.update(
            where.eq('serverName', server), modify.unset('roles.$currUser'));
        print('Succefully Exited from ' + server);
        await db.close();
        return;
      } else {
        print('SyntaxError : Invalid Syntax Provide Server Name');
        await db.close();
        return;
      }
    }
  }
  await db.close();
}
