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

  Future createChannel(User creator, channel, type, server, Db db,
      [c, m, p, category]) async {
    var localServer = db.collection(server);
    if (category != null) {
      if (await Checks.categoryExists(server, category, db)) {
        Category channelCategory =
            await Category.setCategoryData(category, server, db);
        var categories = db.collection('categories');

        await categories.update(where.eq('categoryName', category),
            modify.push('channelList', channel));
        permittedRoles = channelCategory.permitted;
      } else {
        ProcessError.CategoryDoesNotExist(category);
      }
    } else {
      permittedRoles = await Checks.permittedList(c, m, p);
    }
    channelCreator = creator.username;
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
    Server server = Server();
    server.setServerData(serverName ?? "", db);

    for (String i in userList) {
      if (permittedUsers.contains(i)) {
        continue;
      } else if (await Checks.userExists(i, db)) {
        User user = User();
        await user.setUserData(i, db);

        if (await Checks.isServerMember(user, server, db)) {
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

  Future moveToCategory(category, channel, server, db) async {
    Category cat = Category();
    final categoryCurr = await cat.findCategory(server, category, db);
    List categoryChannel = categoryCurr?['channelList'];

    if (categoryChannel.contains(channel)) {
      ProcessError.ChannelExistsInCategory(category, channel);
      return;
    }
    var localServer = db.collection(serverName!);
    await localServer.update(where.eq('channelName', channelName),
        modify.set('permittedRoles', categoryCurr?["permittedRoles"]));
    var categories = db.collection('$server.categories');
    return await categories.update(where.eq('categoryName', category),
        modify.push('channelList', channel));
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
