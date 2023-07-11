import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io';

void main(List<String> arguments) async {
<<<<<<< HEAD
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();
  final users = db.collection('userAuth');
  final userSessions = db.collection('userSession');
  final active = await userSessions.count();

  if (active == 0) {
    final parser = ArgParser();

    parser.addOption('username', abbr: 'u', help: 'LOGIN USER');
    final parsed = parser.parse(arguments);
    String username = parsed['username'] as String;

    final user = await users.findOne(where.eq('username', username));
    if (user == null) {
      print('User not found : failure');
    } else {
      stdout.write("Enter password : ");
      stdin.echoMode = false;
      var pass = stdin.readLineSync().toString();
      print('');
      stdin.echoMode = true;
      var hashedPass = hashPass(pass);

      if (user['hash'] == hashedPass) {
        final session = {'username': username, 'sessionToken': Uuid().v4()};
        final result = await userSessions
            .insertOne(session..['_id'] = ObjectId().toHexString());
        if (result.isAcknowledged) {
          print("User logged in successfully!");
        } else {
          print('LoginError : Failure');
        }
      } else {
        print('LoginError : Incorrect Password');
      }
      await db.close();
    }
  } else {
    print('DuplicacyError : Already Logged In');
    await db.close();
  }
=======
  final db = await Db.create('mongodb://127.0.0.1:27017/testDB');
  await db.open();
  final collection = db.collection('users');

  final parser = ArgParser();
  parser.addOption('username', abbr: 'u', help: 'ADD USER');
  final parsed = parser.parse(arguments);
  String username = parsed['username'] as String;

  final user = await collection.findOne(where.match('username', username));
  if (user == null) {
    print('User not found : failure');
  } else {
    stdout.write("Enter password : ");
    var pass = stdin.readLineSync().toString();
    var hashedPass = hashPass(pass);

    while (user['hash'] != hashedPass) {
      print('Incorrect password : failure');
      stdout.write("Enter password : (enter q to exit) : ");
      pass = stdin.readLineSync().toString();
      if (pass == 'q') {
        await db.close();
        return;
      }
      hashedPass = hashPass(pass);
    }
    print("User logged in successfully!");
  }
  await db.close();
>>>>>>> 5b75c19 (login attempt)
}

String hashPass(String pass) {
  var bytes = utf8.encode(pass);
  var digest = sha256.convert(bytes);

  return digest.toString();
}
