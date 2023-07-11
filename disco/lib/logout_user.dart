import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io';

void main(List<String> arguments) async {
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();
  final users = db.collection('userAuth');
  final userSessions = db.collection('userSession');
  final user = await users.findOne();

  stdout.write("Enter password : ");
  stdin.echoMode = false;
  var pass = stdin.readLineSync().toString();
  print('');
  stdin.echoMode = true;
  var hashedPass = hashPass(pass);
  if (user == null) {
    print('LogoutError : No User Logged in!');
  } else if (user['hash'] == hashedPass) {
    await userSessions.deleteMany({});
    print('Logout success');

    await db.close();
  } else {
    print('LogoutError : Unsuccesful Logout Attempt');
    await db.close();
  }
}

String hashPass(String pass) {
  var bytes = utf8.encode(pass);
  var digest = sha256.convert(bytes);

  return digest.toString();
}
