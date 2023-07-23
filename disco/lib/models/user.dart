import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';
import 'package:disco/models/errors.dart';
import 'package:disco/models/checks.dart';

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

  Future<void> setUserData(String name, Db db) async {
    final user = await findUser(name, db);
    username = name;
    id = user!['_id'];
    _hash = user['hash'];
  }

  Future<Map<String, dynamic>?> findUser(String username, Db db) async {
    final userAuth = db.collection('userAuth');
    return await userAuth.findOne(where.eq('username', username));
  }

  Future<void> register(String name, Db db) async {
    final userAuth = db.collection('userAuth');
    print(
        "Password must satify the following characteristics:\n-> At least one uppercase letter\n-> At least one lowercase letter\n-> At least one digit\n-> Minimum length of 8 characters ");
    stdout.write("Enter Password : ");
    stdin.echoMode = false;
    var pass = stdin.readLineSync().toString();
    stdin.echoMode = true;
    print('');
    if (!(await Checks.isValidPassword(pass))) {
      ProcessError.PasswordMismatch();
      return;
    }
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

  Future<void> login(username, Db db) async {
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

  Future<void> logout(username, Db db) async {
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

  Future<void> sendDM(msg, receiver, Db db) async {
    final messageDB = db.collection('messages');

    if (receiver == username) {
      ProcessError.RecipientError();
      return;
    }

    bool checkReceiver = await Checks.userExists(receiver, db);
    if (!checkReceiver) {
      ProcessError.UserDoesNotExist(receiver);
      return;
    }

    final document = {
      'sender': username,
      'receiver': receiver,
      'time': DateTime.now().toString(),
      'message': msg
    };
    final result =
        await messageDB.insertOne(document..['_id'] = ObjectId().toHexString());
    if (result.isAcknowledged) {
      print('Succesfully Sent');
    } else {
      ProcessError.UnsuccessfulProcess();
    }
  }

  Future<void> showDM(sender, limitF, Db db) async {
    final messageDB = db.collection('messages');
    final receiver = username;

    if (sender == "ALL") {
      final messages =
          await messageDB.find(where.eq('receiver', receiver)).toList();
      if (messages.isNotEmpty) {
        for (var i in messages.reversed) {
          print('FROM : ${i['sender']}');
          print('SENT ON : ${i['time']}');
          print(i['message']);
          print('');
          limitF--;
          if (limitF == 0) {
            break;
          }
        }
      } else {
        ("No Personal Messages Found in Inbox.");
      }
      return;
    }

    if (sender == receiver) {
      ProcessError.RecipientError();
      return;
    }

    //sender != "ALL" && sender != null
    bool checkSender = await Checks.userExists(sender, db);
    if (!checkSender) {
      ProcessError.UserDoesNotExist(sender);
      return;
    }
    final messages = await messageDB
        .find(where.eq('receiver', receiver).and(where.eq('sender', sender)))
        .toList();
    if (messages.isNotEmpty) {
      for (var i in messages.reversed) {
        print('FROM :${i['sender']}');
        print('SENT ON : ${i['time']}');
        print(i['message']);
        print('');
        limitF--;
        if (limitF == 0) {
          break;
        }
      }
    } else {
      ("No Personal Messages Found in Inbox From $sender.");
    }
  }

  Future<void> deleteAccount(Db db) async {
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
      var localServer = db.collection('${server['serverName']}');

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

      // ignore: await_only_futures
      final channelCursor = await localServer.find();
      await for (var channel in channelCursor) {
        await localServer.update(
          where.eq('channelName', channel['channelName']),
          modify.pullAll('members', [
            {username: id}
          ]),
        );
      }
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
