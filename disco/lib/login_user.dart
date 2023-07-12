import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();
  final users = db.collection('userAuth');
  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  if (currentSession == null) {
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
          print("$username logged in successfully!");
        } else {
          print('LoginError : Failure');
        }
      } else {
        print('LoginError : Incorrect Password');
      }
    }
  } else {
    String username = currentSession['username'];
    print('DuplicacyError : $username already logged in');
  }
  await db.close();
}

String hashPass(String pass) {
  var bytes = utf8.encode(pass);
  var digest = sha256.convert(bytes);

  return digest.toString();
}
