import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/server.dart';

enum Permitted { creator, moderator, peasant }

class Checks {
  static Future<bool> isValidPassword(String password) async {
    // Define the pattern using a regular expression
    RegExp passwordPattern =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$');

    // Match the pattern against the password
    if (passwordPattern.hasMatch(password)) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> userLoggedIn(Db db) async {
    final userSessions = db.collection('userSession');
    final currentSession = await userSessions.findOne();
    bool check = (currentSession != null);
    return check;
  }

  static Future<bool> userExists(String username, Db db) async {
    final userAuth = db.collection('userAuth');
    final user = await userAuth.findOne(where.eq('username', username));
    bool check = (user != null);
    return check;
  }

  static Future<bool> serverExists(server, Db db) async {
    final servers = db.collection('servers');
    return !(await servers.find(where.eq('serverName', server)).isEmpty);
  }

  static Future<bool> channelExists(channel, Server server, Db db) async {
    var localServer = db.collection(server.serverName!);

    return !(await localServer.find(where.eq('channelName', channel)).isEmpty);
  }

  static Future<bool> categoryExists(category, Db db) async {
    var categories = db.collection('categories');

    return !(await categories.find(where.eq('categoryName', category)).isEmpty);
  }

  static Future<bool> isServerMember(User user, Server server, Db db) async {
    final servers = db.collection('servers');
    return !(await servers
        .find(where
            .eq('serverName', server.serverName)
            .eq('allMembers', {user.username: user.id}))
        .isEmpty);
  }

  static Future<bool> presentInQueue(User user, server, Db db) async {
    final servers = db.collection('servers');
    return !(await servers
        .find(where.eq('serverName', server).eq('inQueue', user.username))
        .isEmpty);
  }

  static Future<bool> isChannelMember(
      User user, channel, Server server, Db db) async {
    var localServer = db.collection(server.serverName!);

    return !(await localServer
        .find(where
            .eq('channelName', channel)
            .eq('members', {user.username: user.id}))
        .isEmpty);
  }

  static bool isMod(Server currServer, User user) {
    var role = currServer.roles?[user.username];
    if (role != 'mod' && role != 'creator') {
      return false;
    }
    return true;
  }

  static Future<bool> isOwner(User user, server, Db db) async {
    final servers = db.collection('servers');
    return !(await servers
        .find(where.eq('serverName', server).eq('userId', user.id))
        .isEmpty);
  }

  static Future<List> permittedList(bool c, bool m, bool p) async {
    List permittedRoles = [];
    if (c) {
      permittedRoles.add(Permitted.creator.toString());
    }
    if (m) {
      permittedRoles.add(Permitted.moderator.toString());
    }
    if (p) {
      permittedRoles.add(Permitted.peasant.toString());
    }
    if (!c && !m && !p) {
      permittedRoles.add(Permitted.creator.toString());
      permittedRoles.add(Permitted.moderator.toString());
      permittedRoles.add(Permitted.peasant.toString());
    }
    return permittedRoles;
  }
}
