import 'package:mongo_dart/mongo_dart.dart';
// import 'package:disco/models/server.dart';
import 'package:disco/models/user.dart';

class Channel {
  String? channelName;
  String? serverName;
  List<Map<dynamic, dynamic>>? members;
  String? type;
  List<dynamic>? messages;

  Channel();

  Future createChannel(
      User creator, channel, type, DbCollection localServer) async {
    final document =
        _createChannelDoc(channel, creator.username, creator.id, type);

    final result = await localServer
        .insertOne(document..['_id'] = ObjectId().toHexString());

    return result;
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
      'messages': []
    };
    return document;
  }
}
