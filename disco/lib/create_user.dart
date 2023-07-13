import 'package:args/args.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:io';

void main(List<String> arguments) async {
  //creating a new instance of the database server
  final db = await Db.create('mongodb://127.0.0.1:27017/myDB');
  await db.open();

  //checking for any instance of login from the database
  final userSessions = db.collection('userSession');
  final currentSession = await userSessions.findOne();

  if (currentSession == null) {
    //evaluating the command line arguments
    final parser = ArgParser();
    parser.addOption('username', abbr: 'u', help: 'ADD USER');
    final parsed = parser.parse(arguments);
    String username = parsed['username'] as String;

    //registering the user in database USERAUTH
    final userAuth = db.collection('userAuth');
    final user = await userAuth.findOne(where.eq('username', username));

    //only registering if user does not exist
    if (user == null) {
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
        var hashedPass = hashPass(pass);

        //adding user to database
        final document = {'username': username, 'hash': hashedPass};
        final result = await userAuth
            .insertOne(document..['_id'] = ObjectId().toHexString());
        if (result.isAcknowledged) {
          print('Succesfully Registered ');
        } else {
          print('RegistrationError : Unsuccessful Login');
        }
      } else {
        print('LoginError :  Password do not Match');
      }
    } else {
      print('DuplicacyError : User Already Exists');
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
