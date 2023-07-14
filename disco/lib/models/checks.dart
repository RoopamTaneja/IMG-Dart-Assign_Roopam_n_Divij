import 'package:mongo_dart/mongo_dart.dart';

class Checks {
  Checks();

  Future<bool> userLoggedIn(DbCollection userSessions) async {
    final currentSession = await userSessions.findOne();
    bool check = (currentSession != null);
    return check;
  }

  Future<bool> userExists(String username, DbCollection userAuth) async {
    final user = await userAuth.findOne(where.eq('username', username));
    bool check = (user != null);
    return check;
  }

  Future<bool> serverExists(String server, DbCollection servers) async {
    return !(await servers.find(where.eq('serverName', server)).isEmpty);
  }

  Future<bool> channelExists(channel, DbCollection localServer) async {
    return !(await localServer.find(where.eq('channelName', channel)).isEmpty);
  }
}
