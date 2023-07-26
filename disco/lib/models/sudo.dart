import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/server.dart';

class Sudo extends User {
  Server? myServer;

  Sudo();

  Future<void> addMod(username, Db db) async {
    final servers = db.collection('servers');

    //server exists bcoz i'm its owner
    var role = myServer?.roles?[username];
    if (role == 'peasant') {
      //user is peasant so make him mod

      await servers.update(where.eq('serverName', myServer?.serverName),
          modify.set('roles.$username', 'moderator'));
      print(
          "$username Added as Moderator of ${myServer?.serverName} Successfully.");
    } else {
      //else that is not possible (for null, mod, creator etc)

      print("UpdationError : Promotion Not Possible.");
    }
  }

  Future<void> removeMod(username, Db db) async {
    final servers = db.collection('servers');
    //server exists bcoz i'm its owner
    var role = myServer?.roles?[username];
    if (role == "moderator") {
      //user is mod so make him peasant

      await servers.update(where.eq('serverName', myServer?.serverName),
          modify.set('roles.$username', 'peasant'));
      print(
          "$username Removed as Moderator of ${myServer?.serverName} Successfully.");
    } else {
      //else that is not possible (for null, peasant, creator etc)

      print("UpdationError : Demotion Not Possible.");
    }
  }
}
