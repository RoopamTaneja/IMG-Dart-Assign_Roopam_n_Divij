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

  Future? findServer(String server, DbCollection servers) async {
    return await servers.findOne(where.eq('serverName', server));
  }

  Future createServer(User creator, String server, Db db) async {
    final servers = db.collection('servers');
    final document = _createServerDoc(server, creator.username, creator.id);

    final result =
        await servers.insertOne(document..['_id'] = ObjectId().toHexString());
    await db.createCollection(server);

    return result;
  }

  Future setServerData(String sName, DbCollection servers) async {
    final server = await findServer(sName, servers);
    serverName = sName;
    serverID = server['serverID'];
    date = server['dateOfCreation'];
    creator = server['creator'];
    userID = server['userID'];
    roles = server['roles'];
    allMembers = server['allMembers'];
    inQueue = server['inQueue'];
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
