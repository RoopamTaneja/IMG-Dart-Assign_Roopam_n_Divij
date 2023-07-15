import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/server.dart';

class Checks {
  Checks();

  Future<bool> userLoggedIn(Db db) async {
    final userSessions = db.collection('userSession');
    final currentSession = await userSessions.findOne();
    bool check = (currentSession != null);
    return check;
  }

  Future<bool> userExists(String username, Db db) async {
    final userAuth = db.collection('userAuth');
    final user = await userAuth.findOne(where.eq('username', username));
    bool check = (user != null);
    return check;
  }

  Future<bool> serverExists(server, Db db) async {
    final servers = db.collection('servers');
    return !(await servers.find(where.eq('serverName', server)).isEmpty);
  }

  Future<bool> channelExists(channel, Server server, Db db) async {
    var localServer = db.collection(server.serverName!);

    return !(await localServer.find(where.eq('channelName', channel)).isEmpty);
  }

  Future<bool> isServerMember(User user, Server server, Db db) async {
    final servers = db.collection('servers');
    return !(await servers
        .find(where
            .eq('serverName', server.serverName)
            .eq('allMembers', {user.username: user.id}))
        .isEmpty);
  }

  Future<bool> presentInQueue(User user, server, Db db) async {
    final servers = db.collection('servers');
    return !(await servers
        .find(where.eq('serverName', server).eq('inQueue', user.username))
        .isEmpty);
  }

  Future<bool> isChannelMember(User user, channel, Server server, Db db) async {
    var localServer = db.collection(server.serverName!);

    return !(await localServer
        .find(where
            .eq('channelName', channel)
            .eq('members', {user.username: user.id}))
        .isEmpty);
  }

  bool isMod(Server currServer, User user) {
    var role = currServer.roles?[user.username];
    if (role != 'mod' && role != 'creator') {
      return false;
    }
    return true;
  }
}
