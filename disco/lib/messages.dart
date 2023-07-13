import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';

void main(List<String> arguments) async {
  //creating a new instance of the database server
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();
  //checking for any instance of login from the database

  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();
  final messageDB = db.collection('messages');
  final userAuth = db.collection('userAuth');
  final parser = ArgParser();
  parser.addOption('personal', abbr: 'p', help: "SEND PERSONAL MESSAGES");
  parser.addOption('channel', abbr: 'c', help: 'SEND MESSAGES ON CHANNEL');
  parser.addOption('server', abbr: 's', help: "SERVER FOR CHANNEL");

  parser.addOption('write', abbr: 'w', help: "WRITE MESSAGES");

  if (currentSession == null) {
    print('LoginError :  No User Logged in');
    return;
  } else {
    final parsed = parser.parse(arguments);
    final sender = currentSession['username'];
    final channel = parsed['channel'];
    final server = parsed['server'];
    final write = parsed['write'];
    final reciever = parsed['personal'];
    if (write == null) {
      print('SyntaxError : No Message to Send');
      return;
    }
    if (reciever == null && channel == null) {
      print('SyntaxError : Please Add At Least One Recipient');
      db.close();
      return;
    }
    if (channel != null && server == null) {
      print('SyntaxErorr : Kindly Enter Server');
      db.close();
      return;
    }
    if (reciever != null) {
      final document = {
        'sender': sender,
        'reciever': reciever,
        'time': DateTime.now().toString(),
        'message': write
      };
      final result = await messageDB
          .insertOne(document..['_id'] = ObjectId().toHexString());
      if (result.isAcknowledged) {
        print('Succesfully Sent ');
      } else {
        print('MessageError : Unsuccessful ');
      }
    }
    if (channel != null && server != null) {
      final serverDb = db.collection(server);
      final checkChannel =
          await serverDb.find(where.eq('channelName', channel)).isEmpty;
      if (checkChannel) {
        print('ChannelErorr : No Channel Found');
        db.close();
        return;
      }
      final document = {
        'sender': sender,
        'time': DateTime.now().toString(),
        'message': write
      };
      final channelDb = await serverDb.update(
          where.eq('channelName', channel), modify.push('messages', document));

      print('Message Sent Succesful');
    }
  }
  await db.close();
}
