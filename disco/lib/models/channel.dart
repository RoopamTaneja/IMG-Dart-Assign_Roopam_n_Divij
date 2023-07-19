import 'package:disco/models/errors.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/category.dart';
import 'package:disco/models/checks.dart';

class Channel {
  String? channelName;
  String? serverName;
  String? channelCreator;
  List<dynamic>? members;
  String? type;
  List<dynamic>? messages;
  Category? channelCategory;
  List<dynamic> permittedRoles = [];
  List<dynamic> permittedUsers = [];

  Channel();

  Future createChannel(
      User creator, channel, type, server, Db db, bool c, bool m, bool p,
      [category]) async {
    var localServer = db.collection(server);
    Checks check = Checks();
    if (category != null) {
      if (await check.categoryExists(category, db)) {
        Category channelCategory =
            Category.setCategoryData(category, server, db);
      }
      ;
    }
    channelCreator = creator.username;
    permittedRoles = await check.permittedList(c, m, p);
    permittedUsers.add(creator.username);
    final document =
        _createChannelDoc(channel, creator.username, creator.id, type);

    final result = await localServer
        .insertOne(document..['_id'] = ObjectId().toHexString());

    return result;
  }

  Future? findChannel(server, channel, Db db) async {
    var localServer = db.collection(server);
    return await localServer.findOne(where.eq('channelName', channel));
  }

  Future setChannelData(server, channel, Db db) async {
    final channelDoc = await findChannel(server, channel, db);
    channelName = channel;
    members = channelDoc['members'];
    messages = channelDoc['messages'];
    serverName = server;
    type = channelDoc['type'];
  }

  Future addInChannel(User user, channel, Server server, Db db) async {
    var localServer = db.collection(server.serverName!);
    await localServer.update(where.eq('channelName', channel),
        modify.push('members', {user.username: user.id}));
  }

  Future leaveChannel(User user, Db db) async {
    var localServer = db.collection(serverName!);
    List memberList = members!;

    if (!memberList.any((member) =>
        member.containsKey(user.username) &&
        member[user.username] == user.id)) {
      ProcessError.UserNotInChannel(user.username);

      return;
    }

    await localServer.update(
      where.eq('channelName', channelName),
      modify.pull('members', {user.username: user.id}),
    );
    print('Successfully Exited from $channelName');
  }

  Future addPermittedMember(userList, db, activeUser) async {
    if (activeUser != channelCreator) {
      ProcessError.ChannelRightsError();
    }
    Checks error = Checks();
    Server server = Server();
    server.setServerData(serverName ?? "", db);

    for (String i in userList) {
      if (permittedUsers.contains(i)) {
        continue;
      } else if (await error.userExists(i, db)) {
        User user = User();
        await user.setUserData(i, db);

        if (await error.isServerMember(user, server, db)) {
          var localServer = db.collection(serverName!);
          await localServer.update(where.eq('channelName', channelName),
              modify.push('permittedMembers', i));
          permittedUsers.add(i);
        } else {
          continue;
        }
      }
    }
  }

  //private method
  Map<String, dynamic> _createChannelDoc(
      channel, activeUser, activeUserId, type) {
    final document = {
      'channelName': channel,
      'creator': activeUser,
      'members': [
        {activeUser: activeUserId}
      ],
      'type': type,
      'permittedRoles': permittedRoles,
      'permittedUsers': permittedUsers,
      'messages': []
    };
    return document;
  }
}
