import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';

void main(List<String> arguments) async {
  //creating a new instance of the database server
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();
  //checking for any instance of login from the database
  final users = db.collection('userAuth');
  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();
  final servers = db.collection('servers');
  if (currentSession == null) {
    //if no user logged in then no point in moving ahead
    print('LoginError : No User Logged In');
    db.close();
    return;
  }

  final cursor = await servers.find();
  final currUser = currentSession['username'];
  final currentUser = await users.findOne(where.eq('username', currUser));
  if (currentUser == null) {
    return;
  }
  dynamic userID = currentUser['_id'];

  stdout.write("Enter Password : ");
  stdin.echoMode = false;
  var pass = stdin.readLineSync().toString();
  print('');
  stdin.echoMode = true;
  var hashedPass = hashPass(pass);

  if (currentUser['hash'] != hashedPass) {
    print('Incorrect Password');
    db.close();
    return;
  }
  await for (var server in cursor) {
    var memberList = server['allMembers'];
    var localServer = db.collection(server['serverName']);

    if (!memberList.any((member) =>
        member.containsKey(currUser) && member[currUser] == userID)) {
      continue;
    }

    await localServer.update(
      where,
      modify.pullAll('members', [
        {'$currUser': userID}
      ]),
    );

    await servers.update(
      where,
      modify.pullAll('allMembers', [
        {currUser: userID}
      ]),
    );

    await servers.update(
      where,
      modify.unset('roles.$currUser'),
    );
  }

  users.deleteOne(where.eq('username', currUser));
  userSessions.deleteMany({});
  await db.close();
}

String hashPass(String pass) {
  var bytes = utf8.encode(pass);
  var digest = sha256.convert(bytes);

  return digest.toString();
}
