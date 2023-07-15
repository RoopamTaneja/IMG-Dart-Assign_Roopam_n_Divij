import 'package:disco/models/errors.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/user.dart';

class Server {
  String? serverName;
  String? serverID;
  String? date;
  String? creator;
  String? userID;
  Map<dynamic, dynamic>? roles;
  List<dynamic>? allMembers;
  List<dynamic>? inQueue;

  Server();

  void setData(sName, sID, date, creator, userID, roles, allMems, inQ) {
    serverName = sName;
    serverID = sID;
    this.date = date;
    this.creator = creator;
    this.userID = userID;
    this.roles = roles;
    allMembers = allMems;
    inQueue = inQ;
  }

  Future? findServer(String server, Db db) async {
    final servers = db.collection('servers');
    return await servers.findOne(where.eq('serverName', server));
  }

  Future setServerData(String sName, Db db) async {
    final server = await findServer(sName, db);
    serverName = sName;
    serverID = server['serverID'];
    date = server['dateOfCreation'];
    creator = server['creator'];
    userID = server['userID'];
    roles = server['roles'];
    allMembers = server['allMembers'];
    inQueue = server['inQueue'];
  }

  Future createServer(User creator, server, Db db) async {
    final servers = db.collection('servers');
    final document = _createServerDoc(server, creator.username, creator.id);

    final result =
        await servers.insertOne(document..['_id'] = ObjectId().toHexString());
    await db.createCollection(server);

    return result;
  }

  Future addInQueue(User user, Db db) async {
    final servers = db.collection('servers');
    await servers.update(where.eq('serverName', serverName),
        modify.push('inQueue', user.username));
  }

  Future showChannels(Db db) async {
    final serverCurrent = db.collection(serverName!);
    List channelNames =
        await serverCurrent.find().map((doc) => doc['channelName']).toList();
    if (channelNames.isEmpty) {
      print("No Channels Yet in $serverName.");
    } else {
      print("List of Channels in $serverName : ");
      for (String i in channelNames) {
        print(i);
      }
    }
  }

  Future leaveServer(User user, Db db) async {
    final servers = db.collection('servers');
    var localServer = db.collection(serverName!);
    List memberList = allMembers!;

    if (!memberList.any((member) =>
        member.containsKey(user.username) &&
        member[user.username] == user.id)) {
      ProcessError.UserNotInServer(user.username);
      return;
    }

    await localServer.update(
      where,
      modify.pullAll('members', [
        {user.username: user.id}
      ]),
    );
    await servers.update(
      where.eq('serverName', serverName),
      modify.pullAll('allMembers', [
        {user.username: user.id}
      ]),
    );

    await servers.update(where.eq('serverName', serverName),
        modify.unset('roles.${user.username}'));
    print('Successfully Exited from $serverName');
  }

  void showMods() {
    print('List of moderators : ');
    int count = 0;
    for (String i in roles!.keys) {
      if (roles?[i] == 'moderator') {
        print(i);
        count++;
      }
    }
    if (count == 0) {
      print("No moderators in $serverName except creator : $creator");
    }
  }

  //private method
  Map<String, dynamic> _createServerDoc(sName, activeUser, activeUserId) {
    String sID = Uuid().v1();
    String dateTime = DateTime.now().toString();
    var document = {
      'serverName': sName,
      'dateOfCreation': dateTime,
      'creator': activeUser,
      'userId': activeUserId,
      'serverId': sID,
      'roles': {activeUser: 'creator'},
      'allMembers': [
        {activeUser: activeUserId}
      ],
      'inQueue': [], //members waiting to join
    };
    setData(sName, sID, dateTime, activeUser, activeUserId, {
      activeUser: 'creator'
    }, [
      {activeUser: activeUserId}
    ], []);
    return document;
  }
}
