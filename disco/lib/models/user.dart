import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:io';

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

  Future setUserData(String name, DbCollection userAuth) async {
    final user = await findUser(name, userAuth);
    username = name;
    id = user['_id'];
    _hash = user['hash'];
  }

  Future? findUser(String username, DbCollection userAuth) async {
    return await userAuth.findOne(where.eq('username', username));
  }

  Future register(String name, DbCollection userAuth) async {
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
        print('RegistrationError : Unsuccessful Login');
      }
    } else {
      print('LoginError :  Password do not Match');
    }
  }

  Future login(username, userAuth, userSessions) async {
    final user = await findUser(username, userAuth);
    if (user == null) {
      print('LoginError : User $username Not Found');
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
          print('LoginError : Failure');
        }
      } else {
        print('LoginError : Incorrect Password');
      }
    }
  }

  Future logout(username, userAuth, userSessions) async {
    final user = await findUser(username, userAuth);
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
        print('LogoutError : Incorrect Password');
      }
    } else {
      print('LogoutError : Unsuccesful Logout Attempt');
    }
  }

  //private method
  String _hashPass(String pass) {
    var bytes = utf8.encode(pass);
    var digest = sha256.convert(bytes);

    return digest.toString();
  }
}
