import 'package:disco/models/errors.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:disco/models/server.dart';
import 'package:disco/models/user.dart';
import 'package:disco/models/category.dart';

enum permitted { creator, moderator, peasant }

class Channel {
  String? channelName;
  String? serverName;
  List<dynamic>? members;
  String? type;
  List<dynamic>? messages;
  Category? channelCategory;
  List<dynamic> permittedRoles = [];
  List<dynamic>? permittedMembers;

  Channel();

  Future createChannel(
      User creator, channel, type, server, Db db, bool c, bool m, bool p,
      [category]) async {
    var localServer = db.collection(server);

    // if (c) {
    //   permittedRoles.add(permitted.creator);
    // }
    // if (m) {
    //   permittedRoles.add(permitted.moderator);
    // }
    // if (p) {
    //   permittedRoles.add(permitted.peasant);
    // }
    // if (!c && !m && !p) {
    //   permittedRoles.add(permitted.creator);
    //   permittedRoles.add(permitted.moderator);
    //   permittedRoles.add(permitted.peasant);
    // }

    if (category != null) {
      Category currentCategory =
          await Category.setCategoryData(category, server, db);
    }

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

  //private method
  Map<String, dynamic> _createChannelDoc(
      channel, activeUser, activeUserId, type) {
    final document = {
      'channelName': channel,
      'members': [
        {activeUser: activeUserId}
      ],
      'type': type,
      'permittedRoles': permittedRoles,
      'messages': []
    };
    return document;
  }
}
