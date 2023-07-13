import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io';

void main(List<String> arguments) async {
  //creating instance of database server
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  final users = db.collection('userAuth');
  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  //checking if any user is logged in
  if (currentSession != null) {
    String username = currentSession['username'];
    final user = await users.findOne(where.eq('username', username));

    //checking for existance of user logged in
    if (user != null) {
      stdout.write("$username, Enter Your Password to Logout : ");
      stdin.echoMode = false;
      var pass = stdin.readLineSync().toString();
      print('');
      stdin.echoMode = true;
      var hashedPass = hashPass(pass);

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
  } else {
    print('LogoutError : No User Logged in!');
  }
  await db.close();
}

String hashPass(String pass) {
  var bytes = utf8.encode(pass);
  var digest = sha256.convert(bytes);

  return digest.toString();
}
