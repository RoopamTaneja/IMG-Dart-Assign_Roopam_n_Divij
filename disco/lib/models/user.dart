import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';
import 'package:disco/models/errors.dart';

class User {
  String? id;
  String? username;
  // ignore: unused_field
  String? _hash;

  User();

  void setData(username, id, hash) {
    this.username = username;
    this.id = id;
    _hash = hash;
  }

  void get getData =>
      print("User details : Username - $username, UserID - $id");

  Future setUserData(String name, Db db) async {
    final user = await findUser(name, db);
    username = name;
    id = user['_id'];
    _hash = user['hash'];
  }

  Future? findUser(String username, Db db) async {
    final userAuth = db.collection('userAuth');
    return await userAuth.findOne(where.eq('username', username));
  }

  Future register(String name, Db db) async {
    final userAuth = db.collection('userAuth');

    stdout.write("Enter Password : ");
    stdin.echoMode = false;
    var pass = stdin.readLineSync().toString();
    stdin.echoMode = true;
    print('');
    stdout.write("Confirm Password : ");
    stdin.echoMode = false;
    var passCon = stdin.readLineSync().toString();
    stdin.echoMode = true;
    print('');

    //checking if passwords match
    if (pass == passCon) {
      var hashedPass = _hashPass(pass);
      String id = ObjectId().toHexString();
      //adding user to database
      final document = {'_id': id, 'username': name, 'hash': hashedPass};

      final result = await userAuth.insertOne(document);
      if (result.isAcknowledged) {
        setData(name, id, hashedPass);

        print('Succesfully Registered ');
      } else {
        ProcessError.UnsuccessfulProcess();
      }
    } else {
      ProcessError.PasswordMismatch();
    }
  }

  Future login(username, Db db) async {
    final userSessions = db.collection('userSession');

    final user = await findUser(username, db);
    if (user == null) {
      ProcessError.UserDoesNotExist(username);
      return;
    } else {
      //only allowing registered user to login

      stdout.write("Enter Password : ");
      stdin.echoMode = false;
      var pass = stdin.readLineSync().toString();
      print('');
      stdin.echoMode = true;
      var hashedPass = _hashPass(pass);

      //verifying user by matching password
      if (user['hash'] == hashedPass) {
        final session = {'username': username, 'sessionToken': Uuid().v4()};
        final result = await userSessions
            .insertOne(session..['_id'] = ObjectId().toHexString());
        if (result.isAcknowledged) {
          print("$username Logged in Successfully!");
        } else {
          ProcessError.UnsuccessfulProcess();
        }
      } else {
        ProcessError.PasswordMismatch();
      }
    }
  }

  Future logout(username, Db db) async {
    final userSessions = db.collection('userSession');

    final user = await findUser(username, db);
    if (user != null) {
      stdout.write("$username, Enter Your Password to Logout : ");
      stdin.echoMode = false;
      var pass = stdin.readLineSync().toString();
      print('');
      stdin.echoMode = true;
      var hashedPass = _hashPass(pass);

      //checking for validity of user logged in
      if (user['hash'] == hashedPass) {
        await userSessions.deleteMany({});
        print('Logout success');
      } else {
        ProcessError.PasswordMismatch();
      }
    } else {
      ProcessError.UnsuccessfulProcess();
    }
  }

  Future deleteAccount(Db db) async {
    final userSessions = db.collection('userSession');
    final users = db.collection('userAuth');
    final servers = db.collection('servers');

    print("Are you sure you wish to delete your account?");
    stdout.write("Enter Password to Confirm : ");
    stdin.echoMode = false;
    var pass = stdin.readLineSync().toString();
    print('');
    stdin.echoMode = true;
    var hashedPass = _hashPass(pass);

    if (_hash != hashedPass) {
      ProcessError.PasswordMismatch();
      return;
    }

    // ignore: await_only_futures
    final cursor = await servers.find();
    await for (var server in cursor) {
      var memberList = server['allMembers'];
      List<dynamic> inQueueList = server['inQueue'];
      var localServer = db.collection(server['serverName']);

      if (!memberList.any(
          (member) => member.containsKey(username) && member[username] == id)) {
        if (inQueueList.contains(username)) {
          await servers.update(
            where.eq('_id', server['_id']),
            modify.pullAll('inQueue', [username]),
          );
        }
        continue;
      }
      bool changeCreator;
      if (server['roles']['username'] == 'creator') {
        changeCreator = true;
      } else {
        changeCreator = false;
      }

      await localServer.update(
        where,
        modify.pullAll('members', [
          {username: id}
        ]),
      );

      await servers.update(
        where.eq('_id', server['_id']),
        modify.pullAll('allMembers', [
          {username: id}
        ]),
      );

      await servers.update(
        where.eq('_id', server['_id']),
        modify.unset('roles.$username'),
      );

      if (changeCreator == true) {
        Map<dynamic, dynamic> roles = server['roles'];

        var newCreator = await roles.keys
            .firstWhere((key) => roles[key] == 'moderator', orElse: () => null);

        newCreator ??= await roles.keys
            .firstWhere((key) => roles[key] == 'peasant', orElse: () => null);
        if (newCreator != null) {
          await servers.update(where.eq('_id', server['_id']),
              modify.set('roles.$newCreator', 'creator'));
        }
      }
    }

    await users.deleteOne(where.eq('username', username));
    await userSessions.deleteMany({});
    print('Account of $username Deleted Successfully.');
  }

  //private method
  String _hashPass(String pass) {
    var bytes = utf8.encode(pass);
    var digest = sha256.convert(bytes);

    return digest.toString();
  }
}
